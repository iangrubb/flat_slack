defmodule FlatSlackClient.Interface do

    @behaviour Ratatouille.App

    import Ratatouille.View

    alias  Ratatouille.Runtime.{Command, Subscription}

    alias FlatSlackClient.{
        Messenger,
        ConnectionLog
    }

    alias FlatSlackClient.Repo, as: ClientRepo
    alias FlatSlackServer.Repo, as: ServerRepo

    alias FlatSlackServer.Models.Chatroom

    alias FlatSlackClient.Views.{
        Landing,
        ChatRoom
    }

    alias FlatSlackClient.Updates

    alias Ratatouille.Window


    import Ratatouille.Constants, only: [key: 1]

    @arrow_up key(:arrow_up)
    @arrow_down key(:arrow_down)
    @ctrl_e key(:ctrl_e)


    @special_ui [@arrow_up, @arrow_down, @ctrl_e]

    def init(_context) do
        {:ok, width} = Window.fetch(:width)
        {:ok, height} = Window.fetch(:height)
        {
            %{  
                dimensions: {width, height},

                landing_ui:
                    %{input_field: "", error_message: "", input_cursor: 0, input_options:
                        [
                        {"Create a New Chatroom", :new_chatroom},
                        {"Restart a Chatroom", :restart_chatroom},
                        {"Connect to New Chatroom", :new_remote_connection},
                        {"Connect to Visited Chatroom", :reestablish_connection}
                        ]
                    },
                past_connections: nil,
                owned_chatrooms: nil,

                connection_choice: nil,

                remote_port: nil,

                chatroom_data: nil,
                chatroom_ui: %{message_cursor: 0, message_field: ""}
            },
            Command.new(fn ->
                {ClientRepo.all(ConnectionLog), ServerRepo.all(Chatroom)}
            end, :initialize_client)
        }
    end 

    def subscribe(_model) do
        Subscription.interval(100, :check_messenger)
    end

    def update(model, msg) do
        case {model, msg} do
            { _ , {:initialize_client, {past_connections, owned_chatrooms}}} ->
                %{model | past_connections: past_connections, owned_chatrooms: owned_chatrooms}
            { _, :check_messenger } ->
                case Messenger.get_message() do
                    :none ->
                        model
                    server_message ->
                        Updates.server(model, server_message)
                end
            { _ , {:resize, event}} -> %{ model | dimensions: {event.w, event.h}}

            {%{remote_port: nil}, {:event, event}} -> Updates.landing(model, event)

            {%{chatroom_data: nil, remote_port: _}, {:event, event} } ->
                submit =
                    fn name ->
                        updated_model = %{ model | landing_ui: %{ model.landing_ui | input_field: ""}}
                        message_out = %{type: "NAME_CHOICE", payload: name}
                        message_command = Command.new(fn -> Messenger.send_message(message_out) end, :server_send)
                        {updated_model, message_command}
                    end
                Updates.text_field(model, [:landing_ui, :input_field], event, submit, nil)

            {_, {:event, %{key: key}}} when key in @special_ui -> Updates.chatroom(model, key)

            {_, {:event, event}} -> 
                submit =
                    fn sentence ->
                        updated_model = %{ model | chatroom_ui: %{ model.chatroom_ui | message_field: ""}}
                        message_out = %{type: "NEW_CHAT_MESSAGE", payload: sentence}
                        message_command = Command.new(fn -> Messenger.send_message(message_out) end, :server_send)
                        {updated_model, message_command}
                    end
                Updates.text_field(model, [:chatroom_ui, :message_field], event, submit, nil)
            _ -> model
        end
    end

    def render(model) do
        
        case model.chatroom_data do
            nil -> Landing.render(model.dimensions, model.landing_ui, model.remote_port, model.connection_choice)
            _ -> ChatRoom.render(model.dimensions, model.chatroom_ui, model.chatroom_data)
        end
        
    end


end