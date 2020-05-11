defmodule FlatSlackClient.Interface do

    @behaviour Ratatouille.App

    import Ratatouille.View

    alias  Ratatouille.Runtime.{Command, Subscription}

    alias FlatSlackClient.Messenger

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
                connected: false,
                landing_ui: %{input_field: "", error_message: ""},
                chatroom_ui: %{message_cursor: 0, message_field: ""},
                chatroom_data: nil,
                dimensions: {width, height}
            },
            Command.new(fn -> Messenger.establish_connection() end, :server_init)
        }
    end 

    def subscribe(_model) do
        Subscription.interval(100, :check_messenger)
    end

    def update(model, msg) do
        case {model, msg} do
            { _, :check_messenger } ->
                
                case Messenger.get_message() do
                    :none ->
                        model
                    server_message ->
                        Updates.server(model, server_message)
                end
            { _ , {:resize, event}} -> %{ model | dimensions: {event.w, event.h}}
            {%{chatroom_data: nil, connected: false}, {:event, _event}} -> model
            {%{chatroom_data: nil, connected: true}, {:event, event} } ->
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
            nil -> Landing.render(model.dimensions, model.landing_ui, model.connected)
            _ -> ChatRoom.render(model.dimensions, model.chatroom_ui, model.chatroom_data)
        end
        
    end


end