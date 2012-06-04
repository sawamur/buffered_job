
require 'active_support'
require 'active_record'
require 'action_mailer'

require 'buffered_job/model'
require 'buffered_job/proxy'
require 'buffered_job/ext'

require 'delayed_job_active_record'


ActiveRecord::Base.send(:include,BufferedJob::Ext)
ActionMailer::Base.send(:extend,BufferedJob::Ext)

module BufferedJob
  class << self
    DEFAULT_DELAY_TIME = 3.minutes
    @@delay_time = DEFAULT_DELAY_TIME

    def flush!
      BufferedJob::Model.flush!
    end

    def delay_time=(sec)
      @@delay_time = sec
    end

    def delay_time
      @@delay_time
    end
    
    def reset_delay_time
      @@delay_time = DEFAULT_DELAY_TIME
    end
  end
end
