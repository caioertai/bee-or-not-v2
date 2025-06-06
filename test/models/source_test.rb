require "test_helper"

class SourceTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    source = Source.new(
      base_url: "https://example.com",
      slug: "example",
      name: "Example News",
      real: true
    )
    assert source.valid?
  end

  test "should require base_url" do
    source = Source.new(slug: "test", name: "Test", real: true)
    assert_not source.valid?
    assert_includes source.errors[:base_url], "can't be blank"
  end

  test "should require valid URL format" do
    source = Source.new(
      base_url: "not-a-url",
      slug: "test",
      name: "Test",
      real: true
    )
    assert_not source.valid?
    assert_includes source.errors[:base_url], "is invalid"
  end

  test "should require slug" do
    source = Source.new(base_url: "https://example.com", name: "Test", real: true)
    assert_not source.valid?
    assert_includes source.errors[:slug], "can't be blank"
  end

  test "should require unique slug" do
    Source.create!(
      base_url: "https://example.com",
      slug: "unique-slug",
      name: "Test",
      real: true
    )

    duplicate_source = Source.new(
      base_url: "https://other.com",
      slug: "unique-slug",
      name: "Other",
      real: false
    )
    
    assert_not duplicate_source.valid?
    assert_includes duplicate_source.errors[:slug], "has already been taken"
  end

  test "should require name" do
    source = Source.new(base_url: "https://example.com", slug: "test", real: true)
    assert_not source.valid?
    assert_includes source.errors[:name], "can't be blank"
  end

  test "should require real field" do
    source = Source.new(base_url: "https://example.com", slug: "test", name: "Test")
    assert_not source.valid?
    assert_includes source.errors[:real], "is not included in the list"
  end

  test "real scope should return only real sources" do
    real_count = Source.real.count
    total_real = Source.where(real: true).count
    assert_equal total_real, real_count
  end

  test "fake scope should return only fake sources" do
    fake_count = Source.fake.count
    total_fake = Source.where(real: false).count
    assert_equal total_fake, fake_count
  end

  test "should have headlines association" do
    source = sources(:reuters)
    assert_respond_to source, :headlines
    assert source.headlines.count > 0
  end
end
