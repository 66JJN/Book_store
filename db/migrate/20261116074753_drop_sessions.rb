# Devise keeps the login in the Rails session cookie, so the old sessions table is no longer used.
class DropSessions < ActiveRecord::Migration[8.1]
  def change
    drop_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end
  end
end
