class Game < ApplicationRecord
  has_many :rounds, dependent: :destroy

  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def total_rounds
    rounds.count
  end

  def correct_rounds
    rounds.where(correct: true).count
  end

  def accuracy_percentage
    return 0 if total_rounds.zero?

    (correct_rounds.to_f / total_rounds * 100).round(1)
  end

  def current_round
    @current_round ||= rounds.build
  end

  def increment_score!
    increment!(:score)
  end
end
