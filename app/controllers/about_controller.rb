class AboutController < ApplicationController

  layout :set_layout
  before_action :require_login, :check_admin_slug
  
  def index
    @my_permissions = my_permissions
    @admin_slug = admin_backend_slug
    render 'admin/about/index'
  end
  
end