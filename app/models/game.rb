# Mock Game model using Data class for now
# Will be converted to ActiveRecord later
class Game < Data.define(:id, :score, :total_rounds, :created_at)
  def self.create
    new(
      id: SecureRandom.uuid,
      score: 0,
      total_rounds: 0,
      created_at: Time.current
    )
  end

  def self.find(id)
    # Mock find - would normally fetch from database
    # For now, create a game with some sample data
    new(
      id: id,
      score: session_data[:score] || 0,
      total_rounds: session_data[:total_rounds] || 0,
      created_at: Time.current
    )
  end

  def increment_score!
    self.class.new(**to_h.merge(score: score + 1))
  end

  def increment_rounds!
    self.class.new(**to_h.merge(total_rounds: total_rounds + 1))
  end

  def accuracy_percentage
    return 0 if total_rounds.zero?

    (score.to_f / total_rounds * 100).round(1)
  end

  private

  def self.session_data
    # This will be injected by controllers when we have session access
    {}
  end
end
