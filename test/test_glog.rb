require 'helper'

class TestGlog < Test::Unit::TestCase
  should "show something..." do
    Glog.new.write_log
  end
end
