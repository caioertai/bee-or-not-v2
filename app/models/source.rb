class Source < ApplicationRecord
  has_many :headlines, dependent: :destroy

  validates :base_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(['http', 'https']) }
  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :real, inclusion: { in: [ true, false ] }

  scope :real, -> { where(real: true) }
  scope :fake, -> { where(real: false) }
end
