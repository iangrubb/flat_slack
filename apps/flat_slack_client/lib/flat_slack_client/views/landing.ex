defmodule FlatSlack.Views.Landing do

    import Ratatouille.View

    def render({width, height}, %{input_field: input_field}, connected) do

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
                    case connected do
                        true -> label(content: "Please enter your name: " <> input_field <> "▌")
                        false -> label(content: "Attempting Connection")
                    end

                end
            end

        end

    end
end