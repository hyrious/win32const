# frozen_string_literal: true

Dir.chdir __dir__

begin
  require 'midori'
rescue
  puts "gem install midori"
  exit 1
end

class LruCache
  def initialize max_size
    @max_size = max_size
    @data = {}
  end

  def [] key
    found = true
    value = @data.delete(key) { found = false }
    if found
      @data[key] = value
    else
      nil
    end
  end

  def []= key, value
    @data.delete key
    @data[key] = value
    if @data.size > @max_size
      @data.delete @data.first[0]
    end
    value
  end
end

Cache = LruCache.new 233
require 'set'
NotFound = Set.new

class Win32ConstAPI < Midori::API
  get '/' do
    <<~HTML
      <!DOCTYPE html><title>win32const</title><body>
      <input id=i><button onclick="o.textContent='wait...';fetch('/',{method:'post',body:i.value}).then(r=>r.text()).then(t=>o.textContent=t)">search</button><pre id=o></pre>
    HTML
  end

  post '/' do
    if ret = Cache[request.body] then next ret end
    Cache[request.body] = `ruby win32const.rb #{request.body.inspect}`
  end
end

(Midori::Runner.new Win32ConstAPI).start
