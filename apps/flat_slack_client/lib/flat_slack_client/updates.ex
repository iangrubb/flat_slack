defmodule FlatSlackClient.Updates do

    alias  Ratatouille.Runtime.Command

    import Ratatouille.Constants, only: [key: 1]

    @arrow_up key(:arrow_up)
    @arrow_down key(:arrow_down)
    @ctrl_e key(:ctrl_e)

    # Update handling for messages from the server

    def server(model, message) do
        case message do
            %{"type" => "CONNECTION_CONFIRMED"} ->
                %{model | connected: true}
            %{"type" => "INITIAL_DATA", "payload" => %{"messages" => messages, "users" => users, "user_id" => user_id}} ->
                normalized_messages = Enum.map(messages, fn message -> normalize(message) end)
                normalized_users = Enum.map(users, fn user -> normalize(user) end)
                %{model | chatroom_data: {normalized_messages, normalized_users, user_id}}
            %{"type" => "NEW_MESSAGE", "payload" => message} ->
                {messages, users, user_id} = model.chatroom_data
                %{model | chatroom_data: {[ normalize(message) | messages], users, user_id}}
            %{"type" => "ACTIVE_USER", "payload" => user }  ->
                {messages, users, user_id} = model.chatroom_data
                update = "#{user["name"]} has joined the chat"
                %{ model | chatroom_data: {[%{user_id: nil, content: update} | messages], [ normalize(user) | users], user_id} }
            %{"type" => "INACTIVE_USER", "payload" => absent_user_id } ->
                {messages, users, user_id} = model.chatroom_data
                user = Enum.find(users, fn u -> u.id == absent_user_id end)
                update = "#{user.name} has left the chat"
                absent_user = Enum.find(users, fn user -> user.id == absent_user_id end)
                filtered_users = Enum.filter(users, fn user -> user.id !== absent_user_id end)
                %{ model | chatroom_data: {[%{user_id: nil, content: update} | messages], [%{absent_user | active: false} | filtered_users] , user_id}}
            _ -> model
        end
    end

    def normalize(%{"id" => id, "name" => name, "active" => active}) do
        %{id: id, name: name, active: active}
    end

    def normalize(%{"id"=> id, "user_id" => user_id, "content" => content, "username" => username}) do
        %{id: id, user_id: user_id, content: content, username: username}
    end



    # Update handling for text-typing contexts

    @spacebar key(:space)

    @delete_keys [
        key(:delete),
        key(:backspace),
        key(:backspace2)
    ]

    @enter key(:enter)

    def text_field(model, target, event, confirm, cancel) do

        case event do
            %{key: @enter} ->
                text = Enum.reduce(target, model, fn key, acc -> Map.fetch!(acc, key) end)
                confirm.(text)
            %{key: key} when key in @delete_keys ->
                rec_update(model, target, fn text -> String.slice(text, 0..-2)  end)
            %{ch: ch} when ch > 0 ->
                rec_update(model, target, fn text -> text <> <<ch::utf8>> end)
            %{key: @spacebar} ->
                rec_update(model, target, fn text -> text <> " " end)
            _ -> model
        end

    end

    defp rec_update(map, [key], update_callback) do
        Map.update!(map, key, update_callback)
    end

    defp rec_update(map, [key | remaining], update_callback) do
        target = Map.fetch!(map, key)
        part = rec_update(target, remaining, update_callback )
        Map.update!( map, key, fn _ -> part end)
    end



    def chatroom(model, key) do
        case key do
            @arrow_up -> %{model | chatroom_ui: %{ model.chatroom_ui | message_cursor: max(0, model.chatroom_ui.message_cursor - 1)}}
            @arrow_down -> %{model | chatroom_ui: %{ model.chatroom_ui | message_cursor: model.chatroom_ui.message_cursor + 1}}
            @ctrl_e -> %{model | chatroom_ui: %{ model.chatroom_ui | message_field: ""}}
        end
    end


    def landing(model, event) do

        case {model.connection_choice, event} do
            {_ , %{key: @ctrl_e}} ->
                # Undo connection_choice and clear fields.
                default_ui = %{input_field: "", error_message: "", input_cursor: 0, input_options:
                    [
                    {"Create a New Chatroom", :new_chatroom},
                    {"Restart a Chatroom", :restart_chatroom},
                    {"Connect to New Chatroom", :new_remote_connection},
                    {"Connect to Visited Chatroom", :reestablish_connection}
                    ]
                }
                %{ model | connection_choice: nil, landing_ui: default_ui}
            {nil, event} ->
                # Make conncetion_choice
                select_submenu = fn (model, choice) ->
                    case choice do
                        :new_remote_connection ->
                            %{ model | connection_choice: choice}
                        :reestablish_connection ->
                            displayed_connections = 
                                model.past_connections
                                |> Enum.map(fn conn -> { "#{conn.chatroom_name} -- last visited #{conn.most_recent_visit}", conn.port} end)
                            %{ model | connection_choice: choice, landing_ui: %{ model.landing_ui | input_options: displayed_connections}}
                        :new_chatroom ->
                            %{ model | connection_choice: choice}
                        :restart_chatroom ->
                            displayed_chatrooms = 
                                model.owned_chatrooms
                                |> Enum.map(fn room -> { room.name, room.name } end)
                            %{ model | connection_choice: choice, landing_ui: %{ model.landing_ui | input_options: displayed_chatrooms}}
                        _ -> model
                    end
                end
                list_select(model, event, select_submenu)
            {:new_remote_connection, event} ->
                # Take address input


                text_field(model, [:landing_ui, :input_field], event, nil, nil)
            {:reestablish_connection, event} ->
                # Pick remote address
                # What happens if the remote address is hosting a connection, but not the same chatroom?

                # Add callback
                list_select(model, event, nil)
            {:new_chatroom, event} ->
                # Name new chatroom

                text_field(model, [:landing_ui, :input_field], event, nil, nil)
            {:restart_chatroom, event} ->
                # Pick chatroom to open

                # Add callback
                list_select(model, event, nil)
            _ -> model
        end
    end

    defp list_select(model, event, callback) do
        case event do
            %{key: @arrow_up} ->
                new_cursor = if (model.landing_ui.input_cursor == 0), do: length(model.landing_ui.input_options) - 1, else: new_cursor =  model.landing_ui.input_cursor - 1
                %{ model | landing_ui: %{ model.landing_ui | input_cursor: new_cursor}}
            %{key: @arrow_down} ->
                new_cursor = rem(model.landing_ui.input_cursor + 1, length(model.landing_ui.input_options))
                %{ model | landing_ui: %{ model.landing_ui | input_cursor: new_cursor}}
            %{key: @enter} ->
                { {_display, choice}, _remainder} = List.pop_at(model.landing_ui.input_options, model.landing_ui.input_cursor)
                reset_model = %{ model | landing_ui: %{ model.landing_ui | input_cursor: 0, input_options: [] }}
                callback.(reset_model, choice)
            _ ->
                model
        end
    end
        
end