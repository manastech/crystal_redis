require "../spec_helper"

describe Redis::Client do
  it "set and get" do
    Redis.open do |client|
      client.set("foo", "bar").should eq("OK")
      client.get("foo").should eq("bar")
    end
  end

  it "set and get with []" do
    Redis.open do |client|
      client["foo"] = "bar"
      client["foo"].should eq("bar")
      client.del("foo")
      client["foo"]?.should be_nil
    end
  end

  it "set and get number" do
    Redis.open do |client|
      client.set("foo", 1).should eq("OK")
      client.get("foo").should eq("1")
      client.set(1, 2).should eq("OK")
      client.get(1).should eq("2")
    end
  end

  it "del one key" do
    Redis.open do |client|
      client.set("foo", "bar").should eq("OK")
      client.del("foo").should eq(1)
      client.get("foo").should be_nil
    end
  end

  it "del many keys" do
    Redis.open do |client|
      client.set("foo", "bar").should eq("OK")
      client.set("baz", "qux").should eq("OK")
      client.del("foo", "baz").should eq(2)
    end
  end

  it "del one numeric key" do
    Redis.open do |client|
      client.set(1, "bar").should eq("OK")
      client.del(1).should eq(1)
      client.get(1).should be_nil
    end
  end

  it "exists" do
    Redis.open do |client|
      client.set("foo", "bar").should eq("OK")
      client.exists("foo").should be_true
      client.del("foo")
      client.exists("foo").should be_false
    end
  end

  it "incr and decr" do
    Redis.open do |client|
      client.del("foo")
      client.incr("foo").should eq(1)
      client.incr("foo").should eq(2)
      client.decr("foo").should eq(1)
      client.decr("foo").should eq(0)
      client.decr("foo").should eq(-1)
      client.decr("foo").should eq(-2)
    end
  end
end
