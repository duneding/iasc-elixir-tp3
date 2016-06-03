defmodule TP3Test do
  use ExUnit.Case
  doctest TP3

  test "the truth of process" do
	server = Server.start([])
	c1 = Client.start
	c2 = Client.start
	
	assert Process.alive?(server)
	assert Process.alive?(c1)
	assert Process.alive?(c2)
  end

  test "the truth of connect" do
	server = Server.start([])
	c1 = Client.start
	{pid, :connect, nickname} = send server, {c1, :connect, "Martin"}
    
    assert nickname == "Martin"
    assert Process.alive?(pid)
  end  
end
