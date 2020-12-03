defmodule ShellTasksServerTest do
  use ExUnit.Case
  doctest ShellTasksServer

  test "greets the world" do
    assert ShellTasksServer.hello() == :world
  end
end
