class AssetsController < ApplicationController

  #layout "fusionpanel/fusionpanel", :only => [ :index ]
  layout :set_layout
  before_action :require_login, :check_admin_slug
  require 'fileutils'

  def index
    @my_permissions = my_permissions
    @admin_slug = admin_backend_slug
    if my_permissions.include?("can_view_assets")
      render 'admin/assets/index'
    else
      render 'admin/restricted', :status => 403
    end
  end

  def file_writer
    @admin_slug = admin_backend_slug
    @my_permissions = my_permissions
    @file_editable = ['x-ruby','html','css', 'javascript']
    if params.has_key?(:file_id)
      file_id = params[:file_id]
    else
    file_id = 0
    end

    @parent_id = file_id

    @folder_list= Asset.where(parent: file_id).order('file_type ASC')
    @bread_crumbs = get_bread_crumbs(file_id)

    render inline:
    '
    <ul class="breadcrumb"><%= @bread_crumbs  %></ul>
    <div class="clear"></div>
    <% if @folder_list.empty? %>
    <p>No file or folder Available</p>
    <% end %>
    <% @folder_list.each do |file| %>
    <div class="fileitem">
        <% file_type = file.file_type.split("/").first %>
        <% file_type_ext = file.file_type.split("/").last %>
        <% if file_type == "appfolder"  %>
        <img src="<%= root_url %>images/folder.png" width="60" file-directory file-id="<%= file.id %>" />
        <% elsif file_type == "image"  %>
        <a class="fancybox" href="<%= root_url + "assets" + file.location %>">
        <img src="<%= root_url + "assets" + file.location %>" style="width:60px;height:60px"  />
        </a>
        <% else %>
          <%
          case file_type_ext
          when "x-ruby"
            file_icon = "ruby_file"
          when "html"
            file_icon = "html_file"
          when "css"
            file_icon = "css_file"
          when "javascript"
            file_icon = "js_file"
          else
            file_icon = "default"
          end
          %>
          <% if @file_editable.include?(file_type_ext) %>
            <a href="#fileStatePrompt" ng-click="setFileID(<%= file.id.to_s  %>)" data-toggle="modal"><img src="<%= root_url %>images/file_icon/<%= file_icon %>.png" /></a>
          <% else %>
            <a href="<%= root_url + @admin_slug + "/assets/download/" + file.id.to_s %>"><img src="<%= root_url %>images/file_icon/default.png" /></a>
          <% end %>
          
        <% end %>
        <% if @my_permissions.include?("can_modify_assets") %>
          <div class="dirname">
          <label class="checkbox">
          <% dots = (file.name.length >= 10 )? "..." : "" %>
          <input type="checkbox" ng-model="file<%= file.id %>" ng-change="addremove(file<%= file.id %>,\'<%= file.id %>\')" class="dir_check" >
          <span title="<%= file.name %>"><%= file.name[0,9] + dots %></span>
          </label>
          </div>
        <% else %>
          <div class="dirname">
          <% dots = (file.name.length >= 10 )? "..." : "" %>
          <span title="<%= file.name %>"><%= file.name[0,9] + dots %></span>
          </div>
        <% end %>
    </div>
    <% end %>
    
    <div id="fileStatePrompt" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
        <h3 id="modal-header">Select File Action</h3>
      </div>
      <div class="modal-body">
        <div>
          <a href="<%= root_url + @admin_slug + "/assets/edit/{{fileID}}" %>" class="btn btn-large mb10">Edit File</a>
          <a href="<%= root_url + @admin_slug + "/assets/download/{{fileID}}" %>" class="btn btn-large">Download File</a>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-large" data-dismiss="modal" aria-hidden="true">Cancel</button>
      </div>
    </div>
    
    <div class="fileitem file-new" ng-show="showDirectoryMaker">
        <img src="<%= root_url %>images/folder.png" width="60" file-directory file-id="45" />
        <div class="dirname">
            <%= form_tag(admin_assets_create_dir_path, method: "post") do %>
              <%= hidden_field_tag "parent", @parent_id %>
              <%= text_field_tag "name", nil, :style => "width:75px;height:11px", :placeholder => "New Folder" %>
            <% end %>
        </div>
    </div>
    <div class="clear"></div>

    <div id="asset-upload" class="row-fluid">
      <% if @my_permissions.include?("can_modify_assets") %>
      <div class="span3">
        <%= form_tag(admin_asset_delete_path, method: "post", id: "deletefilefolder") do %>
          <input type="hidden" name="parent" value="<%= @parent_id %>" />
          <ul style="display:none">
          <li ng-repeat="file in filefolders"><input name="file_folders[]" type="checkbox" value="{{file}}" checked></li>
          </ul>
          <input type="button" ng-click="submitform()" ng-show=\'filefolders.length > 0\' class="btn btn-danger mt10" value="Delete File/Directory">
        <% end %>
      </div>
      <% end %>
      <% if @my_permissions.include?("can_modify_assets") %>
      <div class="span9">
        <div class="pull-right">
          <%= form_tag(admin_assets_upload_path, method: "post",:multipart => true) do %>
            <input type="hidden" name="parent" value="<%= @parent_id %>" />
            <input type="file" name="file" class="filestyle" data-classButton="btn btn-primary">
            <input type="submit" class="btn" value="Upload">
          <% end %>
        </div>
      </div>
      <% end %>
    </div>

    <script data-turbolinks-track="true" src="/assets/bootstrap-filestyle.min.js?body=1"></script>
    '
  end

  def template_loader
    render inline: '<div class="slide-animate" ng-include="templateUrl" onload="loadMe()"></div>'
  end

  def upload
    @my_permissions = my_permissions

    if my_permissions.include?("can_modify_assets")
      uploaded_io = params[:file]
      if uploaded_io.nil?
        flash[:error] = ["File is empty, Please upload a file."]
        redirect_to admin_asset_path
      else
        @dir_request = Asset.new()
        @dir_request.name = uploaded_io.original_filename
        @dir_request.slug = uploaded_io.original_filename
        @dir_request.file_type = uploaded_io.content_type
        @dir_request.location = get_parent_location(params[:parent],uploaded_io.original_filename)
        @dir_request.owner = session[:user_id]
        @dir_request.parent = params[:parent]
        @dir_request.visibility = "public"
        @dir_request.save

        if @dir_request.errors.any?
          flash[:error] = @dir_request.errors.full_messages
          redirect_to admin_asset_path
        else

          File.open(Rails.root.join('public', 'assets'+save_to_parent(params[:parent]), uploaded_io.original_filename), 'wb') do |file|
            file.write(uploaded_io.read)
          end

          flash[:notice] = "<strong>File Added!</strong> You've successfully uploaded \"" + @dir_request.name + "\"."
          log_user_activities 'upload_file', 'uploaded <strong>' + uploaded_io.original_filename + '</strong>'
          if params[:parent]
            redirect_to admin_asset_path + "#/file_id/" + params[:parent]
          else
            redirect_to admin_asset_path
          end
        end
      end
    else
      flash[:error] = [User::PERMISSION_ERROR_MSG]
      if params[:parent]
        redirect_to admin_asset_path + "#/file_id/" + params[:parent]
      else
        redirect_to admin_asset_path
      end
    end

  end

  def edit_file
    @my_permissions = my_permissions
    @asset = Asset.find_by_id(params[:file_id])
    @file_id = @asset.id
    @file_name = @asset.name
    @file_location = @asset.location
    if @asset.file_type != 'application/x-ruby'
      @asset_file_type = @asset.file_type
    else
      @asset_file_type = 'ruby'
    end
    
    
    file_content_code = ""
    
    File.open("public/assets" + @asset.location, "r") do |f|
      f.each_line do |line|
        file_content_code += line
      end
    end
    @file_content = file_content_code
    render 'admin/assets/edit'
  end
  
  def update_file
    @my_permissions = my_permissions
    page_type = params[:pagetype]
    if my_permissions.include?("can_modify_assets")
      
      file_id = params[:file_id]
      file_original_name = params[:file_original_name]
      file_name = params[:file_name]
      file_location = params[:file_location]
      file_content = params[:file_content]
      file_path = File.dirname('public/assets' + file_location) + '/'
      
      begin
        File.open('public/assets' + file_location, 'w') do |f2|
          f2.puts file_content
        end
        File.rename('public/assets' + file_location, file_path + file_name)
        #Update DB record
        asset = Asset.find(params[:file_id])
        asset.name = file_name
        asset.slug = file_name
        original_path = File.dirname(file_location)
        if asset.parent == 0
          asset.location = original_path + file_name
        else
          asset.location = original_path + '/' + file_name
        end
        
        asset.save
        
        log_user_activities 'update_file', 'updated <strong>' + file_name + '</strong>'
        
        if file_original_name != file_name
          log_user_activities 'update_file', 'change <strong> filename from ' + file_original_name + ' to ' + file_name + '</strong>'
        end
          
        flash[:notice] = "File successfully updated"
        redirect_to admin_asset_edit_file_path(:file_id=>file_id)
      rescue
        flash[:notice] = "Error saving file. Please try again later."
        redirect_to admin_asset_path
      end
      
    else
      render 'admin/restricted'
    end
  end

  def download
    file_id = params[:file_id]
    file = Asset.find_by_id(file_id)
    send_data(root_url + 'assets' + file.location, :filename => file.name)
  end

  def delete
    @my_permissions = my_permissions

    if my_permissions.include?("can_modify_assets")
      params[:file_folders].reverse.each do |file_folder|
        file_info = get_file_info(file_folder)
        if file_info["type"] =="appfolder"
          FileUtils.rm_rf('public/assets' + file_info["location"])
        else
          File.delete('public/assets' + file_info["location"])
        end

      end
      #Asset.destroy_all(:id => params[:file_folders])
      #Asset.destroy_all(:parent => params[:file_folders])
      params[:file_folders].each do |file_id|
        asset_name = Asset.find_by_id(file_id).name
        Asset.destroy(file_id)
        log_user_activities 'delete_assets', 'deleted <strong>' + asset_name + '</strong>'
      end

      params[:file_folders].each do |file_id|
        find_parent = Asset.find_by_parent(file_id)
        if find_parent
          asset_name = find_parent.name
          Asset.find_by_parent(file_id).destroy
          log_user_activities 'delete_assets', 'deleted <strong>' + asset_name + '</strong>'
        end
      end

      flash[:notice] = "File/Folder deleted successfully."
    else
      flash[:error] = [User::PERMISSION_ERROR_MSG]
    end

    if params[:parent]
      redirect_to admin_asset_path + "#/file_id/" + params[:parent]
    else
      redirect_to admin_asset_path
    end

  end

  def create_dir
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_assets")
      @dir_request = Asset.new()
      @dir_request.name = params[:name].gsub(/[^a-zA-Z 0-9]/, "")
      @dir_request.slug = format_string(params[:name])
      @dir_request.file_type = "appfolder"
      @dir_request.location = get_parent_location(params[:parent],format_string(params[:name]))
      @dir_request.owner = session[:user_id]
      @dir_request.parent = params[:parent]
      @dir_request.visibility = "public"
      @dir_request.save

      if @dir_request.errors.any?
        flash[:error] = @dir_request.errors.full_messages
        redirect_to admin_asset_path
      else
        FileUtils::mkdir_p 'public/assets/' + get_parent_location(params[:parent],format_string(params[:name]))
        flash[:notice] = "<strong>Directory Added!</strong> You've successfully created \"" + @dir_request.name + "\"."
        log_user_activities 'create_directory', 'added directory <strong>' + @dir_request.name + '</strong>'
        if params[:parent]
          redirect_to admin_asset_path + "#/file_id/" + params[:parent]
        else
          redirect_to admin_asset_path
        end
      end

    else
      flash[:error] = [User::PERMISSION_ERROR_MSG]
      redirect_to admin_asset_path
    end

  end

  def get_file_info file_id
    filefolder = Asset.find(file_id)
    file_info = Hash.new
    file_info["type"] = filefolder.file_type
    file_info["location"] = filefolder.location

    return file_info
  end

  def get_parent_location file_id, file_slug

    if file_id.to_s == "0"
      parent_location = ""
    else
      folder_parent = Asset.find_by_id(file_id)
    parent_location = folder_parent.location
    end
    file_location = parent_location  + "/" + file_slug
    return file_location

  end

  def save_to_parent file_id

    if file_id.to_s == "0"
      parent_location = ""
    else
      folder_parent = Asset.find_by_id(file_id)
    parent_location = folder_parent.location
    end

    return parent_location

  end

  def get_bread_crumbs file_id

    admin_base_category_url = root_url + admin_backend_slug + '/assets'

    if file_id == '0'
      location = 'assets'
    else
      folders = Asset.find_by_id(file_id)
      location = 'assets' + folders.location
    end

    each_location = location.split('/')

    bread_crumbs = '<li><i class="icon-picture"></i> <a href="'+admin_base_category_url+'#/">Assets</a></li>'

    for i in (1..each_location.count - 2)
      bread_crumbs += '<li><span class="divider">/</span><a href="'+admin_base_category_url+'#/file_id/'+get_id(each_location[i]).to_s+'">' + each_location[i].capitalize + '</a></li>'
    end

    if each_location.count > 1
      bread_crumbs += '<li class="active"><span class="divider">/</span>' + each_location.last.capitalize + '</li>'
    end

    return bread_crumbs.html_safe

  end

  def get_id slug
    folder_parent = Asset.find_by_slug(slug)
    return folder_parent.id
  end

  def format_string name
    return name.gsub(/[^a-zA-Z 0-9]/, "").gsub(/\s/,'_').downcase
  end

end