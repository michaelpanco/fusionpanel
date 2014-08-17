class SettingsController < ApplicationController

  layout :set_layout
  before_action :require_login, :check_admin_slug
  
  def index
    @my_permissions = my_permissions
    @admin_slug = admin_backend_slug
    if my_permissions.include?("can_view_settings")
      page404_line_code = ""
      pageOffline_line_code = ""
      
      File.open("public/404.html", "r") do |f|
        f.each_line do |line|
          page404_line_code += line
        end
      end
      
      File.open("public/offline.html", "r") do |f2|
        f2.each_line do |line2|
          pageOffline_line_code += line2
        end
      end
      
      @page404_content =  page404_line_code.html_safe
      @pageOffline_content =  pageOffline_line_code.html_safe
      @pages = Page.all
  
      #load admin settings
      admin_settings = Hash.new
      admin_settings["admin_slug"] = Setting.find_by_setting_name('admin_slug').setting_value
      admin_settings["web_status"] = Setting.find_by_setting_name('web_status').setting_value
      admin_settings["company_name"] = Setting.find_by_setting_name('company_name').setting_value
      admin_settings["admin_title"] = Setting.find_by_setting_name('admin_title').setting_value
      admin_settings["generic_meta_description"] = Setting.find_by_setting_name('generic_meta_description').setting_value
      admin_settings["generic_meta_keywords"] = Setting.find_by_setting_name('generic_meta_keywords').setting_value
      
      admin_settings["smtp_address"] = Setting.find_by_setting_name('smtp_address').setting_value
      admin_settings["smtp_port"] = Setting.find_by_setting_name('smtp_port').setting_value
      admin_settings["smtp_domain"] = Setting.find_by_setting_name('smtp_domain').setting_value
      admin_settings["smtp_username"] = Setting.find_by_setting_name('smtp_username').setting_value
      admin_settings["smtp_password"] = Setting.find_by_setting_name('smtp_password').setting_value
      
      homepage_setting_value = Setting.find_by_setting_name('homepage').setting_value
      admin_settings["homepage_id"] = !homepage_setting_value.empty? ? homepage_setting_value : nil
      
      if !page_exist? homepage_setting_value
      	admin_settings["homepage_id"] = nil
      end
      
      homepage_value = !admin_settings["homepage_id"].nil? ? Page.find(admin_settings["homepage_id"]).content_title : 'Please select page'
      admin_settings["homepage_value"] = homepage_value.length >= 25 ? homepage_value[0,25] + '...' : homepage_value
      @admin_settings = admin_settings
      session[:admin_title] = Setting.find_by_setting_name('admin_title').setting_value
      @ips = block_ips
      render 'admin/settings/index'
    else
      render 'admin/restricted'
    end
  end

  def update
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_settings")
      setting = {
        1 => { "setting_value" => params[:admin_slug] },
        2 => { "setting_value" => params[:web_status] },
        3 => { "setting_value" => params[:company_name] },
        4 => { "setting_value" => params[:admin_title] },
        5 => { "setting_value" => params[:homepage] },
        6 => { "setting_value" => params[:generic_meta_description] },
        7 => { "setting_value" => params[:generic_meta_keywords] },
      }
  
      additional_block_ip = params[:block_ips].split("\r\n") - block_ips
      deleted_block_ip = block_ips - params[:block_ips].split("\r\n")
  
      # Add block IP
  
      additional_block_ip.each do |new_ip|
        if new_ip != ""
          BlockIp.create(:ip => new_ip)
        end
      end
  
      # Remove block IP
  
      deleted_block_ip.each do |new_ip|
        BlockIp.where(:ip => new_ip).destroy_all
      end
  
      if Setting.update(setting.keys, setting.values)
        flash[:notice] = "Settings successfully updated!"
        session[:admin_slug] = params[:admin_slug]
        log_user_activities 'update_setting', 'updated <strong>Settings</strong>'
        redirect_to root_url + session[:admin_slug] + "/settings" #admin_setting_path
      else
        flash[:notice] = "<strong>Error Updating!</strong>"
        redirect_to admin_setting_path
      end
    else
      render 'admin/restricted'
    end

  end

  def updatepage
    @my_permissions = my_permissions
    page_type = params[:pagetype]
    if my_permissions.include?("can_modify_settings")
      if page_type == 'page404'
        page_document = '404.html'
      else
        page_document = 'offline.html'
      end
      
      page_content = params[:content]
      
      begin
        File.open('public/' + page_document, 'w') do |f2|
          f2.puts page_content
        end
        if page_type == 'page404'
          log_user_activities 'update_setting', 'updated <strong>404 page setting</strong>'
        else
          log_user_activities 'update_setting', 'updated <strong>Offline page setting</strong>'
        end
        flash[:notice] = page_document.capitalize + " page is successfully updated"
        redirect_to admin_setting_path
      rescue
        flash[:notice] = "Error saving page. Please try again later."
        redirect_to admin_setting_path
      end
    else
      render 'admin/restricted'
    end
  end

  def update_smtp
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_settings")
      response = Hash.new
      setting = {
         8 => { "setting_value" => params[:smtp_address] },
         9 => { "setting_value" => params[:smtp_port] },
        10 => { "setting_value" => params[:smtp_domain] },
        11 => { "setting_value" => params[:smtp_username] },
        12 => { "setting_value" => params[:smtp_password] },
      }
      
      if Setting.update(setting.keys, setting.values)
        flash[:notice] = "SMTP Settings successfully updated!"
        response["code"] = 100
        response["message"] = "Success"
      else
        response["code"] = 201
        response["message"] = "Error Updating SMTP. Please try again."
      end 

    else
        response["code"] = 201
        response["message"] = User::PERMISSION_ERROR_MSG
    end
    
    render json:response

  end

  def block_ips
    ips = BlockIp.all
    ips_arr = []
    ips.each do |block_ip|
      ips_arr.push(block_ip.ip)
    end
    return ips_arr
  end
end