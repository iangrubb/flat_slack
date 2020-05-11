defmodule FlatSlackServer do
  
  use Application

  def start(_types, _args) do

    children = [
      {FlatStackServer.ServerController, name: ServerController},
      {Task.Supervisor, name: ConnectionSupervisor},
      {Task, fn -> FlatSlackServer.ConnectionProvider.accept(4040) end}
    ]

    opts = [strategy: :one_for_one, name: FlatSlackServer.Supervisor]

    Supervisor.start_link(children, opts)

  end

  def stop(_state) do
    System.halt()
  end

end
