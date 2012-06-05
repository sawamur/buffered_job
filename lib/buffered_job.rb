
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

    def last_results
      BufferedJob::Model.last_results
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

    def unlock!
      Lock.unlock!
    end
  end

  class Lock
    def self.cache
      @@cache ||= defined?(Rails) ? Rails.cache : ActiveSupport::Cache::MemoryStore.new
    end
    
    def self.lock!
      cache.write("mail_buffer_lock",true,:expires_in => 10.minutes)
    end
    
    def self.unlock!
      cache.delete("mail_buffer_lock")
    end
    
    def self.locked?
      cache.exist?("mail_buffer_lock")
    end
  end

  class NoBufferTargetError < StandardError
  end

  class NoBufferKeywordError < StandardError
  end

  class NoMergeMethodError < StandardError
  end
end
