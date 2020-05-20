defmodule FlatSlackClient.Views.Landing do

    import Ratatouille.View

    def render({width, height}, %{input_field: input_field, input_cursor: input_cursor, input_options: input_options, error_message: error_message}, remote_port, connection_choice) do
       
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
                            row do
                                column size: 6 do
                                    label(content: "Enter the network address of the remote chatroom:")
                                    label(content: "")
                                    label(content: input_field <> "▌", wrap: true)
                                end
                            end
                            
                        {nil, :reestablish_connection} ->
                            row do
                                column size: 6 do
                                    label(content: "Select a remote chatroom to attempt to join:")
                                    label(content: "")
                                    for {{text, _message}, index} <- Enum.with_index(input_options) do
                                        front = if index == input_cursor, do: ">" , else: " " 
                                        label(content: "#{front} #{index + 1}. #{text}") 
                                    end     
                                end
                            end

                        {nil, :new_chatroom} -> 

                            row do
                                column size: 6 do
                                    label(content: "Create a name for your new chatroom:")
                                    label(content: "")
                                    label(content: input_field <> "▌", wrap: true)
                                end

                            end
                            
                        {nil, :restart_chatroom} ->
                            label(content: "Select local chatroom to restart:")
                            row do
                                column size: 6 do
                                    for {{text, _message}, index} <- Enum.with_index(input_options) do
                                        front = if index == input_cursor, do: ">" , else: " " 
                                        label(content: "#{front} #{index + 1}. #{text}") 
                                    end
                                end
                            end

                        {nil, _}  ->
                            row do
                                column size: 6 do

                                    label(content: "")
                                    label(content: error_message)
                                    label(content: "")
                                    label(content: "Please select an option to join a chat:")
                                    label(content: "")
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