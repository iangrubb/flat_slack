defmodule FlatSlackClient.Views.Landing do

    import Ratatouille.View

    def render({width, height}, %{input_field: input_field, input_cursor: input_cursor, input_options: input_options}, remote_port, connection_choice) do
       
        


        view do

            viewport offset_x: -(div((width - 100), 2)) , offset_y: -(div((height - 8), 2)) do

                label(content: "Welcome to...")

                # 82 chars wide

                label(content: " ______   __         ______     ______         ______     __         ______     ______     __  __    ")
                label(content: "/\\  ___\\ /\\ \\       /\\  __ \\   /\\__  _\\       /\\  ___\\   /\\ \\       /\\  __ \\   /\\  ___\\   /\\ \\/ /    ")
                label(content: "\\ \\  __\\ \\ \\ \\____  \\ \\  __ \\  \\/_/\\ \\/       \\ \\___  \\  \\ \\ \\____  \\ \\  __ \\  \\ \\ \\____  \\ \\   \"-.   ")
                label(content: " \\ \\_\\    \\ \\_____\\  \\ \\_\\ \\_\\    \\ \\_\\        \\/\\_____\\  \\ \\_____\\  \\ \\_\\ \\_\\  \\ \\_____\\  \\ \\_\\ \\_\\ ")
                label(content: "  \\/_/     \\/_____/   \\/_/\\/_/     \\/_/         \\/_____/   \\/_____/   \\/_/\\/_/   \\/_____/   \\/_/\\/_/ ")
            
                viewport offset_x: -10, offset_y: -1 do
                    case {remote_port, connection_choice} do
                        {nil, :new_remote_connection} -> 
                            label(content: "Enter port")
                            # Case for entering address of chatroom you want to connect to
                        {nil, :reestablish_connection} ->
                            label(content: "Select remote chatroom")
                        {nil, :new_chatroom} -> 
                            label(content: "Enter chatroom name")
                            # Case for entering name of chatroom you just created
                        {nil, :restart_chatroom} ->
                            label(content: "Select local chatroom")
                        {nil, _}  ->
                            row do
                                column size: 6 do

                                    for {{text, _message}, index} <- Enum.with_index(input_options) do
                                        front = if index == input_cursor, do: ">" , else: " " 
                                        label(content: "#{front} #{index + 1}. #{text}") 
                                    end
                                    
                                end

                            end
                            
                            # Case for choosing a server to join.
                            # Subcases: find new remote chatroom, connect to past remote chatroom, reinitialize old chatroom, create new chatroom
                        {_, _} ->
                            # Case for entering your name to enter once remote connection is established
                            label(content: "Please enter your name: " <> input_field <> "▌")
                    end

                end
            end

        end

    end
end