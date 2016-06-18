# -*- encoding: UTF-8 -*-
require 'wovnrb/text_caches/cache_base'
require 'wovnrb/text_caches/memory_cache'
require 'minitest/autorun'
require 'timecop'

class MemoryCacheTest < Minitest::Test
  def test_initialize
    memory = Wovnrb::MemoryCache.new({
      'cache_megabytes' => 1,
      'ttl_seconds' => 1
    })
    option = memory.options
    assert_equal(1.megabytes, option[:size])
    assert_equal(1.megabytes, option[:size])
    assert_equal(1.seconds, option[:expires_in])
  end

  def test_initialize_without_cache_megabytes
    memory = Wovnrb::MemoryCache.new({
      'ttl_seconds' => 1
    })
    option = memory.options
    assert_equal(200.megabytes, option[:size])
    assert_equal(1.seconds, option[:expires_in])
  end

  def test_initialize_without_ttl
    memory = Wovnrb::MemoryCache.new({
      'cache_megabytes' => 1,
    })
    option = memory.options
    assert_equal(1.megabytes, option[:size])
    assert_equal(300.seconds, option[:expires_in])
  end

  def test_initialize_with_no_config
    memory = Wovnrb::MemoryCache.new({})
    option = memory.options
    assert_equal(200.megabytes, option[:size])
    assert_equal(300.seconds, option[:expires_in])
  end

  def test_put_without_cache
    memory = Wovnrb::MemoryCache.new({})
    memory.put('a', 'b')
    assert_equal('b', memory.get('a'))
  end

  def test_put_with_cache
    memory = Wovnrb::MemoryCache.new({})
    memory.put('a', 'b')
    memory.put('a', 'b2')
    assert_equal('b2', memory.get('a'))
  end

  def test_get_with_cache
    memory = Wovnrb::MemoryCache.new({})
    memory.put('a', 'b')
    assert_equal('b', memory.get('a'))
  end

  def test_get_without_cache
    memory = Wovnrb::MemoryCache.new({})
    assert_equal(nil, memory.get('a'))

  end

  def test_get_with_timeout
    memory = Wovnrb::MemoryCache.new({})
    memory.put('a', 'b')
    Timecop.travel(1.day.since)
    assert_equal(nil, memory.get('a'))
  end

  def test_get_with_over_memory
    # ActiveSupport::Cache::MemoryStore has 240 bytes overhead per instance
    memory = Wovnrb::MemoryCache.new({
      'cache_megabytes' => 400.0 / 1000 / 1000,
    })
    memory.put('a', 'c')
    memory.put('b', 'd')
    assert_equal(nil, memory.get('a'))
    assert_equal('d', memory.get('b'))
  end

  def test_get_with_utf8
    memory = Wovnrb::MemoryCache.new({})
    memory.put('http://www.example.com', 'あいうえお')
    assert_equal('あいうえお', memory.get('http://www.example.com'))
  end
end
