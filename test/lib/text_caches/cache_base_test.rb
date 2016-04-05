require 'wovnrb/text_caches/cache_base'
require 'minitest/autorun'

class CacheBaseTest < Minitest::Test
  def teardown
    Wovnrb::CacheBase.reset_cache
  end

  def test_build
    cache = Wovnrb::CacheBase.build({})
    assert_equal('Wovnrb::MemoryCache', cache.class.name)
  end

  def test_build_with_invalid_strategy
    assert_raises RuntimeError do
      Wovnrb::CacheBase.build({strategy: :invalid})
    end
  end

  def test_set_and_get_single
    Wovnrb::CacheBase.set_single({})
    cache = Wovnrb::CacheBase.get_single
    assert_equal('Wovnrb::MemoryCache', cache.class.name)
  end

  def test_get_single_without_set
    assert_raises RuntimeError do
      Wovnrb::CacheBase.get_single
    end
  end
end
