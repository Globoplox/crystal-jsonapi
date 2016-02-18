require "./spec_helper"

class CacheableTest
  include JSONApi::Cacheable
  cache_key @foo, @bar

  def initialize(@foo, @bar)
  end

  def to_cached_json(io)
    io.json_object do |object|
      object.field(:foo, @foo)
      object.field(:bar, @bar)
    end
  end
end

class TimesCalledTest
  include JSONApi::Cacheable
  cache_key @foo, @bar

  getter times_called
  def initialize(@foo, @bar)
    @times_called = 0
  end

  def to_cached_json(io)
    @times_called += 1
    io.json_object do |object|
      object.field(:foo, @foo)
      object.field(:bar, @bar)
    end
  end
end

describe JSONApi::Cacheable do
  context JSONApi::Cacheable::CacheIO do
    it "copies data written to it to the given io" do
      io = MemoryIO.new
      cache = JSONApi::Cacheable::CacheIO.new(io)
      cache << "hello"
      io.to_s.should eq("hello")
    end

    it "stores the data written to it" do
      io = MemoryIO.new
      cache = JSONApi::Cacheable::CacheIO.new(io)
      cache << "hello"
      cache.to_s.should eq("hello")
    end

    it "is chainable" do
      io = MemoryIO.new
      first_cache = JSONApi::Cacheable::CacheIO.new(io)
      second_cache = JSONApi::Cacheable::CacheIO.new(first_cache)
      second_cache << "hello"
      first_cache.to_s.should eq("hello")
      second_cache.to_s.should eq("hello")
    end
  end

  context "#to_json" do
    it "writes the json to the given io" do
      test = CacheableTest.new("foo", "bar")
      test.to_json.should eq(%[{"foo":"foo","bar":"bar"}])
    end

    it "calls to_json only once per hash" do
      test = TimesCalledTest.new("foo", "bar")
      other_test = TimesCalledTest.new("foo", "bar")

      test.to_json
      test.to_json
      test.times_called.should eq(1)
      other_test.to_json
      other_test.times_called.should eq(0)
    end
  end
end
