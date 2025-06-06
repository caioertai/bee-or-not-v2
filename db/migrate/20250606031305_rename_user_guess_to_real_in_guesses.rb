class RenameUserGuessToRealInGuesses < ActiveRecord::Migration[8.0]
  def up
    # Add new boolean column
    add_column :guesses, :real_boolean, :boolean

    # Convert data: "real" -> true, "fake" -> false
    execute <<-SQL
      UPDATE guesses#{' '}
      SET real_boolean = CASE WHEN user_guess = 'real' THEN 1 ELSE 0 END
    SQL

    # Drop old column and rename new one
    remove_column :guesses, :user_guess
    rename_column :guesses, :real_boolean, :real
  end

  def down
    # Add back string column
    add_column :guesses, :user_guess, :string

    # Convert data back: true -> "real", false -> "fake"
    execute <<-SQL
      UPDATE guesses#{' '}
      SET user_guess = CASE WHEN real = 1 THEN 'real' ELSE 'fake' END
    SQL

    # Drop boolean column
    remove_column :guesses, :real
  end
end
