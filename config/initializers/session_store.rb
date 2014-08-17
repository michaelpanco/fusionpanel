# Be sure to restart your server when you modify this file.

#Fusionpanel::Application.config.session_store :cookie_store, key: '_fusionpanel_session'

Fusionpanel::Application.config.session_store :active_record_store, key: '_fusionpanel_session'#, expire_after: 10.second
ActionDispatch::Session::ActiveRecordStore.session_class = Session