require "../spec_helper"

describe Redis::Client do
  it "sets and gets" do
    client = Redis::Client.new
    client.set("foo", "bar").should eq("OK")
    client.get("foo").should eq("bar")
  end

  it "removes a key" do
    client = Redis::Client.new
    client.set("foo", "bar").should eq("OK")
    client.del("foo").should eq(1)
    client.get("foo").should be_nil
  end
end
