module Redis
  alias ResponseType = Nil | Int64 | String | Array(ResponseType)

  module Protocol
    extend self

    def read(io)
      case io.read_byte.try &.chr
      when '+'
        read_string(io)
      when '-'
        raise CommandError.new read_string(io)
      when ':'
        read_number(io)
      when '$'
        length = read_number(io).to_i32
        return nil if length == -1

        value = String.new(length) do |buffer|
                  io.read_fully(Slice.new(buffer, length))
                  {length, 0}
                end
        io.read_byte # \r
        io.read_byte # \n
        value
      when '*'
        length = read_number(io)
        return nil if length == -1

        Array.new(length.to_i32) { read(io) as ResponseType }
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
      char = read_char(io)
      if char == '-'
        negative = true
        char = read_char(io)
      end
      while char.digit?
        length = length * 10 + (char - '0')
        char = read_char(io)
      end
      io.read_byte # \n
      negative ? -length : length
    end

    private def read_char(io)
      io.read_byte.not_nil!.chr
    end
  end
end
