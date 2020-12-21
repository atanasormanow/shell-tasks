defmodule ShellTasksServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :shell_tasks_server,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ShellTasksServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:plug_cowboy, "~> 2.4"}
    ]
  end
end
