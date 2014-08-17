class WebtrafficController < ApplicationController

  layout :set_layout
  before_action :require_login, :check_admin_slug

  def index
    @admin_slug = admin_backend_slug
    @my_permissions = my_permissions
    if my_permissions.include?("can_view_pages")
      page = params[:page]
      search_query = params[:category_name]
      @record_count = Traffic.count
     	 @search_keyword = search_query
      
      if params.has_key?(:category_name)
        @webtraffic = Traffic.search(search_query)
      else
        @webtraffic = Traffic.page(page).per(15)
      end
  
      if @webtraffic.class == Array
        @webtraffic = Traffic.paginate_array(@webtraffic).page(page).per(15) 
      else
        @webtraffic = @webtraffic.page(page).per(15)
      end
      
       unless @webtraffic.empty?
        @webtraffic_count = @webtraffic.first.id == 1 ? @webtraffic.count - 1 : @webtraffic.count
      end
      
      render 'admin/traffic/index'
      
    else
      render 'admin/restricted'
    end
  end
  
  def details
    @admin_slug = admin_backend_slug
    @my_permissions = my_permissions
    @back_url = request.env['HTTP_REFERER'].nil? ? admin_webtraffic_path : request.env['HTTP_REFERER']
    @visitor = Traffic.find_by_id(params[:id])
    
    if @visitor
      @ip_address = @visitor.ip
      @date_visited = @visitor.date_visited
      @browser = @visitor.browser
      render 'admin/traffic/details'
    else
      @title = "Visitor Details not found."
      @description = 'Unable to find visitor details. <a href="' + admin_webtraffic_path + '" >Back to Web Traffic</a>'
      @message = @description.html_safe
      render 'admin/extras/404_internal'
    end
  end
  
end