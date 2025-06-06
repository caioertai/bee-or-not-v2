class Game < ApplicationRecord
  has_many :rounds, dependent: :destroy
  has_many :guesses, through: :rounds

  after_create :create_first_round

  def total_rounds
    rounds.joins(:guesses).distinct.count
  end

  def correct_rounds
    rounds.joins(:guesses).where(guesses: { correct: true }).distinct.count
  end

  def score
    guesses.where(correct: true).count
  end

  def accuracy_percentage
    return 0 if total_rounds.zero?

    (correct_rounds.to_f / total_rounds * 100).round(1)
  end

  def current_round
    rounds.includes(:guesses).find { |round| !round.completed? } || create_next_round
  end

  private

  def create_first_round
    create_next_round
  end

  def create_next_round
    headline = Headline.order("RANDOM()").first
    rounds.create!(headline: headline)
  end
end
