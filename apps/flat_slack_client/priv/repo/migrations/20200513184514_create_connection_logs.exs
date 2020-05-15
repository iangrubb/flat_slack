defmodule FlatSlackClient.Repo.Migrations.CreateConnectionLogs do
  use Ecto.Migration

  def change do
    create table(:connection_logs) do
      add :chatroom_name, :string
      add :port, :string
      add :most_recent_visit, :string
      timestamps()
    end

  end
end
