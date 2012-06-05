# -*- coding: utf-8 -*-

module BufferedJob
  class Model < ActiveRecord::Base
    self.table_name = 'buffered_jobs'
    before_create :yaml_dump
    after_create :set_delayed_job
    
    def self.mailer?(obj)
      obj.respond_to?(:superclass) and obj.superclass == ActionMailer::Base
    end
    
    def self.flush!
      return if Lock.locked?
      Lock.lock!
      jobs = self.all
      skip = []
      @last_results = []
      jobs.each do |j|
        if skip[j.id]
          j.destroy
          next 
        end
        cojobs = jobs.select{ |o| o.user_id == j.user_id and o.category == j.category }
        receiver = YAML.load(j.receiver)
        if cojobs.size > 1
          begin
            targets = cojobs.map{|c|
              YAML.load(c.target)
            }
            unless receiver.respond_to?(j.merge_method)
              raise NoMergeMethodError,"define #{j.merge_method}"
            end
            if mailer?(receiver)
              @last_results << receiver.send(j.merge_method,targets).deliver
            else
              @last_results << receiver.send(j.merge_method,targets)
            end
          rescue => er
            @last_results << er
          end
          cojobs.each do |c|
            skip[c.id] = true
          end
        else
          begin
            target = YAML.load(j.target)
            if mailer?(receiver)
              @last_results << receiver.send(j.method,target).deliver
            else
              @last_results << receiver.send(j.method,target)
            end
          rescue => er
            @last_results << er
          end
        end
        j.destroy
      end
      Lock.unlock!
    end
    
    def self.last_results
      @last_results or []
    end
    
    
    private
    def yaml_dump
      self.receiver = YAML.dump self.receiver
      self.target = YAML.dump self.target
    end

    def set_delayed_job
      delay_time = BufferedJob.delay_time
      self.class.delay(:run_at => delay_time.from_now).flush!
    end
  end
end








