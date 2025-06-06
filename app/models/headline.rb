class Headline < ApplicationRecord
  belongs_to :source

  validates :content, presence: true, length: { minimum: 10, maximum: 500 }
  validates :real, inclusion: { in: [ true, false ] }

  scope :real, -> { where(real: true) }
  scope :fake, -> { where(real: false) }

  def source_url
    read_attribute(:source_url) || source&.base_url
  end

  def real?
    real
  end

  def fake?
    !real
  end
end
