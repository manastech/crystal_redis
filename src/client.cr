require "./protocol"

class Redis::Client
  include Protocol

  def initialize(host = "127.0.0.1", port = 6379)
    @io = BufferedIO.new TCPSocket.new host, port
  end

  def del(key)
    command "DEL", key
  end

  def get(key)
    (command "GET", key) as String?
  end

  def set(key, value)
    command "SET", key, value
  end

  def command(name, *args)
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
