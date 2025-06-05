# Mock Round model using Data class for now
# Will be converted to ActiveRecord later
class Round < Data.define(:id, :game_id, :headline, :user_guess, :correct, :completed_at)
  def self.create_for_game(game_id)
    headline = Headline.order("RANDOM()").first
    raise "No headlines available" if headline.nil?

    new(
      id: SecureRandom.uuid,
      game_id: game_id,
      headline: headline,
      user_guess: nil,
      correct: nil,
      completed_at: nil
    )
  end

  def make_guess(guess)
    is_correct = (guess == "real" && headline.real?) || (guess == "fake" && headline.fake?)

    self.class.new(**to_h.merge(
      user_guess: guess,
      correct: is_correct,
      completed_at: Time.current
    ))
  end

  def completed?
    !completed_at.nil?
  end

  def guess_text
    user_guess&.capitalize
  end

  def result_text
    return "" unless completed?

    if correct
      "Correct! This headline was #{headline.real? ? 'real' : 'fake'}."
    else
      "Wrong! This headline was actually #{headline.real? ? 'real' : 'fake'}."
    end
  end

  def result_class
    return "" unless completed?

    correct ? "text-green-600" : "text-red-600"
  end
end
