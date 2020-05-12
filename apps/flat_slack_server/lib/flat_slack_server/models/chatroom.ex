defmodule FlatSlackServer.Models.Chatroom do
    use Ecto.Schema
    alias FlatSlackServer.Models.Message

    schema "chatrooms" do
        has_many :messages, Message
        field :name, :string
        timestamps()
    end

end