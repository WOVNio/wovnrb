require 'wovnrb/store'
require 'minitest/autorun'

class StoreTest < Minitest::Test
  def test_initialize
    s = Wovnrb::Store.new
    refute_nil(s)
  end

  def test_settings_no_parameters
    s = Wovnrb::Store.new
    assert_equal('path', s.settings['url_pattern'])
    assert_equal('/(?<lang>[^/.?]+)', s.settings['url_pattern_reg'])
  end

  def test_settings_url_pattern_path
    s = Wovnrb::Store.new
    s.settings({'url_pattern' => 'path'})
    assert_equal('path', s.settings['url_pattern'])
    assert_equal('/(?<lang>[^/.?]+)', s.settings['url_pattern_reg'])
  end

  def test_settings_url_pattern_subdomain
    s = Wovnrb::Store.new
    s.settings({'url_pattern' => 'subdomain'})
    assert_equal("^(?<lang>[^.]+)\.", s.settings['url_pattern_reg'])
    assert_equal('subdomain', s.settings['url_pattern'])
  end

  def test_settings_url_pattern_query
    s = Wovnrb::Store.new
    s.settings({'url_pattern' => 'query'})
    assert_equal('((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)', s.settings['url_pattern_reg'])
    assert_equal('query', s.settings['url_pattern'])
  end
end

