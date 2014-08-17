class UserMailer < ActionMailer::Base
	
	default from: 'fp@michaelpanco.com'
	
	def send_user_invitation(email, link, role, inviter)
		UserMailer.smtp_settings = {
			:address              => Setting.find_by_setting_name('smtp_address').setting_value,
			:port                 => Setting.find_by_setting_name('smtp_port').setting_value, #465 , 587
			:domain               => Setting.find_by_setting_name('smtp_domain').setting_value,
			:user_name            => Setting.find_by_setting_name('smtp_username').setting_value,
			:password             => Setting.find_by_setting_name('smtp_password').setting_value,
			:authentication       => :plain,
			:enable_starttls_auto => true  }

		@inviter = inviter
		@create_link  = link
		@user_role = role
		mail(to: email, subject: 'I just invited you to fusionpanel')
	end

	def forgot_password(account_id, email, reset_password_token, base_url, admin_slug, company_name)
		
		UserMailer.smtp_settings = {
			:address              => Setting.find_by_setting_name('smtp_address').setting_value,
			:port                 => Setting.find_by_setting_name('smtp_port').setting_value, #465 , 587
			:domain               => Setting.find_by_setting_name('smtp_domain').setting_value,
			:user_name            => Setting.find_by_setting_name('smtp_username').setting_value,
			:password             => Setting.find_by_setting_name('smtp_password').setting_value,
			:authentication       => :plain,
			:enable_starttls_auto => true  }

		@account_id = account_id
		@reset_password_token = reset_password_token
		@base_url = base_url
		@admin_slug = admin_slug
		@company_name = company_name
		
		mail(to: email, subject: 'Fusionpanel - Reset Password')
	end

end