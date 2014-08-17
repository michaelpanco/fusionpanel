class Setting < ActiveRecord::Base
    validates :setting_name, presence: true, uniqueness: true
    SMTP_URL = 'Setting.find(1).setting_name'
end
