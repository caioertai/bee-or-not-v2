class Round < ApplicationRecord
  belongs_to :game
  belongs_to :headline

  validates :user_guess, presence: true, inclusion: { in: %w[real fake] }
  validates :correct, inclusion: { in: [ true, false ] }, allow_nil: true

  scope :correct, -> { where(correct: true) }
  scope :incorrect, -> { where(correct: false) }

  before_save :calculate_correctness

  def guess_text
    user_guess&.capitalize
  end

  def result_text
    if correct?
      "Correct! This headline was #{headline.real? ? 'real' : 'fake'}."
    else
      "Wrong! This headline was actually #{headline.real? ? 'real' : 'fake'}."
    end
  end

  def result_class
    correct? ? "text-green-600" : "text-red-600"
  end

  private

  def calculate_correctness
    self.correct = (user_guess == "real" && headline.real?) ||
                   (user_guess == "fake" && headline.fake?)
  end
end
