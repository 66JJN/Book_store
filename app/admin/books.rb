ActiveAdmin.register Book do
  permit_params :title, :author, :isbn, :description, :price, :stock, :published_on,
                :cover_image_url, :category_id, market_ids: []

  includes :category, :markets # avoid N+1 queries on the index page

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :isbn
    column :category
    column(:price) { |book| number_to_currency(book.price) }
    column :stock
    column(:markets) { |book| book.markets.map(&:name).join(", ") }
    actions
  end

  filter :title
  filter :author
  filter :isbn
  filter :category, collection: -> { Category.order(:name) }
  filter :markets, collection: -> { Market.order(:name) }
  filter :price
  filter :stock
  filter :published_on

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :author
      f.input :isbn
      f.input :category, collection: Category.order(:name)
      f.input :price
      f.input :stock
      f.input :published_on, as: :string, input_html: { type: "date" } # v4 has no datepicker input
      f.input :cover_image_url
      f.input :description
      f.input :markets, as: :check_boxes, collection: Market.order(:name)
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :author
      row :isbn
      row :category
      row(:price) { |book| number_to_currency(book.price) }
      row :stock
      row :published_on
      row(:cover_image_url) { |book| image_tag(book.cover_image_url, class: "h-40") if book.cover_image_url.present? }
      row(:description) { |book| simple_format(book.description) }
      row(:markets) { |book| book.markets.map(&:name).join(", ") }
      row :created_at
      row :updated_at
    end
  end
end
