defmodule User do
  defstruct nickname: "", silent: [], pid: nil
end

defmodule Server do
  def start(clients) do
    spawn(fn -> loop(clients) end)
  end

  def getClient(clients, client) do
    Enum.find clients, fn x ->
      Map.get(x,:pid) == client
    end    
  end

  def filterClient(clients, client) do
    Enum.filter clients, fn x ->
      Map.get(x,:pid) != client
    end    
  end

  def addSilent(user, element) do
    List.flatten(Map.get(user,:silent),[element])
  end

  def removeSilent(user, element) do
    List.delete(Map.get(user,:silent),element)
  end

  def updateSilent(user, new_silent) do
    Map.put(user, :silent, new_silent)
  end

  def isSilenced(user, element) do
    silent = Map.get(user, :silent)
    if (Enum.member?(silent, element)) do          
      true
    else
      false
    end    
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
          em_map = getClient(clients, emisor)        
          if (!isSilenced(em_map, receptor)) do
	      	  send emisor, {receptor, :visto}       		          
          end
      {:print, :clients} -> 
          IO.puts 'Clients: #{inspect clients}'           
      {emisor, receptor, :escribir, mensaje} -> 
	      	IO.puts 'Escribe mensaje. Emisor #{inspect emisor} Receptor #{inspect receptor}. 
	      			 Mensaje: #{mensaje}'
	      	send receptor, {emisor, :typing}	
	      	:timer.sleep(3* 1000);	 
	      	send receptor, {self, emisor, :leer, mensaje}              	
      {emisor, :silent, receptor} ->    
          em_map = getClient(clients, emisor)
          rest_list = filterClient(clients, emisor)
          clients = List.insert_at(rest_list, -1, 
                                    updateSilent(em_map, 
                                    addSilent(em_map, receptor)))
          loop(clients)                            
      {emisor, :unsilent, receptor} ->  
          em_map = getClient(clients, emisor)  
          rest_list = filterClient(clients, emisor)
          clients = List.insert_at(rest_list, -1, 
                                    updateSilent(em_map, 
                                    removeSilent(em_map, receptor)))
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


