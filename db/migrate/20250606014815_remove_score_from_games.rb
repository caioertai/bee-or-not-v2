class RemoveScoreFromGames < ActiveRecord::Migration[8.0]
  def change
    remove_column :games, :score, :integer
  end
end
