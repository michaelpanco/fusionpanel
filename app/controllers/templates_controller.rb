class TemplatesController < ApplicationController

	layout :set_layout
	before_action :require_login, :check_admin_slug
	
	def index
		@my_permissions = my_permissions
		@admin_slug = admin_backend_slug
		if my_permissions.include?("can_view_templates")
			page = params[:page]
			search_query = params[:search]
			@record_count = Template.count
			@search_keyword = search_query

			if params.has_key?(:search)
				@templates = Template.search(search_query)
			else
				@templates = Template.page(page).per(15)
			end

			if @templates.class == Array
				@templates = Template.paginate_array(@templates).page(page).per(15)
			else
				@templates = @templates.page(page).per(15)
			end

			render 'admin/templates/index'
		else
			render 'admin/restricted'
		end
	end

	def add
		@my_permissions = my_permissions

		if my_permissions.include?("can_modify_templates")

			# Set empty default in all inputs
			@params_template_name = ""
			@params_template_content = ""

			render 'admin/templates/add'
		else
			render 'admin/restricted'
		end

	end

	def create
		@my_permissions = my_permissions
		if my_permissions.include?("can_modify_templates")
			file_content = params[:filetemplatecontent]
			@template = Template.new(post_template_params)
			@template.location = "templates/" + format_string(@template.name)
			@template.save
			if @template.errors.any?
				flash.now[:error] = @template.errors.full_messages
				@params_template_name = @template.name
				@params_template_content = file_content
				render 'admin/templates/add'
			else
				begin
					File.open('app/views/templates/' + format_string(@template.name) + '.html.erb', 'w+') do |f2|
						f2.puts file_content
					end
					log_user_activities 'create_template', 'created <strong>' + params[:template]["name"] + '</strong> template'
					flash[:notice] = "<strong>Template Added!</strong> You've successfully created \"" + @template.name + "\"."
					redirect_to admin_template_path
				rescue
					flash[:error] = ["Error saving template. Please try again."]
					Template.destroy_all(:name => @template.name)
					redirect_to admin_template_path
				end

			end
		else
			render 'admin/restricted'
		end
	end

	def edit
		@my_permissions = my_permissions
		if my_permissions.include?("can_view_templates")
			@template = Template.find(params[:id])

			template_line_code = ""

			File.open("app/views/" + @template.location + ".html.erb" , "r") do |f|
				f.each_line do |line|
					template_line_code += line
				end
			end

			@template_content =  template_line_code.html_safe

			render 'admin/templates/edit'
		else
			render 'admin/restricted'
		end
	end

	def update
		@my_permissions = my_permissions
		if my_permissions.include?("can_modify_templates")
			@template = Template.find(params[:id])
			template_content = params[:templatecontent]
			current_template_location = @template.location
			template_location = "templates/" + format_string(params[:templatename])

			if @template.update(:name=>params[:templatename], :location=>template_location)
				File.rename("app/views/"+current_template_location+".html.erb", "app/views/"+template_location+".html.erb")

				begin
					File.open("app/views/"+template_location+".html.erb", "w") do |f2|
						f2.puts template_content
					end
					log_user_activities 'update_template', 'updated <strong>' + params[:templatename] + '</strong> template'
					flash[:notice] = "<strong>Template Updated!</strong> You've successfully updated \"" + @template.name + "\"."
					redirect_to admin_edit_template_path(:id=>params[:id])
				rescue
					flash[:notice] = "Error saving template. Please try again later."
					redirect_to admin_edit_template_path(:id=>params[:id])
				end

			else
				flash.now[:error] = @template.errors.full_messages
				render 'admin/templates/edit'
			end
		else
			render 'admin/restricted'
		end
	end

	def delete
		#@my_permissions = my_permissions
		#params[:template_ids].each do |id|
		#  File.delete('app/views/' + template_location(id) + '.html.erb')
		#end

		#Template.destroy_all(:id => params[:template_ids])

		#redirect_to admin_template_path

		@my_permissions = my_permissions
		if my_permissions.include?("can_modify_templates")
			if can_delete_template(params[:template_ids])
				params[:template_ids].each do |id|
					File.delete('app/views/' + template_location(id) + '.html.erb')
				end

				params[:template_ids].each do |item_id|
					template_title = Template.find_by_id(item_id).name
					Template.destroy(item_id)
					log_user_activities 'delete_template', 'deleted <strong>' + template_title + '</strong> template'
				end

			else
				flash[:error] = ["Delete Failed! Some Template may have contain an active pages."]
			end
			redirect_to admin_template_path
		else
			render 'admin/restricted'
		end
	end

	private

	def template_location template_id
		template = Template.find(template_id)
		return template.location
	end

	def format_string name
		return name.gsub(/[^a-zA-Z 0-9]/, "").gsub(/\s/,'_').downcase
	end

	def post_template_params
		params.require(:template).permit(:name)
	end

	def can_delete_template(template_ids)
		template_ids.each do |id|
			template = Template.find(id)
			if template.page.present?
			return false
			end
		end

		return true
	end

end