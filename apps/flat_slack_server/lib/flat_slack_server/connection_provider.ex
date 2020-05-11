defmodule FlatSlackServer.ConnectionProvider do

    alias FlatStackServer.ServerController
  
    def accept(port) do
      {:ok, socket} = :gen_tcp.listen(port, [:binary, active: false, packet: 2, reuseaddr: true])
      loop_acceptor(socket)
    end
  
    def loop_acceptor(socket) do
      {:ok, client} = :gen_tcp.accept(socket)
      {:ok, pid} = Task.Supervisor.start_child(ConnectionSupervisor, fn -> initialize_connection(client) end)
      :ok = :gen_tcp.controlling_process(client, pid)
      loop_acceptor(socket)
    end
  
    defp initialize_connection(socket) do
      send_message(socket, %{type: "CONNECTION_CONFIRMED"})
      listen(socket)
    end
  
    defp listen(socket) do
      case :gen_tcp.recv(socket, 0) do
        {:ok, data} ->
          message = Poison.decode!(data)
          process_message(socket, message)
          listen(socket)
        _ ->
          ServerController.disconnect(socket)
      end
    end
  
    defp process_message(socket, message) do
      case message do
        %{"type" => "NEW_CHAT_MESSAGE", "payload" => content} ->
          ServerController.new_message(socket, content)
        %{"type" => "NAME_CHOICE", "payload" => name} ->
          ServerController.provide_name(socket, name)   
        _ -> :unrecognized_message
      end
    end
  
    def send_message(socket, message) do
      :gen_tcp.send(socket, Poison.encode!(message))
    end
  
    def broadcast_message(sockets, message) do
      sockets
      |> Enum.each(fn socket -> send_message(socket, message) end)
    end
  
  end