class Round < ApplicationRecord
  belongs_to :game
  belongs_to :headline
  has_many :guesses, dependent: :destroy

  def current_guess
    guesses.last
  end

  def completed?
    guesses.any?
  end

  def correct?
    current_guess&.correct?
  end
end
