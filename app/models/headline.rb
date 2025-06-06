class Headline < ApplicationRecord
  belongs_to :source

  validates :content, presence: true, length: { minimum: 10, maximum: 500 }
  validates :real, inclusion: { in: [ true, false ] }
  validates :source_url, presence: true

  scope :real, -> { where(real: true) }
  scope :fake, -> { where(real: false) }

  def real?
    real
  end

  def fake?
    !real
  end
end
