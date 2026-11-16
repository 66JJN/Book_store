class User < ApplicationRecord
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLE_VALUES = %w[user admin].freeze

  # The JSON API and the Bruno collection still send and receive "email_address"
  alias_attribute :email_address, :email

  validates :role, inclusion: { in: ROLE_VALUES }, if: -> { @requested_role }

  after_create :assign_default_role
  after_save :apply_requested_role

  def admin?
    has_role?(:admin)
  end

  # The API keeps a single "role" field ("user" or "admin") on top of Rolify roles
  def role
    @requested_role || (admin? ? "admin" : "user")
  end

  def role=(value)
    @requested_role = value.to_s
  end

  # Never expose encrypted_password / reset_password_token to ActiveAdmin search
  def self.ransackable_attributes(_auth_object = nil)
    %w[email created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[roles]
  end

  private

  def assign_default_role
    add_role(:reader) if roles.blank?
  end

  def apply_requested_role
    return unless @requested_role

    @requested_role == "admin" ? add_role(:admin) : remove_role(:admin)
    @requested_role = nil
  end
end
