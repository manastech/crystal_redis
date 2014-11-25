require "../spec_helper"

def it_reads(string, expected, file = __FILE__, line = __LINE__)
  it "reads #{string}", file, line do
    Redis::Protocol.read(StringIO.new(string)).should eq(expected)
  end
end

describe Redis::Protocol do
  describe "read" do
    it_reads "+OK\r\n", "OK"
    it_reads "+Hello world\r\n", "Hello world"

    it_reads ":0\r\n", 0
    it_reads ":1000\r\n", 1000

    it_reads "$6\r\nfoobar\r\n", "foobar"
    it_reads "$0\r\n\r\n", ""
    it_reads "$-1\r\n", nil

    it_reads "*0\r\n", [] of Redis::ResponseType
    it_reads "*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n", ["foo", "bar"]
    it_reads "*-1\r\n", nil
    it_reads "*3\r\n:1\r\n:2\r\n:3\r\n", [1, 2, 3]
    it_reads "*5\r\n:1\r\n:2\r\n:3\r\n:4\r\n$6\r\nfoobar\r\n", [1, 2, 3, 4, "foobar"]
    it_reads "*3\r\n$3\r\nfoo\r\n$-1\r\n$3\r\nbar\r\n", ["foo", nil, "bar"]

    it "raises on error" do
      expect_raises Redis::CommandError, "OH NO!" do
        Redis::Protocol.read(StringIO.new("-OH NO!"))
      end
    end
  end

  describe "write" do
    it "writes nil" do
      io = StringIO.new
      Redis::Protocol.write(nil, io)
      io.to_s.should eq("$-1\r\n")
    end

    it "writes bulk string" do
      io = StringIO.new
      Redis::Protocol.write("hello", io)
      io.to_s.should eq("$5\r\nhello\r\n")
    end

    it "writes integer" do
      io = StringIO.new
      Redis::Protocol.write(1234, io)
      io.to_s.should eq(":1234\r\n")
    end

    it "writes array" do
      io = StringIO.new
      Redis::Protocol.array(5, io) do
        Redis::Protocol.write(1, io)
        Redis::Protocol.write(2, io)
        Redis::Protocol.write(3, io)
        Redis::Protocol.write(4, io)
        Redis::Protocol.write("foobar", io)
      end
      io.to_s.should eq("*5\r\n:1\r\n:2\r\n:3\r\n:4\r\n$6\r\nfoobar\r\n")
    end
  end
end
