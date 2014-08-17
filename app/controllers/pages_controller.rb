class PagesController < ApplicationController
	include PageCategory

	layout :set_layout
	before_action :require_login, :check_admin_slug
	
	def index
		
		@admin_slug = admin_backend_slug
		@my_permissions = my_permissions
		
		if my_permissions.include?("can_view_pages")
			@categories = Category.all
			creators = Page.select(:created_by).distinct
			@creators = User.where(id: creators)
			page = params[:page]
			search_query = params[:search_title]
			@record_count = Page.count
			@search_keyword = search_query

			if params.has_key?(:search_title)
				else
				@pages = Page.page(page).per(15)
			end

			if params.has_key?(:category) || params.has_key?(:status) || params.has_key?(:creator)

				page_params = Hash.new
				page_params["category_id"] = params[:category] if params.has_key?(:category) && params[:category] != "all"
				page_params["status"] = params[:status] if params.has_key?(:status) && params[:status] != "all"
				page_params["created_by"] = params[:creator] if params.has_key?(:creator) && params[:creator] != "all"
				@pages = Page.where_value(page_params) if !page_params.empty?

				@cat_filter_value = params.has_key?(:category) && params[:category] != "all" ? Category.find_by_id(params[:category]).name  : "All Category"
				@stat_filter_value = params.has_key?(:status) && params[:status] != "all" ? params[:status].capitalize : "All Status"
				@creator_filter_value = params.has_key?(:creator) && params[:creator] != "all" ? User.find_by_id(params[:creator]).fullname : "All Creator"

			else
				@cat_filter_value = "All Category"
				@stat_filter_value = "All Status"
				@creator_filter_value = "All Creator"
			end

			if @pages.class == Array
				@pages = Page.paginate_array(@pages).page(page).per(15)
			else
				@pages = @pages.page(page).per(15)
			end
			render 'admin/pages/index'
		else
			render 'admin/restricted'
		end
	end

	def add
		@my_permissions = my_permissions
		if my_permissions.include?("can_modify_pages")
			@user = User

			# Set empty default in all inputs
			@params_content_title = ""
			@params_url_slug = ""
			@params_category = "No Category"
			@params_page_status = "Active"
			@params_template_id = ""
			@params_template_value = "Select Template"
			@params_page_content = ""
			@params_page_title = ""
			@params_page_description = ""
			@params_page_keywords = ""

			@templates = Template.all
			@categories = Category.where("slug != ?", "nocategory")
			render 'admin/pages/add'
		else
			render 'admin/restricted'
		end
	end

	def create
		@my_permissions = my_permissions
		if my_permissions.include?("can_modify_pages")
			@page = Page.new(post_page_params)
			@page.category_id = PageCategory.search_category_value(params[:page]["category_id"])
			@page.created_by = session[:user_id]
			@page.build_meta(post_meta_params)
			@page.save
			@categories = Category.where("id != ?", 1)

			if @page.errors.any?

				@defaultTemplateID = ""
				@defaultTemplateValue = 'Select Template'
				@templates = Template.all

				# Retain all the user input
				@params_content_title = @page.content_title
				@params_url_slug = @page.url_slug
				@params_category = params[:page]["category_id"]
				@params_page_status= @page.status.capitalize
				@params_template_id = @page.template_id
				@params_template_value = params[:template_value]
				@params_page_content = @page.content
				@params_page_title = @page.meta.page_title
				@params_page_description = @page.meta.page_description
				@params_page_keywords = @page.meta.page_keywords
				@params_page_no_index = @page.meta.no_index
				@params_page_no_follow = @page.meta.no_follow

				flash.now[:error] = @page.errors.full_messages
				render 'admin/pages/add'
			else
				flash[:notice] = "<strong>Page Added!</strong> You've successfully created \"" + @page.content_title + "\"."
				log_user_activities 'create_page', 'created <strong>' + params[:page]["content_title"] + '</strong> page'
				redirect_to admin_page_path
			end
		else
			render 'admin/restricted'
		end
	end

	def edit
		if my_permissions.include?("can_view_pages")
			@my_permissions = my_permissions
			@page = Page.find_by_id(params[:id])
			@templates = Template.all

			if @page
				if @page.category.present?
					@page_cat_name = @page.category.name
				else
					@page_cat_name = "No Category"
				end
				@categories = Category.where("id != ?", 1)
				render 'admin/pages/edit'
			else
				@title = "Page not found"
				@description = 'The page you requested does not exist. <a href="' + admin_page_path + '" >Back to Pages</a>'
				@message = @description.html_safe
				render 'admin/extras/404_internal'
			end
		else
			render 'admin/restricted'
		end
	end

	def update
		if my_permissions.include?("can_modify_pages")
			@page = Page.find(params[:id])
			params[:page]["category_id"] = PageCategory.search_category_value(params[:page]["category_id"])
			params[:page]["template_id"] = PageCategory.search_template_value(params[:page]["template_id"])
			@page.content_title = params[:page]["content_title"]
			@page.content  = params[:page]["content"]
			@page.url_slug  = params[:page]["url_slug"]
			@page.status  = params[:page]["status"]
			@page.category_id  = params[:page]["category_id"]
			@page.template_id  = params[:page]["template_id"]
			# Updatee Meta Attributes
			@page.meta.page_title  = params[:meta]["page_title"]
			@page.meta.page_description  = params[:meta]["page_description"]
			@page.meta.page_keywords  = params[:meta]["page_keywords"]
			@page.meta.no_index  = params[:meta]["no_index"]
			@page.meta.no_follow  = params[:meta]["no_follow"]
			if @page.save
				flash[:notice] = "<strong>Page Updated!</strong> You've successfully updated \"" + @page.content_title + "\"."
				log_user_activities 'update_page', 'updated <strong>' + params[:page]["content_title"] + '</strong> page'
				redirect_to admin_edit_page_path(:id=>params[:id])
			else
				flash.now[:error] = @page.errors.full_messages
				render 'admin/pages/edit'
			end
		else
			render 'admin/restricted'
		end
	end

	def quick_status_update
		@page = Page.find(params[:id]).reload
		if @page
			@page.status = params[:status]
			@page.save
			if @page.errors.any?
				response["code"] = 201
				response["message"] = @page.errors.full_messages[0]
			else
				flash[:notice] = "<strong>Category Added!</strong> You successfully create " + @page.name + "."
				response["code"] = 100
				response["message"] = "Success"
			end
			render json:response
		end
	end

	def delete
		if my_permissions.include?("can_modify_pages")
			params[:page_ids].each do |item_id|
				page_title = Page.find_by_id(item_id).content_title
				Page.destroy(item_id)
				Meta.destroy(item_id)
				log_user_activities 'delete_page', 'deleted <strong>' + page_title + '</strong> page'
			end
			redirect_to admin_page_path
		else
			render 'admin/restricted'
		end
	end

	private

	def post_page_params
		params.require(:page).permit(:content_title, :content, :url_slug, :status, :meta_id, :template_id)
	end

	def post_meta_params
		params.require(:meta).permit(:page_title, :page_description, :page_keywords, :no_index, :no_follow)
	end

end