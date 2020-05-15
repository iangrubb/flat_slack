defmodule FlatSlackClient.ConnectionLog do

    use Ecto.Schema

    schema "connection_logs" do
        field :chatroom_name, :string
        field :port, :string
        field :most_recent_visit, :string
        timestamps()
    end

end