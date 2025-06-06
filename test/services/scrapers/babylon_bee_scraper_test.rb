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

  test "should parse JSON response correctly" do
    json_response = {
      "articles" => [
        {
          "id" => 18501,
          "title" => "Test Headline",
          "path" => "/news/test-article"
        }
      ]
    }.to_json
    
    headlines = @scraper.send(:parse_articles_json, json_response)
    
    assert_equal 1, headlines.length
    assert_equal 'Test Headline', headlines.first.content
  end

  test "should extract article data from JSON object" do
    article = {
      "id" => 18501,
      "title" => "Test Headline",
      "path" => "/news/test-article"
    }
    
    data = @scraper.send(:extract_article_data, article)
    
    assert_not_nil data
    assert_equal 'Test Headline', data[:content]
    assert_equal 'https://babylonbee.com/news/test-article', data[:source_url]
  end

  test "should return nil for article without title" do
    article = {
      "id" => 18501,
      "path" => "/news/test-article"
    }
    
    data = @scraper.send(:extract_article_data, article)
    
    assert_nil data
  end

  test "should handle missing path in article data" do
    article = {
      "id" => 18501,
      "title" => "Test Headline"
    }
    
    data = @scraper.send(:extract_article_data, article)
    
    assert_not_nil data
    assert_equal 'Test Headline', data[:content]
    assert_equal 'https://babylonbee.com', data[:source_url]
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