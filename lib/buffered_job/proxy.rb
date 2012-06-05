module BufferedJob
  class Proxy
    def initialize(receiver,user,key,opt={})
      @receiver = receiver
      @user = user
      @opt = opt
      @key = key
    end
    
    def method_missing(method,target)
      @key ||= ( @receiver.class == Class ? @receiver.to_s : @receiver.class.to_s) + '#' + method.to_s
      merge_method = @opt[:action] || "merge_#{method}".to_sym
      user_id = @user.respond_to?(:id) ? @user.id : 0
      BufferedJob::Model.create(:user_id => user_id,
                                :category => @key,
                                :receiver => @receiver,
                                :method => method.to_sym,
                                :merge_method => merge_method,
                                :target => target)
    end
  end
end
