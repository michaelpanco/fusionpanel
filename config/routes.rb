Fusionpanel::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  root 'main#index'


  # User temporary control routes
  get 'adduser' => 'admin#add_user', as: :add_user
  post 'adduser' => 'admin#create_user', as: :create_user

  get ':mainslug' => 'main#router', as: 'admin'
  get ':mainslug/visitorinfo/:filter_type' => 'main#visitor_info', as: 'admin_visitor_info'
  get ':mainslug/login' => 'main#router', as: 'admin_index'
  post ':mainslug/login' => 'admin#login_connect', as: 'login_connect'
  get ':mainslug/logout' => 'admin#logout', as: 'admin_logout'
	get ':mainslug/resetpassword' => 'main#resetpassword', as: 'admin_resetpassword_user'
	post ':mainslug/resetpassword' => 'main#resetpassword_submit', as: 'admin_resetpassword_submit_user'
	
  # Pages
  get ':mainslug/pages' => 'pages#index', as: 'admin_page'
  get ':mainslug/pages/add' => 'pages#add', as: 'admin_add_page'
  post ':mainslug/pages/add' => 'pages#create', as: 'admin_create_page'
  get ':mainslug/pages/edit/:id' => 'pages#edit', as: 'admin_edit_page'
  post ':mainslug/pages/edit/:id' => 'pages#update', as: 'admin_update_page'
  post ':mainslug/pages/delete' => 'pages#delete', as: 'admin_delete_page'

  #Categories
  get ':mainslug/categories' => 'categories#index', as: 'admin_category'
  post ':mainslug/categories/add' => 'categories#create', as: 'admin_create_category'
  post ':mainslug/categories/delete' => 'categories#delete', as: 'admin_delete_category'
  get ':mainslug/categories/edit/:id' => 'categories#edit', as: 'admin_edit_category'
  post ':mainslug/categories/edit/:id' => 'categories#update', as: 'admin_update_category'

  #Users
  get ':mainslug/users' => 'users#index', as: 'admin_user'
  post ':mainslug/users/add' => 'users#add', as: 'admin_add_user'
  get ':mainslug/create-account/:token' => 'users#create_account', as: 'admin_createaccount_user'
  get ':mainslug/users/role' => 'users#role_index', as: 'admin_user_role'
  get ':mainslug/users/role/add' => 'users#add_role', as: 'admin_user_addrole'
  post ':mainslug/users/role/add' => 'users#create_role', as: 'admin_user_createrole'
  get ':mainslug/users/role/edit/:id' => 'users#edit_role', as: 'admin_user_editrole'
  post ':mainslug/users/role/edit/:id' => 'users#update_role', as: 'admin_user_updatetrole'
  post ':mainslug/users/role/delete' => 'users#delete_role', as: 'admin_delete_role'
  get ':mainslug/users/:username' => 'users#profile', as: 'admin_user_profile'
  post ':mainslug/create-account/:token' => 'users#create', as: 'admin_create_user'
  post ':mainslug/users/changerole' => 'users#changerole', as: 'admin_changerole_user'
  post ':mainslug/users/delete' => 'users#delete', as: 'admin_delete_user'
  post ':mainslug/users/changepassword' => 'users#changepassword', as: 'admin_changepassword_user'
  post ':mainslug/users/forgotpassword' => 'main#forgotpassword', as: 'admin_forgotpassword_user'
  
  #Widgets
  get ':mainslug/widgets' => 'widgets#index', as: 'admin_widget'
  get ':mainslug/widgets/add' => 'widgets#add', as: 'admin_add_widget'
  post ':mainslug/widgets/add' => 'widgets#create', as: 'admin_create_widget'
  post ':mainslug/widgets/delete' => 'widgets#delete', as: 'admin_delete_widget'
  get ':mainslug/widgets/edit/:id' => 'widgets#edit', as: 'admin_edit_widget'
  post ':mainslug/widgets/edit/:id' => 'widgets#update', as: 'admin_update_widget'

  #Assets
  get ':mainslug/assets' => 'assets#index', as: 'admin_asset'
  get ':mainslug/file_writer/:file_id' => 'assets#file_writer', as: 'admin_asset_filewriter'
  get ':mainslug/template_loader' => 'assets#template_loader', as: 'admin_asset_templateloader'
  post ':mainslug/assets/upload' => 'assets#upload', as: 'admin_assets_upload'
  post ':mainslug/assets/create_dir' => 'assets#create_dir', as: 'admin_assets_create_dir'
  get ':mainslug/assets/edit/:file_id' => 'assets#edit_file', as: 'admin_asset_edit_file'
  post ':mainslug/assets/edit/:file_id' => 'assets#update_file', as: 'admin_asset_update_file'
  get ':mainslug/assets/download/:file_id' => 'assets#download', as: 'admin_asset_download'
  post ':mainslug/assets/delete' => 'assets#delete', as: 'admin_asset_delete'

  #Settings
  get ':mainslug/settings' => 'settings#index', as: 'admin_setting'
  post ':mainslug/settings/update' => 'settings#update', as: 'admin_setting_update'
  post ':mainslug/settings/updatepage' => 'settings#updatepage', as: 'admin_setting_updatepage'
  post ':mainslug/settings/updatesmtp' => 'settings#update_smtp', as: 'admin_setting_updatesmtp'
  
  #Template
  get ':mainslug/templates' => 'templates#index', as: 'admin_template'
  get ':mainslug/templates/add' => 'templates#add', as: 'admin_add_template'
  post ':mainslug/templates/create' => 'templates#create', as: 'admin_create_template'
  post ':mainslug/templates/delete' => 'templates#delete', as: 'admin_delete_template'
  get ':mainslug/templates/edit/:id' => 'templates#edit', as: 'admin_edit_template'
  post ':mainslug/templates/edit/:id' => 'templates#update', as: 'admin_update_template'

  #Traffic
  get ':mainslug/webtraffic' => 'webtraffic#index', as: 'admin_webtraffic'
  get ':mainslug/webtraffic/:id' => 'webtraffic#details', as: 'admin_webtraffic_details'
  
  #AdminActivities
  get ':mainslug/adminactivities' => 'adminactivities#index', as: 'admin_adminactivities'
  
  #About
  get ':mainslug/about' => 'about#index', as: 'admin_about'
  
  # Frontpage routing
  get '*pagecats/:page' => 'frontpage#index', as: 'frontendpage'
  
# The priority is based upon order of creation: first created -> highest priority.
# See how all your routes lay out with "rake routes".

# You can have the root of your site routed with "root"
# root 'welcome#index'

# Example of regular route:
#   get 'products/:id' => 'catalog#view'

# Example of named route that can be invoked with purchase_url(id: product.id)
#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

# Example resource route (maps HTTP verbs to controller actions automatically):
#   resources :products

# Example resource route with options:
#   resources :products do
#     member do
#       get 'short'
#       post 'toggle'
#     end
#
#     asset do
#       get 'sold'
#     end
#   end

# Example resource route with sub-resources:
#   resources :products do
#     resources :comments, :sales
#     resource :seller
#   end

# Example resource route with more complex sub-resources:
#   resources :products do
#     resources :comments
#     resources :sales do
#       get 'recent', on: :asset
#     end
#   end

# Example resource route within a namespace:
#   namespace :admin do
#     # Directs /admin/products/* to Admin::ProductsController
#     # (app/controllers/admin/products_controller.rb)
#     resources :products
#   end
end
