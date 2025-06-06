require "test_helper"

class HeadlineTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    headline = Headline.new(content: "Valid headline content", real: true, source: sources(:not_the_bee), source_url: "https://example.com/news")
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
    headline = Headline.new(content: "short", real: true, source: sources(:not_the_bee), source_url: "https://example.com/news")
    assert_not headline.valid?
    assert_includes headline.errors[:content], "is too short (minimum is 10 characters)"
  end

  test "content should have maximum length" do
    long_content = "a" * 501
    headline = Headline.new(content: long_content, real: true, source: sources(:not_the_bee), source_url: "https://example.com/news")
    assert_not headline.valid?
    assert_includes headline.errors[:content], "is too long (maximum is 500 characters)"
  end

  test "real? should return true for real headlines" do
    headline = Headline.new(content: "Real headline content", real: true, source: sources(:not_the_bee), source_url: "https://example.com/news")
    assert headline.real?
  end

  test "fake? should return true for fake headlines" do
    headline = Headline.new(content: "Fake headline content", real: false, source: sources(:babylon_bee), source_url: "https://example.com/news")
    assert headline.fake?
  end

  test "should require source_url" do
    headline = Headline.new(content: "Valid headline content", real: true, source: sources(:not_the_bee))
    assert_not headline.valid?
    assert_includes headline.errors[:source_url], "can't be blank"
  end

  test "should be valid with source_url" do
    headline = Headline.new(content: "Valid headline content", real: true, source: sources(:not_the_bee), source_url: "https://example.com/news")
    assert headline.valid?
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
