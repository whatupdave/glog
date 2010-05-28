require 'helper'

class TestGlog < Test::Unit::TestCase
  should "have initial commit" do
    assert_equal 'Initial Commit', Glog.new.log.last
  end
end
