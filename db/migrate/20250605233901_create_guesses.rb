class CreateGuesses < ActiveRecord::Migration[8.0]
  def change
    create_table :guesses do |t|
      t.references :round, null: false, foreign_key: true
      t.string :user_guess, null: false
      t.boolean :correct, null: false

      t.timestamps
    end

    add_index :guesses, [ :round_id, :created_at ]
  end
end
