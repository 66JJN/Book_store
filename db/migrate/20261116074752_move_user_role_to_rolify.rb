# Copies the old users.role enum ("admin" / "user") into Rolify roles, then drops the column.
# "user" becomes the "reader" role.
class MoveUserRoleToRolify < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      INSERT INTO roles (name, created_at, updated_at)
      VALUES ('admin', NOW(), NOW()), ('reader', NOW(), NOW())
    SQL

    execute <<~SQL
      INSERT INTO users_roles (user_id, role_id)
      SELECT users.id, roles.id
      FROM users
      JOIN roles ON roles.resource_type IS NULL
        AND roles.name = CASE users.role WHEN 'admin' THEN 'admin' ELSE 'reader' END
    SQL

    remove_column :users, :role
  end

  def down
    add_column :users, :role, :string, null: false, default: "user"

    execute <<~SQL
      UPDATE users SET role = 'admin'
      WHERE id IN (
        SELECT users_roles.user_id FROM users_roles
        JOIN roles ON roles.id = users_roles.role_id
        WHERE roles.name = 'admin' AND roles.resource_type IS NULL
      )
    SQL

    execute "DELETE FROM users_roles"
    execute "DELETE FROM roles WHERE name IN ('admin', 'reader') AND resource_type IS NULL"
  end
end
