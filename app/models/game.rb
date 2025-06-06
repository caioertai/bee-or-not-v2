class Game < ApplicationRecord
  has_many :rounds, dependent: :destroy
  has_many :guesses, through: :rounds
  has_one :current_round, -> { where.missing(:guesses).order(:created_at) }, class_name: "Round", inverse_of: :game

  def total_rounds
    rounds.joins(:guesses).distinct.count
  end

  def correct_rounds
    rounds.joins(guesses: { round: :headline })
          .where("guesses.real = headlines.real")
          .distinct.count
  end

  def score
    guesses.joins(round: :headline)
           .where("guesses.real = headlines.real")
           .count
  end

  def accuracy_ratio
    return 0 if total_rounds.zero?

    correct_rounds.to_f / total_rounds
  end

  def create_next_round!
    available_headline = available_headlines.order("RANDOM()").first
    return nil unless available_headline

    self.current_round = rounds.create!(headline: available_headline)
  end

  def completed?
    available_headlines.empty?
  end

  private

  def available_headlines
    used_headline_ids = rounds.pluck(:headline_id)
    Headline.where.not(id: used_headline_ids)
  end
end
