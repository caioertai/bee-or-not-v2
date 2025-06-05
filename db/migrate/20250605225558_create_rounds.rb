class CreateRounds < ActiveRecord::Migration[8.0]
  def change
    create_table :rounds do |t|
      t.references :game, null: false, foreign_key: true
      t.references :headline, null: false, foreign_key: true
      t.string :user_guess, null: false
      t.boolean :correct, null: false

      t.timestamps
    end

    add_index :rounds, [ :game_id, :created_at ]
  end
end
