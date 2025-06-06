# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data to ensure idempotency
Headline.destroy_all
Source.destroy_all

# Real headlines - based on actual news patterns
real_headlines = [
  "Scientists Discover New Species of Deep-Sea Fish in Mariana Trench",
  "Global Climate Summit Reaches Historic Agreement on Carbon Emissions",
  "Tech Giant Announces Major Investment in Renewable Energy Infrastructure",
  "Archaeological Team Uncovers 2,000-Year-Old Roman Villa in Southern Italy",
  "Medical Breakthrough: New Treatment Shows Promise for Alzheimer's Disease"
]

# Fake headlines - deliberately absurd but could fool someone quickly
fake_headlines = [
  "Researchers Confirm That Cats Can Actually Understand Quantum Physics",
  "Breaking: Moon Announces Independence from Earth After 4.5 Billion Years",
  "Local Man Discovers WiFi Password Has Been 'Password123' This Entire Time",
  "Study Shows That Talking to Plants in French Makes Them Grow Faster",
  "Scientists Prove That Monday is Actually the Worst Day of the Week"
]

# Create sources
real_source = Source.find_or_create_by!(slug: 'not-the-bee') do |source|
  source.base_url = 'https://notthebee.com'
  source.name = 'Not the Bee'
  source.real = true
end

fake_source = Source.find_or_create_by!(slug: 'babylon-bee') do |source|
  source.base_url = 'https://babylonbee.com'
  source.name = 'The Babylon Bee'
  source.real = false
end

# Create real headlines
real_headlines.each_with_index do |content, index|
  Headline.find_or_create_by!(content: content) do |headline|
    headline.real = true
    headline.source = real_source
    headline.source_url = "#{real_source.base_url}/news/article-#{index + 1}"
  end
end

# Create fake headlines
fake_headlines.each_with_index do |content, index|
  Headline.find_or_create_by!(content: content) do |headline|
    headline.real = false
    headline.source = fake_source
    headline.source_url = "#{fake_source.base_url}/news/fake-article-#{index + 1}"
  end
end

puts "Seeded #{Headline.count} headlines (#{Headline.real.count} real, #{Headline.fake.count} fake)"
