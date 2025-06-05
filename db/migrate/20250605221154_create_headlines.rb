class CreateHeadlines < ActiveRecord::Migration[8.0]
  def change
    create_table :headlines do |t|
      t.string :content, null: false
      t.boolean :real, null: false

      t.timestamps
    end

    add_index :headlines, :real
  end
end
