require "socket"

module Redis
  DEFAULT_HOST = "127.0.0.1"
  DEFAULT_PORT = 6379

  def self.new(host = nil, port = nil)
    Client.new(host, port)
  end

  def self.open(host = nil, port = nil)
    Client.open(host, port) do |client|
      yield client
    end
  end
end

require "./*"
