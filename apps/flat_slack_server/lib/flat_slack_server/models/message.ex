defmodule FlatSlackServer.Models.Message do
    use Ecto.Schema
    alias FlatSlackServer.Models.Chatroom

    schema "messages" do
        field :username, :string
        field :content, :string
        belongs_to :chatroom, Chatroom
        timestamps()
    end

end





    