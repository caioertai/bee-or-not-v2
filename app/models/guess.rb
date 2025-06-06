class Guess < ApplicationRecord
  belongs_to :round

  validates :user_guess, presence: true, inclusion: { in: %w[real fake] }

  def guess_text
    user_guess&.capitalize
  end

  def correct?
    (user_guess == "real" && round.headline.real?) ||
    (user_guess == "fake" && round.headline.fake?)
  end

  def result_text
    headline = round.headline
    if correct?
      "Correct! This headline was #{headline.real? ? 'real' : 'fake'}."
    else
      "Wrong! This headline was actually #{headline.real? ? 'real' : 'fake'}."
    end
  end

  def result_class
    correct? ? "text-green-600" : "text-red-600"
  end
end
