class BaseAdminController < ApplicationController
  layout "admin"
  include ApplicationHelper
  before_action :authenticate_user!
  before_action :admin_user
end
