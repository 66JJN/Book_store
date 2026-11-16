ActiveAdmin.register Category do
  permit_params :name

  includes :books

  index do
    selectable_column
    id_column
    column :name
    column(:books) { |category| category.books.size }
    column :created_at
    actions
  end

  filter :name
  filter :created_at

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
    end

    panel "Books" do
      table_for category.books.order(:title) do
        column(:title) { |book| link_to book.title, admin_book_path(book) }
        column :author
      end
    end
  end

  controller do
    # A category that still has books cannot be deleted (dependent: :restrict_with_error), so show why
    def destroy
      if resource.destroy
        redirect_to collection_path, notice: "Category was successfully deleted.", status: :see_other
      else
        redirect_to collection_path, alert: resource.errors.full_messages.to_sentence, status: :see_other
      end
    end
  end
end
