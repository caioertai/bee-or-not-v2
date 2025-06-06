class UpdateSourceUrlConstraint < ActiveRecord::Migration[8.0]
  def up
    # Update any headlines that don't have source_url set
    Headline.includes(:source).where(source_url: [ nil, "" ]).find_each do |headline|
      if headline.source_url.blank?
        headline.update_column(:source_url, headline.source.base_url)
      end
    end

    # Add NOT NULL constraint
    change_column_null :headlines, :source_url, false
  end

  def down
    change_column_null :headlines, :source_url, true
  end
end
