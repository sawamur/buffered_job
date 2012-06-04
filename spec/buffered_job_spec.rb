require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BufferedJob" do
  before do
    @john = User.create(:name => "john")
    @paul = User.create(:name => "paul")
    @george = User.create(:name => "george")
    @article = Article.create(:user => @john,:text => "foo")
    BufferedJob::Spec.result = []
    BufferedJob::Model.destroy_all
  end

  after do
  end

  it "can buffer jobs" do
    comment = @article.comments.create(:user => @paul,:text => "I love this!")
    @john.buffer.notify(comment)
    BufferedJob::Model.last.user_id.should == @john.id
    BufferedJob::Model.last.receiver.should == YAML.dump(@john)
  end

  it "can exec one job " do
    comment = @article.comments.create(:user => @paul,:text => "I love this!")
    @john.buffer.notify(comment)
    BufferedJob.flush!
    BufferedJob::Spec.result.should == comment
  end

  it "can exec merge method with a array of target objects " do
    c1 = @article.comments.create(:user => @paul,:text => "I love this!")
    @john.buffer.notify(c1)
    c2 = @article.comments.create(:user => @george,:text => "I hate this!")
    @john.buffer.notify(c2)
    BufferedJob.flush!
    BufferedJob::Spec.result.should == [c1,c2]
  end

  context "with delayed_job" do
    before do
      @original_delay_time = BufferedJob.delay_time
      BufferedJob.delay_time = 0
    end

    after do
      BufferedJob.delay_time = @original_delay_time 
    end

    it "should be flushed by Delayed::Worker" do
      c1 = @article.comments.create(:user => @paul,:text => "I love this!")
      @john.buffer.notify(c1)
      c2 = @article.comments.create(:user => @george,:text => "I hate this!")
      @john.buffer.notify(c2)
      Delayed::Worker.new.work_off
      BufferedJob::Spec.result.should == [c1,c2]
    end
  end
end
