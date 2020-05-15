defmodule FlatSlackClient.Messenger do

    use GenServer

    # Client API

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def establish_connection() do
        GenServer.cast(Messenger, :establish_connection)
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

    def handle_cast(:establish_connection, state) do

        # Needs to be given an address, of the format {x, x, x, x}
        address = nil

        case :gen_tcp.connect(address, 4040, [:binary, packet: 2, active: true]) do
            {:ok, socket} ->
                # Should be made into a call, so that this can both set the port and also change application address state.
                {:noreply, %{ state | port: socket }}
            _ ->
                # Needs to produce an error message to display
                {:noreply, state}
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