class RemoveGuessFieldsFromRounds < ActiveRecord::Migration[8.0]
  def change
    remove_column :rounds, :user_guess, :string
    remove_column :rounds, :correct, :boolean
  end
end
