# frozen_string_literal: true

module ActiveAdmin
  # Default policy for the /admin area: admins can do everything, everyone else nothing.
  # Kept separate from the public policies so a reader can never reach /admin/books just
  # because BookPolicy#index? lets them browse books.
  class ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index? = admin?
    def show? = admin?
    def new? = admin?
    def create? = admin?
    def edit? = admin?
    def update? = admin?
    def destroy? = admin?
    def destroy_all? = admin? # batch action "Delete Selected"

    private

    def admin?
      user&.admin? || false
    end

    class Scope
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        @user&.admin? ? @scope.all : @scope.none
      end
    end
  end
end
