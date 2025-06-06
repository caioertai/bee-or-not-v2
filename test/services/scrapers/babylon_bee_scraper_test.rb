require 'test_helper'

class Scrapers::BabylonBeeScraperTest < ActiveSupport::TestCase
  setup do
    @scraper = Scrapers::BabylonBeeScraper.new
  end

  test "should create babylon bee source" do
    source = Source.find_by(slug: 'babylon-bee')
    assert_not_nil source
    assert_equal 'The Babylon Bee', source.name
    assert_equal 'https://babylonbee.com', source.base_url
    assert_equal false, source.real
  end

  test "should build correct URL for page 1" do
    url = @scraper.send(:build_url, page: 1)
    assert_equal 'https://babylonbee.com/news', url
  end

  test "should build correct URL for page 2" do
    url = @scraper.send(:build_url, page: 2)
    assert_equal 'https://babylonbee.com/news?page=2', url
  end

  test "should extract headline data from HTML element" do
    html = '<div class="post-item"><h2><a href="/news/article-1">Test Headline</a></h2></div>'
    doc = Nokogiri::HTML(html)
    card = doc.css('.post-item').first
    
    data = @scraper.send(:extract_headline_data, card)
    
    assert_not_nil data
    assert_equal 'Test Headline', data[:content]
    assert_equal 'https://babylonbee.com/news/article-1', data[:source_url]
  end

  test "should return nil for invalid HTML element" do
    html = '<div class="post-item"><p>No headline here</p></div>'
    doc = Nokogiri::HTML(html)
    card = doc.css('.post-item').first
    
    data = @scraper.send(:extract_headline_data, card)
    
    assert_nil data
  end

  test "should not create duplicate headlines" do
    source = sources(:babylon_bee)
    existing_headline = Headline.create!(
      content: "Existing Test Headline",
      real: false,
      source: source
    )

    initial_count = Headline.count
    
    data = { content: "Existing Test Headline", source_url: "https://example.com" }
    result = @scraper.send(:create_headline, data)
    
    assert_equal existing_headline, result
    assert_equal initial_count, Headline.count
  end
end