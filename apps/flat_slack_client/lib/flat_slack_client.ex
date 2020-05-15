defmodule FlatSlackClient do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Options for the Ratatouille runtime    
    runtime_opts = [
      app: FlatSlackClient.Interface,
      shutdown: {:application, :flat_slack_client},
      interval: 200
    ]

    children = [
      FlatSlackClient.Repo,
      {FlatSlackClient.Messenger, name: Messenger},
      {Ratatouille.Runtime.Supervisor, name: Runtime, runtime: runtime_opts}
    ]

    opts = [strategy: :one_for_one, name: FlatSlackClient.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop(_state) do
    # Do a hard shutdown after the application has been stopped.
    System.halt()
  end
end
