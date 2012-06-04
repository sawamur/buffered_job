require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BufferedJob" do

  it "can buffer jobs" do
    user = nil
    BufferedJob.buf(:user_id => 1,
                    :category => "foo",
                    :receiver => user)
    BufferedJob.count.should == 1
  end
end
