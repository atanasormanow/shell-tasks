defmodule TopologicalSortTest do
  use ExUnit.Case

  import Topological

  setup_all do
    %{
      example0: [
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
      ],
      example1: [
        %{
          "name" => "a",
          "command" => "touch /tmp/file4",
          "requires" => [
            "b",
            "c",
            "d",
            "e"
          ]
        },
        %{
          "name" => "b",
          "command" => "touch /tmp/file3",
          "requires" => [
            "d"
          ]
        },
        %{
          "name" => "c",
          "command" => "touch /tmp/file3",
          "requires" => [
            "d",
            "e"
          ]
        },
        %{
          "name" => "d",
          "command" => "touch /tmp/file2",
          "requires" => [
            "e"
          ]
        },
        %{
          "name" => "e",
          "command" => "touch /tmp/file1"
        }
      ],
      example1_inversed: [
        %{
          "name" => "a",
          "command" => "cat /tmp/file1"
        },
        %{
          "name" => "b",
          "command" => "cat /tmp/file2",
          "requires" => [
            "a"
          ]
        },
        %{
          "name" => "c",
          "command" => "cat /tmp/file3",
          "requires" => [
            "a"
          ]
        },
        %{
          "name" => "d",
          "command" => "cat /tmp/file3",
          "requires" => [
            "a",
            "b",
            "c"
          ]
        },
        %{
          "name" => "e",
          "command" => "cat /tmp/file4",
          "requires" => [
            "d",
            "c",
            "a"
          ]
        }
      ]
    }
  end

  describe "Testing topological sorting of tasks from" do
    test "example 0 as list", context do
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

      assert sort(context.example0, :list) == output
    end

    test "example 0 as shell script string", context do
      output =
        Enum.join(
          [
            "#!/usr/bin/env bash\n",
            "touch /tmp/file1",
            "echo 'Hello World!' > /tmp/file1",
            "cat /tmp/file1",
            "rm /tmp/file1"
          ],
          "\n"
        )

      assert sort(context.example0, :commands) == output
    end

    test "example 1 as list", context do
      output = [
        %{
          name: "e",
          command: "touch /tmp/file1"
        },
        %{
          name: "d",
          command: "touch /tmp/file2"
        },
        %{
          name: "b",
          command: "touch /tmp/file3"
        },
        %{
          name: "c",
          command: "touch /tmp/file3"
        },
        %{
          name: "a",
          command: "touch /tmp/file4"
        }
      ]

      assert sort(context.example1, :list) == output
    end

    test "example 1 as shell script string", context do
      output =
        Enum.join(
          [
            "#!/usr/bin/env bash\n",
            "touch /tmp/file1",
            "touch /tmp/file2",
            "touch /tmp/file3",
            "touch /tmp/file3",
            "touch /tmp/file4"
          ],
          "\n"
        )

      assert sort(context.example1, :commands) == output
    end

    test "inversed example 1 as list", context do
      output = [
        %{
          name: "a",
          command: "cat /tmp/file1"
        },
        %{
          name: "b",
          command: "cat /tmp/file2"
        },
        %{
          name: "c",
          command: "cat /tmp/file3"
        },
        %{
          name: "d",
          command: "cat /tmp/file3"
        },
        %{
          name: "e",
          command: "cat /tmp/file4"
        }
      ]

      assert sort(context.example1_inversed, :list) == output
    end

    test "inversed example 1 as shell script string", context do
      output =
        Enum.join(
          [
            "#!/usr/bin/env bash\n",
            "cat /tmp/file1",
            "cat /tmp/file2",
            "cat /tmp/file3",
            "cat /tmp/file3",
            "cat /tmp/file4"
          ],
          "\n"
        )

      assert sort(context.example1_inversed, :commands) == output
    end
  end
end
