module BufferedJob
  class Proxy
    def initialize(receiver,user,opt={})
      @receiver = receiver
      @user = user
      @opt = opt
    end
    
    def method_missing(method,target)
      cat =  @opt[:category] 
      cat ||= ( @receiver.class == Class ? @receiver.to_s : @receiver.class.to_s) + '#' + method.to_s
      merge_method = @opt[:action] || "merge_#{method}".to_sym
      BufferedJob::Model.create(:user_id => @user.id,
                             :category => cat,
                             :receiver => @receiver,
                             :method => method.to_sym,
                             :merge_method => merge_method,
                             :target => target)
    end
  end
end
