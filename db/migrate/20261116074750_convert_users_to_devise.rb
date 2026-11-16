# Moves the Rails 8 built-in auth columns over to Devise without losing users.
# has_secure_password and Devise both store a bcrypt hash, so existing passwords keep working.
class ConvertUsersToDevise < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :email_address, :email
    rename_column :users, :password_digest, :encrypted_password
    change_column_default :users, :encrypted_password, from: nil, to: ""

    # Recoverable
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_index :users, :reset_password_token, unique: true

    # Rememberable
    add_column :users, :remember_created_at, :datetime
  end
end
