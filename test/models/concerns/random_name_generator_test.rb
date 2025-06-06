require "test_helper"

class RandomNameGeneratorTest < ActiveSupport::TestCase
  test "generates random name with adjective, animal, and number" do
    name = RandomNameGenerator.generate

    assert_not_nil name
    parts = name.split(" ")
    assert_equal 3, parts.length

    adjective, animal, number = parts
    assert_includes RandomNameGenerator::ADJECTIVES, adjective
    assert_includes RandomNameGenerator::ANIMALS, animal
    assert_match(/\A\d{3}\z/, number)
    assert number.to_i >= 100
    assert number.to_i <= 999
  end

  test "generates different names on multiple calls" do
    names = 10.times.map { RandomNameGenerator.generate }

    # With the large number of combinations, we should get mostly unique names
    assert names.uniq.length >= 8, "Should generate mostly unique names"
  end

  test "has sufficient variety to avoid collisions" do
    # With ~200 adjectives, ~200 animals, and 900 numbers, we have ~36M combinations
    adjectives_count = RandomNameGenerator::ADJECTIVES.length
    animals_count = RandomNameGenerator::ANIMALS.length
    numbers_count = 900 # 100-999

    total_combinations = adjectives_count * animals_count * numbers_count

    assert adjectives_count >= 100, "Should have at least 100 adjectives"
    assert animals_count >= 100, "Should have at least 100 animals"
    assert total_combinations >= 1_000_000, "Should have at least 1M combinations"
  end
end
