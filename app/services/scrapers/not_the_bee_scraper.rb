require "net/http"
require "uri"
require "json"
require "nokogiri"
require "cgi"
require "base64"

module Scrapers
  class NotTheBeeScraper
    BASE_URL = "https://notthebee.com"
    API_PATH = "/loadArticles"

    def initialize
      @source = find_or_create_source
    end

    def scrape_headlines(page: 1)
      response = fetch_articles(page: page)

      return [] unless response.is_a?(Net::HTTPSuccess)

      parse_articles_json(response.body)
    end

    private

    def find_or_create_source
      Source.find_or_create_by(slug: "not-the-bee") do |source|
        source.base_url = BASE_URL
        source.name = "Not the Bee"
        source.real = true
      end
    end

    def fetch_articles(page: 1)
      # First get the CSRF token from the main page
      csrf_token, session_cookie = get_csrf_token
      return nil unless csrf_token && session_cookie

      uri = URI.join(BASE_URL, API_PATH)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Post.new(uri)
        request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36"
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json, text/plain, */*"
        request["Accept-Language"] = "en-US,en;q=0.9,es;q=0.8"
        request["X-Requested-With"] = "XMLHttpRequest"
        request["Cookie"] = session_cookie
        request["Origin"] = BASE_URL
        request["Sec-Fetch-Dest"] = "empty"
        request["Sec-Fetch-Mode"] = "cors"
        request["Sec-Fetch-Site"] = "same-origin"
        request["x-xsrf-token"] = csrf_token
        request["Referer"] = "#{BASE_URL}/news?page=#{page}"

        # Send JSON body with pagination parameters
        skip = (page - 1) * 12  # Calculate skip based on page (12 items per page)
        request_data = {
          category: "latest",
          sort: "desc",
          skip: skip,
          take: 12,
          isAuthor: false
        }
        request.body = request_data.to_json

        http.request(request)
      end
    rescue => e
      Rails.logger.error "Failed to fetch articles from API: #{e.message}"
      nil
    end

    def get_csrf_token
      uri = URI.join(BASE_URL, "/news")

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36"

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
      source_url = path.present? ? URI.join(BASE_URL, path).to_s : BASE_URL

      {
        content: title.strip,
        source_url: source_url
      }
    end

    def create_headline(data)
      existing_headline = Headline.joins(:source)
                                  .where(content: data[:content], sources: { slug: "not-the-bee" })
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
