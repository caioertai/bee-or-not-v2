class RemoveCorrectFromGuesses < ActiveRecord::Migration[8.0]
  def change
    remove_column :guesses, :correct, :boolean
  end
end
