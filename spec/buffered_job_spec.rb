require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BufferedJob" do
  before do
    @john = User.create(:name => "john")
    @paul = User.create(:name => "paul")
    @george = User.create(:name => "george")
    @article = Article.create(:user => @john,:text => "foo")
    BufferedJob::Spec.results = []
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
    BufferedJob::Spec.results.last.should == comment
  end

  it "can exec merge method with a array of target objects " do
    c1 = @article.comments.create(:user => @paul,:text => "I love this!")
    @john.buffer.notify(c1)
    c2 = @article.comments.create(:user => @george,:text => "I hate this!")
    @john.buffer.notify(c2)

    c3 = @article.comments.create(:user => @ringo,:text => "I know this!")
    @paul.buffer.notify(c3)
    BufferedJob.flush!
    BufferedJob::Spec.results.should include([c1,c2])
    BufferedJob::Spec.results.should include(c3)
  end


  context "returing results" do
    it "should returns last results by BufferedJob.last_results" do
      @john.buffer.notify({:foo => "bar"})
      @paul.buffer.notify({:moo => "ooo"})
      BufferedJob.flush!
      BufferedJob.last_results.should == [1,1]
    end

    it "should contain NoMergeMethodError if the receiver doesn't have it" do
      @john.buffer.say("Yay!")
      @john.buffer.say("Hoo!")
      BufferedJob.flush!
      BufferedJob.last_results.last.should be_a_kind_of(BufferedJob::NoMergeMethodError)
    end
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
      BufferedJob::Spec.results.last.should == [c1,c2]
    end
  end


  context "with specific buffering keyword" do

    it "should count by the keyword given to buffer method" do
      c1 = @article.comments.create(:user => @paul,:text => "I love this!")
      @john.buffer("foo").notify(c1)
      c2 = @article.comments.create(:user => @george,:text => "I hate this!")
      @john.buffer("foo").notify(c2)
      c3 = @article.comments.create(:user => @george,:text => "I like this!")
      @john.buffer("foo").notify(c3)

      c4 = @article.comments.create(:user => @george,:text => "I know this!")
      @john.buffer("baa").notify(c4)
      BufferedJob.flush!
      BufferedJob::Spec.results.should include([c1,c2,c3])
      BufferedJob::Spec.results.should include(c4)
    end
  end


  context "ActionMailer" do
    before do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.deliveries = []
    end

    it "buffer sending method with ActionMailer class " do
      TestMailer.buffer("notification/foo@example.org").notification({:to => "foo@example.org"})
      ActionMailer::Base.deliveries.should be_empty
      BufferedJob.flush!
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "should raise error when invoked without key" do
      expect {
        TestMailer.buffer.notification({:to => "foo@example.org"})
      }.to raise_error(BufferedJob::NoBufferKeywordError)
    end
  end
end
