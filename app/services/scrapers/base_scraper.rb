require "net/http"
require "uri"
require "json"
require "cgi"
require "yaml"

module Scrapers
  class BaseScraper
    def initialize(config_key)
      @config = load_config(config_key)
      @source = find_or_create_source
    end

    def scrape_headlines(page: 1)
      response = fetch_articles(page: page)

      return [] unless response.is_a?(Net::HTTPSuccess)

      parse_articles_json(response.body)
    end

    private

    def load_config(config_key)
      config_file = Rails.root.join("config", "scrapers.yml")
      
      unless File.exist?(config_file)
        raise "Scraper configuration file not found: #{config_file}"
      end

      yaml_config = YAML.load_file(config_file)[Rails.env.to_s]
      
      unless yaml_config && yaml_config[config_key.to_s]
        raise "Scraper configuration not found for key: #{config_key} in environment: #{Rails.env}"
      end

      yaml_config[config_key.to_s]
    end

    def find_or_create_source
      Source.find_or_create_by(slug: @config["source_slug"]) do |source|
        source.base_url = @config["base_url"]
        source.name = @config["source_name"]
        source.real = @config["real"]
      end
    end

    def fetch_articles(page: 1)
      # First get the CSRF token from the main page
      csrf_token, session_cookie = get_csrf_token
      return nil unless csrf_token && session_cookie

      uri = URI.join(@config["base_url"], @config["api_path"])

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Post.new(uri)
        
        # Set headers from configuration
        request["User-Agent"] = @config["user_agent"]
        request["Content-Type"] = @config["headers"]["content_type"]
        request["Accept"] = @config["headers"]["accept"]
        request["Accept-Language"] = @config["headers"]["accept_language"]
        request["X-Requested-With"] = @config["headers"]["x_requested_with"]
        request["Cookie"] = session_cookie
        request["Origin"] = @config["base_url"]
        request["Sec-Fetch-Dest"] = @config["headers"]["sec_fetch_dest"]
        request["Sec-Fetch-Mode"] = @config["headers"]["sec_fetch_mode"]
        request["Sec-Fetch-Site"] = @config["headers"]["sec_fetch_site"]
        request["x-xsrf-token"] = csrf_token
        request["Referer"] = "#{@config["base_url"]}/news?page=#{page}"

        # Send JSON body with pagination parameters
        skip = (page - 1) * @config["request_params"]["take"]
        request_data = @config["request_params"].dup
        request_data["skip"] = skip
        request_data["isAuthor"] = request_data.delete("is_author")  # Convert snake_case to camelCase
        
        request.body = request_data.to_json

        http.request(request)
      end
    rescue => e
      Rails.logger.error "Failed to fetch articles from API: #{e.message}"
      nil
    end

    def get_csrf_token
      uri = URI.join(@config["base_url"], "/news")

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = @config["user_agent"]

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          # Extract all cookies - Laravel needs both XSRF-TOKEN and session cookie
          cookies = response.get_fields("Set-Cookie")
          session_cookies = cookies&.map { |cookie| cookie.split(";").first }&.join("; ")

          # Extract XSRF token from cookies
          xsrf_cookie = cookies&.find { |cookie| cookie.start_with?("XSRF-TOKEN=") }
          if xsrf_cookie
            encoded_token = xsrf_cookie.split("=", 2)[1].split(";").first
            # URL decode the token
            xsrf_token = CGI.unescape(encoded_token)

            # Use the raw encoded token directly (as seen in the curl example)
            return [ xsrf_token, session_cookies ] if session_cookies
          end
        end
      end

      [ nil, nil ]
    rescue => e
      Rails.logger.error "Failed to get CSRF token: #{e.message}"
      [ nil, nil ]
    end

    def parse_articles_json(json_body)
      data = JSON.parse(json_body)
      headlines = []

      articles = data["articles"] || []

      articles.each do |article|
        headline_data = extract_article_data(article)
        next if headline_data.nil?

        headlines << create_headline(headline_data)
      end

      headlines.compact
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse JSON response: #{e.message}"
      []
    end

    def extract_article_data(article)
      title = article["title"]
      return nil if title.blank?

      path = article["path"]
      source_url = path.present? ? URI.join(@config["base_url"], path).to_s : @config["base_url"]

      {
        content: title.strip,
        source_url: source_url
      }
    end

    def create_headline(data)
      existing_headline = Headline.joins(:source)
                                  .where(content: data[:content], sources: { slug: @config["source_slug"] })
                                  .first

      return existing_headline if existing_headline

      Headline.create!(
        content: data[:content],
        real: @source.real,
        source: @source,
        source_url: data[:source_url]
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn "Failed to create headline: #{e.message}"
      nil
    end
  end
end