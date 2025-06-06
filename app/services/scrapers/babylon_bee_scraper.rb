require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'

module Scrapers
  class BabylonBeeScraper
    BASE_URL = 'https://babylonbee.com'
    API_PATH = '/loadArticles'

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
      Source.find_or_create_by(slug: 'babylon-bee') do |source|
        source.base_url = BASE_URL
        source.name = 'The Babylon Bee'
        source.real = false
      end
    end

    def fetch_articles(page: 1)
      # First get the CSRF token from the main page
      csrf_token, session_cookie = get_csrf_token
      return nil unless csrf_token && session_cookie

      uri = URI.join(BASE_URL, API_PATH)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri)
        request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        request['Content-Type'] = 'application/x-www-form-urlencoded'
        request['Accept'] = 'application/json, text/javascript, */*; q=0.01'
        request['X-Requested-With'] = 'XMLHttpRequest'
        request['Cookie'] = session_cookie
        request['X-CSRF-TOKEN'] = csrf_token
        request['Referer'] = "#{BASE_URL}/news"
        
        # Send CSRF token and page parameter in POST body
        # Try different parameter formats that Laravel might expect
        request.body = "_token=#{csrf_token}" + (page > 1 ? "&page=#{page}" : "")
        
        http.request(request)
      end
    rescue => e
      Rails.logger.error "Failed to fetch articles from API: #{e.message}"
      nil
    end

    def get_csrf_token
      uri = URI.join(BASE_URL, '/news')

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        request['User-Agent'] = 'Mozilla/5.0 (compatible; BeeOrNotBot/1.0)'
        
        response = http.request(request)
        
        if response.is_a?(Net::HTTPSuccess)
          # Extract CSRF token from meta tag
          doc = Nokogiri::HTML(response.body)
          csrf_meta = doc.css('meta[name="csrf-token"]').first
          csrf_token = csrf_meta&.attr('content')
          
          # Extract all cookies - Laravel needs both XSRF-TOKEN and session cookie
          cookies = response.get_fields('Set-Cookie')
          session_cookies = cookies&.map { |cookie| cookie.split(';').first }&.join('; ')
          
          return [csrf_token, session_cookies] if csrf_token && session_cookies
        end
      end
      
      [nil, nil]
    rescue => e
      Rails.logger.error "Failed to get CSRF token: #{e.message}"
      [nil, nil]
    end

    def parse_articles_json(json_body)
      data = JSON.parse(json_body)
      headlines = []

      articles = data['articles'] || []
      
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
      title = article['title']
      return nil if title.blank?

      path = article['path']
      source_url = path.present? ? URI.join(BASE_URL, path).to_s : BASE_URL

      {
        content: title.strip,
        source_url: source_url
      }
    end

    def create_headline(data)
      existing_headline = Headline.joins(:source)
                                  .where(content: data[:content], sources: { slug: 'babylon-bee' })
                                  .first

      return existing_headline if existing_headline

      Headline.create!(
        content: data[:content],
        real: @source.real,
        source: @source
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn "Failed to create headline: #{e.message}"
      nil
    end
  end
end
