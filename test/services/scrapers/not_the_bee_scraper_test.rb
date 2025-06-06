require "test_helper"

class Scrapers::NotTheBeeScraperTest < ActiveSupport::TestCase
  setup do
    @scraper = Scrapers::NotTheBeeScraper.new
  end

  test "should create not the bee source" do
    source = Source.find_by(slug: "not-the-bee")
    assert_not_nil source
    assert_equal "Not the Bee", source.name
    assert_equal "https://notthebee.com", source.base_url
    assert_equal true, source.real
  end

  test "should parse JSON response correctly" do
    json_response = {
      "articles" => [
        {
          "id" => 18501,
          "title" => "Test Real News Headline",
          "path" => "/news/test-article"
        }
      ]
    }.to_json

    headlines = @scraper.send(:parse_articles_json, json_response)

    assert_equal 1, headlines.length
    assert_equal "Test Real News Headline", headlines.first.content
  end

  test "should extract article data from JSON object" do
    article = {
      "id" => 18501,
      "title" => "Test Real News Headline",
      "path" => "/news/test-article"
    }

    data = @scraper.send(:extract_article_data, article)

    assert_not_nil data
    assert_equal "Test Real News Headline", data[:content]
    assert_equal "https://notthebee.com/news/test-article", data[:source_url]
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
      "title" => "Test Real News Headline"
    }

    data = @scraper.send(:extract_article_data, article)

    assert_not_nil data
    assert_equal "Test Real News Headline", data[:content]
    assert_equal "https://notthebee.com", data[:source_url]
  end

  test "should not create duplicate headlines" do
    source = sources(:not_the_bee)
    existing_headline = Headline.create!(
      content: "Existing Test Real Headline",
      real: true,
      source: source,
      source_url: "https://notthebee.com/news/existing-test"
    )

    initial_count = Headline.count

    data = { content: "Existing Test Real Headline", source_url: "https://example.com" }
    result = @scraper.send(:create_headline, data)

    assert_equal existing_headline, result
    assert_equal initial_count, Headline.count
  end

  test "should create headline with source_url" do
    initial_count = Headline.count

    data = {
      content: "New Test Real Headline",
      source_url: "https://notthebee.com/news/new-test-headline"
    }
    result = @scraper.send(:create_headline, data)

    assert_not_nil result
    assert_equal initial_count + 1, Headline.count
    assert_equal "New Test Real Headline", result.content
    assert_equal "https://notthebee.com/news/new-test-headline", result.source_url
    assert_equal true, result.real
  end
end
