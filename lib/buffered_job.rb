
require 'active_support'
require 'active_record'
require 'action_mailer'

require 'buffered_job/main'
require 'buffered_job/ext'

require 'delayed_job_active_record'


ActiveRecord::Base.send(:include,BufferedJob::Ext)
ActionMailer::Base.send(:extend,BufferedJob::Ext)
