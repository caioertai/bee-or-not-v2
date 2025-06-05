class Headline < ApplicationRecord
  validates :content, presence: true, length: { minimum: 10, maximum: 500 }
  validates :real, inclusion: { in: [ true, false ] }

  scope :real_headlines, -> { where(real: true) }
  scope :fake_headlines, -> { where(real: false) }

  def source_url
    # Placeholder implementation - will be replaced with actual DB field later
    domains = [
      "https://www.bbc.com/news/example-article-#{id}",
      "https://www.reuters.com/world/example-story-#{id}",
      "https://www.cnn.com/news/example-#{id}",
      "https://www.theguardian.com/world/example-#{id}",
      "https://apnews.com/article/example-#{id}"
    ]
    domains.sample
  end

  def real?
    real
  end

  def fake?
    !real
  end
end
