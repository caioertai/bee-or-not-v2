class CreateSources < ActiveRecord::Migration[8.0]
  def change
    create_table :sources do |t|
      t.string :base_url
      t.string :slug
      t.string :name
      t.boolean :real

      t.timestamps
    end
  end
end
