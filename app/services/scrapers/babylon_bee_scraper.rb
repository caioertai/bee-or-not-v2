require 'net/http'
require 'uri'
require 'nokogiri'

module Scrapers
  class BabylonBeeScraper
    BASE_URL = 'https://babylonbee.com'
    NEWS_PATH = '/news'

    def initialize
      @source = find_or_create_source
    end

    def scrape_headlines(page: 1)
      url = build_url(page: page)
      response = fetch_page(url)
      
      return [] unless response.is_a?(Net::HTTPSuccess)
      
      parse_headlines(response.body)
    end

    private

    def find_or_create_source
      Source.find_or_create_by(slug: 'babylon-bee') do |source|
        source.base_url = BASE_URL
        source.name = 'The Babylon Bee'
        source.real = false
      end
    end

    def build_url(page: 1)
      uri = URI.join(BASE_URL, NEWS_PATH)
      uri.query = "page=#{page}" if page > 1
      uri.to_s
    end

    def fetch_page(url)
      uri = URI(url)
      
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        request['User-Agent'] = 'Mozilla/5.0 (compatible; BeeOrNotBot/1.0)'
        http.request(request)
      end
    rescue => e
      Rails.logger.error "Failed to fetch #{url}: #{e.message}"
      nil
    end

    def parse_headlines(html)
      doc = Nokogiri::HTML(html)
      headlines = []

      doc.css('.post-item, .article-card, .bb-article-card, .post').each do |card|
        headline_data = extract_headline_data(card)
        next if headline_data.nil?

        headlines << create_headline(headline_data)
      end

      headlines.compact
    end

    def extract_headline_data(card)
      title_element = card.css('h1 a, h2 a, h3 a, .title a, .headline a').first
      return nil unless title_element

      title = title_element.text.strip
      return nil if title.blank?

      link = title_element['href']
      link = URI.join(BASE_URL, link).to_s if link&.start_with?('/')

      {
        content: title,
        source_url: link
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