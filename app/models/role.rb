class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional: true


  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  # Needed by the "Roles" filter on the ActiveAdmin users page
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
