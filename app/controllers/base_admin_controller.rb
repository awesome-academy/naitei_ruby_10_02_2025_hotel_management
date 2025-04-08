class BaseAdminController < ApplicationController
  layout "admin"
  include ApplicationHelper
  before_action :logged_in_user
  before_action :admin_user
end
