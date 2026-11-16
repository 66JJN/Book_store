# frozen_string_literal: true

# Managing users (JSON API) is admin-only
class UserPolicy < ApplicationPolicy
  def index? = admin?
  def show? = admin?
  def create? = admin?
  def update? = admin?

  # An admin must not delete their own account
  def destroy? = admin? && record != user
end
