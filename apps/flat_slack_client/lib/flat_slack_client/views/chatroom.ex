defmodule FlatSlackClient.Views.ChatRoom do

    import Ratatouille.View

    def render({width, height}, chatroom_ui, {messages, users, user_id}) do

        # top_bar: dash_bar, bottom_bar: dash_bar

        view do
        
            panel title: " // Flat Slack // ", height: :fill do

                row do

                    column size: 3 do

                        panel height: 6 do

                            label(content: "  Welcome to Flat Slack!")
                            label(content: "    Nice to have you " <> Enum.find(users, fn user -> user.id == user_id end).name)

                        end

                        panel title: "Controls ", height: 12, color: :black, background: :white do

                            label(content: "Erase current message")
                            label(content: "ctrl + e", color: :black, background: :white)
                            label(content: "    ")

                            label(content: "Scroll message history")
                            label(content: "arrowup / arrowdown", color: :black, background: :white)
                            label(content: "    ")

                            label(content: "Quit program")
                            label(content: "ctrl + c", color: :black, background: :white)
                            label(content: "    ")
                            
                        end

                        panel title: " Users Online ", height: height - 3 - 12 - 6, color: :black, background: :white do

                            for user <- Enum.filter(users, fn u -> u.active end) do
                               
                                label(content: user.name <> "\n")
                                
                            end

                        end

                    end

                    column size: 9 do

                        panel title: " New Message ", color: :black, background: :white do

                            label(content: chatroom_ui.message_field <> "▌", wrap: true)

                        end

                        panel title: " Message History ", color: :black, background: :white do

                            viewport(offset_y: chatroom_ui.message_cursor) do
                                label( content: "")
                                for message <- messages do

                                    case message.user_id do
                                        nil ->
                                            row do 
                                                column size: 9 do
                                                    label(content: " ")
                                                    label(content: " -- #{message.content} -- ", color: :black, background: :white)
                                                    label(content: " ")
                                                end
                                            end
                                        _   ->
                                            panel title: " #{message.username} " do
                                                label(content: message.content, wrap: true)
                                                label(content: " ")
                                            end
                                    end
                                    
                                end
                            end
                        end

                        

                    end


                end


            end

        end



    end


end