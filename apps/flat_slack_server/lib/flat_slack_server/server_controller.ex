defmodule FlatStackServer.ServerController do

    alias FlatSlackServer.ConnectionProvider

    use GenServer

    # Client API

    ## Startup

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    ## User Presence

    def provide_name(port, name) do
        GenServer.cast(ServerController, {:provide_name, port, name})
    end

    def disconnect(port) do
        GenServer.cast(ServerController, {:disconnect, port})
    end

    ## Messaging

    def new_message(port, message) do
        GenServer.cast(ServerController, {:new_message, port, message})
    end


    # GenServer Callbacks

    ## Startup

    def init(:ok) do
        {:ok, %{messages: [], message_id: 1, users: [], user_id: 1}}
    end

    ## User Presence

    def handle_cast({:provide_name, port, name}, state) do

        %{messages: messages, users: users, user_id: user_id} = state

        new_user = %{id: user_id, port: port, name: name}

        updated_users = [new_user | users]

        # Broadcast new user to all other users
        users
        |> get_active_ports
        |> ConnectionProvider.broadcast_message(%{type: "ACTIVE_USER", payload: display_user(new_user)})

        # Send the new user the current server state

        display_users = 
            updated_users
            |> Enum.map(fn user -> display_user(user) end)

        display_messages = 
            messages
            |> Enum.map(fn message -> display_message(message, users) end)
        
        ConnectionProvider.send_message(port, %{type: "INITIAL_DATA", payload: %{messages: display_messages, users: display_users, user_id: user_id}}) 

        {:noreply, %{state | users: updated_users, user_id: user_id + 1}  }
    end

    def handle_cast({:disconnect, port}, %{users: users} = state) do

        case Enum.find(users, fn user -> user.port == port end) do
            nil ->
                {:noreply, state}
            user ->
                updated_users = [ %{ user | port: nil} | Enum.filter(users, fn user -> user.port !== port end)]

                updated_users
                |> get_active_ports
                |> ConnectionProvider.broadcast_message(%{type: "INACTIVE_USER", payload: user.id})

                {:noreply, %{state | users: updated_users}}
        end
    end

    ## Messaging

    def handle_cast({:new_message, port, content}, state) do

        %{users: users, message_id: message_id, messages: messages} = state

        case Enum.find(users, fn user -> user.port == port end) do
            nil ->
                {:noreply, state}
            user ->
                message = %{id: message_id, user_id: user.id, content: content}

                users
                |> get_active_ports
                |> ConnectionProvider.broadcast_message(%{type: "NEW_MESSAGE", payload: display_message(message, users)})

                

                {:noreply, %{state | messages: [message | messages], message_id: message_id + 1 }}
        end
    end


    # Helper Functions

    defp display_user(user) do
        %{id: user.id, name: user.name, active: is_active?(user)}
    end

    defp display_message(message, users) do
        %{
            id: message.id,
            user_id: message.user_id,
            content: message.content,
            username: Enum.find(users, fn user -> user.id == message.user_id end).name
        }
    end

    defp is_active?(user) do
        not is_nil(user.port)
    end

    defp get_active_ports(users) do
        users
        |> Enum.filter(fn user -> user.port end)
        |> Enum.map(fn user -> user.port end)
    end

end