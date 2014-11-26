require "./protocol"

class Redis::Client
  include Protocol

  def initialize(host = "127.0.0.1", port = 6379)
    @io = BufferedIO.new TCPSocket.new host, port
  end

  def del(*keys)
    command "DEL", *keys
  end

  def exists(key)
    bool "EXISTS", key
  end

  def get(key)
    string? "GET", key
  end

  def incr(key)
    int "INCR", key
  end

  def decr(key)
    int "DECR", key
  end

  def set(key, value)
    command "SET", key, value
  end

  def [](key)
    string "GET", key
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
    array(args.length + 1, @io) do
      write name, @io
      args.each do |arg|
        write arg, @io
      end
    end
    @io.flush

    read @io
  end
end
