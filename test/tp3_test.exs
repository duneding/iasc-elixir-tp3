defmodule TP3Test do
  use ExUnit.Case
  doctest TP3

  test "the truth" do
	server = Server.start([])
	c1 = Client.start
	c2 = Client.start
	send server, {c1, :connect, "Martin"}
	send server, {c2, :connect, "Ale"}
	send server, {:print, :clients}
	send server, {c1,c2,:escribir,"hola soy c1"}
	send server, {c1, :silent, c2}
	send server, {c1, :unsilent, c2}
	send server, {c1, :disconnect}
  	#TODO!!! agregar los assert correspondientes y separar los test.
    assert 1 + 1 == 2
  end
end
