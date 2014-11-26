require "../spec_helper"

describe Redis::Client do
  it "set and get" do
    client = Redis::Client.new
    client.set("foo", "bar").should eq("OK")
    client.get("foo").should eq("bar")
  end

  it "del one key" do
    client = Redis::Client.new
    client.set("foo", "bar").should eq("OK")
    client.del("foo").should eq(1)
    client.get("foo").should be_nil
  end

  it "del many keys" do
    client = Redis::Client.new
    client.set("foo", "bar").should eq("OK")
    client.set("baz", "qux").should eq("OK")
    client.del("foo", "baz").should eq(2)
  end

  it "exists" do
    client = Redis::Client.new
    client.set("foo", "bar").should eq("OK")
    client.exists("foo").should be_true
    client.del("foo")
    client.exists("foo").should be_false
  end

  it "incr and decr" do
    client = Redis::Client.new
    client.del("foo")
    client.incr("foo").should eq(1)
    client.incr("foo").should eq(2)
    client.decr("foo").should eq(1)
    client.decr("foo").should eq(0)
    client.decr("foo").should eq(-1)
    client.decr("foo").should eq(-2)
  end
end
