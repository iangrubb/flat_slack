defmodule FlatSlackServer.ConnectionProvider do

  alias FlatStackServer.ServerController

  alias FlatSlackServer.Models.Chatroom

  alias FlatSlackServer.Repo, as: ServerRepo

  def accept(port, chatroom_id) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, active: false, packet: 2, reuseaddr: true])

    {:ok, pid} = Task.Supervisor.start_child(ConnectionSupervisor, fn -> loop_acceptor(socket, chatroom_id) end)
    :ok = :gen_tcp.controlling_process(socket, pid)

    socket
  end

  def loop_acceptor(socket, chatroom_id) do

    {:ok, client} = :gen_tcp.accept(socket)
    
    {:ok, pid} = Task.Supervisor.start_child(ConnectionSupervisor, fn -> initialize_connection(client, chatroom_id) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket, chatroom_id)

  end

  defp initialize_connection(socket, chatroom_id) do
    send_message(socket, %{type: "CONNECTION_CONFIRMED"})
    listen(socket, chatroom_id)
  end

  defp listen(socket, chatroom_id) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        message = Poison.decode!(data)
        process_message(socket, message, chatroom_id)
        listen(socket, chatroom_id)
      _ ->
        ServerController.disconnect(socket)
    end
  end

  defp process_message(socket, message, chatroom_id) do

    # use chatroom_id in these messages


    


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