require 'wovnrb/services/url'

class URLTest < Minitest::Test

  def test_prepend_path
    assert_equal('http://google.com/new_dir/test', Wovnrb::URL.prepend_path('http://google.com/test', 'new_dir'))
  end

end
