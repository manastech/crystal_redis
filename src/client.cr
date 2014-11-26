require "./protocol"

class Redis::Client
  include Protocol

  def initialize(host = "127.0.0.1", port = 6379)
    @io = BufferedIO.new TCPSocket.new host, port
  end

  def del(*keys)
    command "DEL", *keys, &.to_s
  end

  def exists(key)
    bool "EXISTS", key.to_s
  end

  def get(key)
    string? "GET", key.to_s
  end

  def incr(key)
    int "INCR", key.to_s
  end

  def decr(key)
    int "DECR", key.to_s
  end

  def set(key, value)
    command "SET", key.to_s, value.to_s
  end

  def [](key)
    string "GET", key.to_s
  end

  def []?(key)
    get key
  end

  def []=(key, value)
    set key, value
  end

  private def bool(name, *args)
    command(name, *args) == 1
  end

  private def int(name, *args)
    command(name, *args) as Int64
  end

  private def string(name, *args)
    command(name, *args) as String
  end

  private def string?(name, *args)
    command(name, *args) as String?
  end

  private def command(name, *args)
    command(name, *args) { |x| x }
  end

  private def command(name, *args)
    array(args.length + 1, @io) do
      write name, @io
      args.each do |arg|
        write yield(arg), @io
      end
    end
    @io.flush

    read @io
  end
end
