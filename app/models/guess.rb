class Guess < ApplicationRecord
  belongs_to :round

  validates :real, inclusion: { in: [ true, false ] }

  def guess_text
    real? ? "Real" : "Fake"
  end

  def correct?
    real == round.headline.real
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
