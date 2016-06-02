defmodule User do
  defstruct nickname: "", silent: [], pid: nil
end

defmodule Server do
  def start(clients) do
    spawn(fn -> loop(clients) end)
  end

  def loop(clients) do
    receive do
      {client, :connect, nickname} ->
          user = %User{nickname: nickname, pid: client}
          clients = List.insert_at(clients, -1, user) 
      		IO.puts 'Se conecto usuario: #{nickname}. Proceso #{inspect client}'         
      {client, :disconnect} ->
          clients = Enum.filter clients, fn x ->
            Map.get(x,:pid) != client
          end
          IO.puts 'Clients: #{inspect clients}' 
          clients = List.delete(clients, nil)          
          IO.puts 'Se desconecto usuario con PID: #{inspect client}.'                   
          loop(clients)
      {emisor, receptor, :visto} -> 
	      	send emisor, {receptor, :visto}       		
      {:getClients} -> 
          IO.puts 'Clients: #{inspect clients}' 
      {emisor, receptor, :escribir, mensaje} -> 
	      	IO.puts 'Escribe mensaje. Emisor #{inspect emisor} Receptor #{inspect receptor}. 
	      			 Mensaje: #{mensaje}'
	      	send receptor, {emisor, :typing}	
	      	:timer.sleep(3* 1000);	 
	      	send receptor, {self, emisor, :leer, mensaje}              	
      {emisor, :silent, receptor} ->    
          e = Enum.filter clients, fn x ->
            Map.get(x,:pid) == emisor
          end
          e = List.first(e)

    end
    loop(clients)
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
    {emisor, :typing} -> 
      IO.puts 'Usuario #{inspect emisor} esta escribiendo...'           
		{receptor, :visto} ->
			IO.puts 'Visto por #{inspect receptor}' 
    end  
    loop
  end

end


