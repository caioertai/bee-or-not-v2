class AddSourceToHeadlines < ActiveRecord::Migration[8.0]
  def up
    add_reference :headlines, :source, null: true, foreign_key: true
    
    # Create default sources for existing headlines
    default_real_source = Source.create!(
      base_url: 'https://reuters.com',
      slug: 'reuters',
      name: 'Reuters',
      real: true
    )
    
    default_fake_source = Source.create!(
      base_url: 'https://babylonbee.com',
      slug: 'babylon-bee',
      name: 'The Babylon Bee',
      real: false
    )
    
    # Update existing headlines with appropriate sources
    Headline.where(real: true).update_all(source_id: default_real_source.id)
    Headline.where(real: false).update_all(source_id: default_fake_source.id)
    
    # Now make the column non-nullable
    change_column_null :headlines, :source_id, false
  end

  def down
    remove_reference :headlines, :source, foreign_key: true
  end
end
