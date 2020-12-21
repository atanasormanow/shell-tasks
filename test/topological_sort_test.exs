defmodule TopologicalSortTest do
  use ExUnit.Case

  import Topological

  describe "Testing as list" do
    test "example 0" do
      input = [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1"
        },
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => [
            "task-3"
          ]
        },
        %{
          "name" => "task-3",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => [
            "task-1"
          ]
        },
        %{
          "name" => "task-4",
          "command" => "rm /tmp/file1",
          "requires" => [
            "task-2",
            "task-3"
          ]
        }
      ]

      output = [
        %{
          name: "task-1",
          command: "touch /tmp/file1"
        },
        %{
          name: "task-3",
          command: "echo 'Hello World!' > /tmp/file1"
        },
        %{
          name: "task-2",
          command: "cat /tmp/file1"
        },
        %{
          name: "task-4",
          command: "rm /tmp/file1"
        }
      ]

      assert sort(input, :list) == output
    end
  end
end
