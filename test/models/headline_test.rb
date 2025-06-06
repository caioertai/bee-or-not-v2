require "test_helper"

class HeadlineTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    headline = Headline.new(content: "Valid headline content", real: true, source: sources(:reuters))
    assert headline.valid?
  end

  test "should require content" do
    headline = Headline.new(real: true)
    assert_not headline.valid?
    assert_includes headline.errors[:content], "can't be blank"
  end

  test "should require real field" do
    headline = Headline.new(content: "Valid headline content")
    assert_not headline.valid?
    assert_includes headline.errors[:real], "is not included in the list"
  end

  test "content should have minimum length" do
    headline = Headline.new(content: "short", real: true)
    assert_not headline.valid?
    assert_includes headline.errors[:content], "is too short (minimum is 10 characters)"
  end

  test "content should have maximum length" do
    long_content = "a" * 501
    headline = Headline.new(content: long_content, real: true)
    assert_not headline.valid?
    assert_includes headline.errors[:content], "is too long (maximum is 500 characters)"
  end

  test "real? should return true for real headlines" do
    headline = Headline.new(content: "Real headline content", real: true)
    assert headline.real?
  end

  test "fake? should return true for fake headlines" do
    headline = Headline.new(content: "Fake headline content", real: false)
    assert headline.fake?
  end

  test "source_url should return stored source_url when present" do
    headline = headlines(:real_headline)
    url = headline.source_url
    assert_equal "https://reuters.com/news/scientists-discover-treatment", url
  end

  test "source_url should fallback to source base_url when not set" do
    headline = Headline.new(content: "Test headline", real: true, source: sources(:reuters))
    url = headline.source_url
    assert_equal headline.source.base_url, url
  end

  test "real scope should return only real headlines" do
    real_count = Headline.real.count
    total_real = Headline.where(real: true).count
    assert_equal total_real, real_count
  end

  test "fake scope should return only fake headlines" do
    fake_count = Headline.fake.count
    total_fake = Headline.where(real: false).count
    assert_equal total_fake, fake_count
  end
end
