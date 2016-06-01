defmodule Client do
  def start do
    spawn(fn -> loop end)
  end

  def loop do
    receive do
      {pid, :connect, username} -> IO.puts username + 'se conecto. Proceso #{inspect self}'
      {pid, :corre} -> IO.puts 'Ni ahi. Proceso #{inspect self}'
      {pid, _ } -> send :pid, {:error, 'Accion Invalida de #{inspect pid}'}
    end
  end

end

