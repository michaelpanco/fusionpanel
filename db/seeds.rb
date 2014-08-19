# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Add Default Category

category_data = {
  "No Category" => "nocategory",
	"Personal" => "personal", 
	"Business" => "business",
	"Marketing" => "marketing",
	"Reviews" => "reviews"

}

category_data.each do |category_name, category_slug|
  if category_slug == "nocategory"
    parent_cat = 0
  else
    parent_cat = 1
  end
  Category.create(name: category_name, slug: category_slug, parent_category: parent_cat)
end

# Add Default User Roles

admin_role = ""
Role::PERMISSIONS.each do |inputrole|
  admin_role += inputrole + ", "
end

user_role_data = {
	"Administrator" => admin_role, 
	"Publisher" => "can_view_article",
	"Editor" => "can_create_article",
	"Developer" => "can_create_category"
}

user_role_data.each do |role_title, role_permissions|
  Role.create(name: role_title, permissions: role_permissions, status: "active")
end

# Add initial account to the users table

user_email = "mhike_v2@yahoo.com";
user_username = "michaelpanco";
user_fullname = "Michael Panco";
user_role_id = "1";
user_crypted_password = "c4e1ynkwohl";
user_status = "active";

User.create(email: user_email, username: user_username, fullname: user_fullname, role_id: user_role_id, crypted_password: user_crypted_password, status: user_status)

# Add default template

template_name = "Default";
template_location = "templates/default";

Template.create(name: template_name, location: template_location)

# Initialize Admin Settings

admin_settings_values = {
  "admin_slug" => 'fp-admin', 
  "web_status" => "online",
  "company_name" => "",
  "admin_title" => "Fusionpanel Administrator",
  "homepage" => "",
  "generic_meta_description" => "",
  "generic_meta_keywords" => "",
  "smtp_address" => "",
  "smtp_port" => "",
  "smtp_domain" => "",
  "smtp_username" => "",
  "smtp_password" => ""

}

admin_settings_values.each do |option_name, option_value|
  Setting.create(setting_name: option_name, setting_value: option_value)
end

# Example updating all field

# Traffic.update_all("status = '200'")

require 'fileutils'

dir_path = 'app/views/templates'

FileUtils::mkdir_p dir_path

target_file  = "app/views/templates/default.html.erb"

File.open(target_file, "w+") do |f|
  f.puts '<!doctype html>'
  f.puts '<html lang="en">'
  f.puts '<head>'
	f.puts '<title><%= @page_title %></title>'
	f.puts '</head>'
	f.puts '<body>'
	f.puts '<h1><%= @content_title %></h1>'
	f.puts '<p><%= @content %></p>'
	f.puts '<body>'
	f.puts '</html>'
end


