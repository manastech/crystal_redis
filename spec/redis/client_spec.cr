require "../spec_helper"

describe Redis::Client do
  it "set and get" do
    client = Redis::Client.new
    client.set("foo", "bar").should eq("OK")
    client.get("foo").should eq("bar")
  end

  it "set and get with []" do
    client = Redis::Client.new
    client["foo"] = "bar"
    client["foo"].should eq("bar")
    client.del("foo")
    client["foo"]?.should be_nil
  end

  it "set and get number" do
    client = Redis::Client.new
    client.set("foo", 1).should eq("OK")
    client.get("foo").should eq("1")
    client.set(1, 2).should eq("OK")
    client.get(1).should eq("2")
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

  it "del one numeric key" do
    client = Redis::Client.new
    client.set(1, "bar").should eq("OK")
    client.del(1).should eq(1)
    client.get(1).should be_nil
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
