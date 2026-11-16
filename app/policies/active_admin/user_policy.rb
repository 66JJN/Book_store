# frozen_string_literal: true

module ActiveAdmin
  class UserPolicy < ApplicationPolicy
    # An admin must not delete their own account
    def destroy? = admin? && record != user
  end
end
