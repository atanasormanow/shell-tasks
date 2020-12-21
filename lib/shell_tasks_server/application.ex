defmodule ShellTasksServer.Application do
  use Application
  require Logger

  @port 4000

  def start(_type, _args) do
    children = [
      {
        Plug.Cowboy,
        scheme: :http, plug: ShellTasksServer.Router, port: @port
      }
    ]

    opts = [strategy: :one_for_one, name: ShellTasksServer.Supervisor]

    Logger.info("Starting server on port #{@port}")

    Supervisor.start_link(children, opts)
  end
end
