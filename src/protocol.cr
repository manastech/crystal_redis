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
      io << "$-1\r\n"
    end

    def write(value : Int, io)
      io << ':' << value << "\r\n"
    end

    def write(value : String, io)
      io << '$' << value.bytesize << "\r\n" << value << "\r\n"
    end

    def array(length, io)
      io << '*' << length << "\r\n"
      yield
    end

    private def read_string(io)
      io.gets.not_nil!.chomp
    end

    private def read_number(io)
      length = 0_i64
      negative = false
      byte = io.read_byte.not_nil!
      if byte == '-'.ord
        negative = true
        byte = io.read_byte.not_nil!
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
      negative ? -length : length
    end
  end
end
