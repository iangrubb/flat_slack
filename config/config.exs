# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

import Config

config :flat_slack_server, FlatSlackServer.Repo,
  adapter: Sqlite.Ecto2,
  database: "flat_slack_server.sqlite3",
  loggers: []
  

config :flat_slack_server, ecto_repos: [FlatSlackServer.Repo]


config :flat_slack_client, FlatSlackClient.Repo,
  adapter: Sqlite.Ecto2,
  database: "flat_slack_client.sqlite3",
  loggers: []

config :flat_slack_client, ecto_repos: [FlatSlackClient.Repo]