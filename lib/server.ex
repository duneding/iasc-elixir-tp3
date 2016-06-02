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
      {receptor, :visto, emisor} -> 
          em_map = Enum.find clients, fn x ->
            Map.get(x,:pid) == emisor
          end
          silent = Map.get(em_map, :silent)
          rec_map = Enum.find(silent, fn(x) -> x == receptor end)
          case (rec_map == nil) do          
	      	  true -> send emisor, {receptor, :visto}       		
            false -> 'nothing'
          end
      {:getClients} -> 
          IO.puts 'Clients: #{inspect clients}' 
      {emisor, receptor, :escribir, mensaje} -> 
	      	IO.puts 'Escribe mensaje. Emisor #{inspect emisor} Receptor #{inspect receptor}. 
	      			 Mensaje: #{mensaje}'
	      	send receptor, {emisor, :typing}	
	      	:timer.sleep(3* 1000);	 
	      	send receptor, {self, emisor, :leer, mensaje}              	
      {emisor, :silent, receptor} ->    
          em_map = Enum.filter clients, fn x ->
            Map.get(x,:pid) == emisor
          end
          rest_list = Enum.filter clients, fn x ->
            Map.get(x,:pid) != emisor
          end                    
          em_map = Map.put(List.first(em_map),
                            :silent, 
                            List.flatten(Map.get(List.first(em_map),:silent),[receptor]))
          clients = List.insert_at(rest_list, -1, em_map)
          loop(clients)                            
      {emisor, :unsilent, receptor} ->    
          em_map = List.first(Enum.filter clients, fn x ->
                                Map.get(x,:pid) == emisor
                              end)
          rest_list = Enum.filter clients, fn x ->
            Map.get(x,:pid) != emisor
          end    

          silent = List.delete(Map.get(em_map,:silent), receptor)
          em_map = Map.put(em_map, :silent, silent)
          clients = List.insert_at(rest_list, -1, em_map)
          loop(clients)           
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
			send server, {self, :visto, emisor}
		{emisor, :typing} -> 
			IO.puts 'Usuario #{inspect emisor} esta escribiendo...'			
		{receptor, :visto} ->
			IO.puts 'Visto por #{inspect receptor}' 
    end  
    loop
  end

end


