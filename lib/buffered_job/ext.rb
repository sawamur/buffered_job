module BufferedJob
  module Ext
    def buffer_for(user,key=nil,opt={})
      Proxy.new(self,user,key,opt)
    end

    def buffer(key=nil,opt={})
      if !self.respond_to?(:id) and self.superclass != ActionMailer::Base
        raise NoBufferTargetError 
      end
      if self.kind_of?(Class) and key.nil?
        raise NoBufferKeywordError,"Specify buffer keyword like YourMailer.buffer('send_to_user/123').notification(msg)"
      end
      buffer_for(self,key,opt)
    end
  end
end
