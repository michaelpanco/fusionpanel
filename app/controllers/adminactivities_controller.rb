class AdminactivitiesController < ApplicationController

  layout :set_layout
  before_action :require_login, :check_admin_slug
  def index

    @admin_slug = admin_backend_slug
    @my_permissions = my_permissions

    if my_permissions.include?("can_view_pages")
      page = params[:page]
      search_query = params[:category_name]
      @record_count = Activity.count
      @search_keyword = search_query

      if params.has_key?(:category_name)
        @adminactivity = Activity.search(search_query)
      else
        @adminactivity = Activity.page(page).per(15)
      end

      if @adminactivity.class == Array
        @adminactivity = Activity.paginate_array(@adminactivity).page(page).per(15)
      else
        @adminactivity = @adminactivity.page(page).per(15)
      end

      render 'admin/adminactivities/index'

    else
      render 'admin/restricted'
    end
  end

end