class AddSourceUrlToHeadlines < ActiveRecord::Migration[8.0]
  def change
    add_column :headlines, :source_url, :string
  end
end
