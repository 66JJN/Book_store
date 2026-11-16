# frozen_string_literal: true

# Shared rules for the catalog (books, categories, markets):
# anyone (guests too) can browse, only admins can change anything.
# The JSON API still requires a login before it even gets here (Api::BaseController).
class CatalogPolicy < ApplicationPolicy
  def index? = true
  def show? = true
  def create? = admin?
  def update? = admin?
  def destroy? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
