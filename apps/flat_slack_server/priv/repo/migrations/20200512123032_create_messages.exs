defmodule FlatSlackServer.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do

    create table(:messages) do
      add :username, :string
      add :content, :string
      add :chatroom_id, references(:chatrooms)
      timestamps()
    end

  end
end
