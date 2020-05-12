defmodule FlatSlackServer.Repo do
  use Ecto.Repo, otp_app: :flat_slack_server, adapter: Sqlite.Ecto2
end
