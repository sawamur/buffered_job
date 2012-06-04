class BufferedJob
  module Ext
    def buffer_for(user,opt={})
      Proxy.new(self,user,opt)
    end

    def buffer(opt={})
      raise NoBufferTargetError unless self.respond_to?(:id)
      buffer_for(self,opt)
    end
  end

  class NoBufferTargetError < StandardError
  end
end
