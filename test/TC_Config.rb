require './BaseTestCase.rb'
require '../src/Config.rb'
require '../'

class TC_Config < BaseTestCase
  def setup
    @obj1 = Config
    @obj2 = Config
  end

  def test_conf
    assert_equal(@obj1, @obj2)
  end
end
