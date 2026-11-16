ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, role_ids: []

  includes :roles

  index do
    selectable_column
    id_column
    column :email
    column(:roles) { |user| user.roles.map(&:name).sort.join(", ") }
    column :created_at
    actions
  end

  # CSV export: list the safe columns explicitly so tokens never end up in a file
  csv do
    column :id
    column :email
    column(:roles) { |user| user.roles.map(&:name).sort.join(", ") }
    column :created_at
  end

  filter :email
  filter :roles, collection: -> { Role.order(:name) }
  filter :created_at

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :email
      f.input :password, hint: ("Leave blank to keep the current password" if f.object.persisted?)
      f.input :password_confirmation
      f.input :roles, as: :check_boxes, collection: Role.order(:name)
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row(:roles) { |user| user.roles.map(&:name).sort.join(", ") }
      row :remember_created_at
      row :reset_password_sent_at
      row :created_at
      row :updated_at
    end
  end

  controller do
    # Allow editing a user without retyping the password every time
    def update
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      # An admin must not untick their own admin role and lock themselves out of /admin
      if resource == current_user && params[:user].key?(:role_ids) && !keeps_admin_role?
        return redirect_to edit_admin_user_path(resource), alert: "You cannot remove your own admin role."
      end

      super
    end

    private

    def keeps_admin_role?
      Role.where(id: Array(params[:user][:role_ids]).compact_blank, name: "admin", resource_type: nil).exists?
    end
  end
end
