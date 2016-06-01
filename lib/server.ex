defmodule Server do
  def start do
    spawn(fn -> loop end)
  end

  def loop do
    receive do
      {client, :connect, username} -> 
      		IO.puts 'Se conecto usuario: #{username}. Proceso #{inspect client}'         
      {emisor, receptor, :visto} -> 
	      	send emisor, {receptor, :visto}       		
      {emisor, receptor, :escribir, mensaje} -> 
	      	IO.puts 'Escribe mensaje. Emisor #{inspect emisor} Receptor #{inspect receptor}. 
	      			 Mensaje: #{mensaje}'
	      	send receptor, {emisor, :typing}	
	      	:timer.sleep(3* 1000);	 
	      	send receptor, {self, emisor, :leer, mensaje}              	
    end
    loop
  end

end

defmodule Client do
  def start do
    spawn(fn -> loop end)
  end

  def loop do
    receive do
		{server, emisor, :leer, mensaje} -> 
			IO.puts 'Se lee mensaje: #{mensaje} de emisor: #{inspect emisor}'
			send server, {emisor, self, :visto}
		{emisor, :typing} -> 
			IO.puts 'Usuario #{inspect emisor} esta escribiendo...'			
		{receptor, :visto} ->
			IO.puts 'Visto por #{inspect receptor}' 
    end
    loop
  end

end


