defmodule FlatSlackClient.Messenger do

    use GenServer

    # Client API

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def establish_connection(address) do
        GenServer.call(Messenger, {:establish_connection, address})
    end

    def get_message() do
        GenServer.call(Messenger, :get_message)
    end

    def send_message(message) do
        GenServer.cast(Messenger, {:send_message, message})
    end


    # Server Callbacks

    def init(:ok) do
        {:ok, %{messages: [], port: nil}}
    end

    def handle_call({:establish_connection, address}, _from, state) do
        case :gen_tcp.connect(address, 4040, [:binary, packet: 2, active: true]) do
            {:ok, socket} ->
                {:reply, :ok , %{ state | port: socket }}
            _ ->
                # Needs to produce an error message to display
                {:reply, :error , state}
        end
    end

    def handle_call(:get_message, _from, %{messages: []} = state) do
        {:reply, :none, state}
    end

    def handle_call(:get_message, _from, %{messages: messages} = state) do
        {last, initial} = List.pop_at(messages, length(messages) - 1)
        {:reply, last, %{ state | messages: initial }}
    end

    def handle_cast({:send_message, message}, state) do
        :gen_tcp.send(state.port, Poison.encode!(message))
        {:noreply, state}
    end

    def handle_info({:tcp, _port, data}, state) do
        message = Poison.decode!(data) 
        {:noreply, %{state | messages: [ message | state.messages] }}
    end

    def handle_info(_, state) do
        {:noreply, state}
    end

end