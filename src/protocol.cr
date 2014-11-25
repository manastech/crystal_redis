module Redis
  alias ResponseType = Nil | Int64 | String | Array(ResponseType)

  module Protocol
    extend self

    def read(io)
      case io.read_byte
      when '+'.ord
        read_string(io)
      when '-'.ord
        raise CommandError.new read_string(io)
      when ':'.ord
        read_number(io)
      when '$'.ord
        length = read_number(io)
        return nil if length == -1

        value = io.read(length.to_i32)
        io.read_byte # \r
        io.read_byte # \n
        value
      when '*'.ord
        length = read_number(io)
        return nil if length == -1

        values = Array(ResponseType).new(length)
        length.times do
          values << read(io)
        end
        values
      else
        nil
      end
    end

    def write(value : Nil, io)
      io.print "$-1\r\n"
    end

    def write(value : Int, io)
      io.print ':'
      io.print value
      io.print "\r\n"
    end

    def write(value : String, io)
      io.print '$'
      io.print value.bytesize
      io.print "\r\n"
      io.print value
      io.print "\r\n"
    end

    def array(length, io)
      io.print '*'
      io.print length
      io.print "\r\n"
      yield
    end

    private def read_string(io)
      io.gets.not_nil!.chomp
    end

    private def read_number(io)
      length = 0_i64
      byte = io.read_byte.not_nil!
      if byte == '-'.ord
        io.read_byte # 1
        io.read_byte # \r
        io.read_byte # \n
        return -1_i64
      end
      while true
        if '0'.ord <= byte < '9'.ord
          length = length * 10 + (byte - '0'.ord)
        else
          break
        end
        byte = io.read_byte.not_nil!
      end
      io.read_byte # \n
      length
    end
  end
end
