defmodule RequestVerificationTest do
  use ExUnit.Case

  import RequestVerification

  describe "Testing whether the request has a proper structure" do
    test "with valid structure" do
      input = %{
        "tasks" => [
          %{
            "name" => "task-1",
            "command" => "echo 'Hello World!' >> /tmp/hello",
            "requires" => [
              "task-2"
            ]
          },
          %{
            "name" => "task-2",
            "command" => "touch /tmp/hello",
          }
        ]
      }

      assert verify_request_structure(input, ["name", "command"]) == :ok
    end

    test "with invalid structure" do
      input = %{
        "tasks" => [
          %{
            "name" => "task-1",
            "requires" => [
              "task-2"
            ]
          },
          %{
            "name" => "task-2",
            "command" => "touch /tmp/hello",
          }
        ]
      }

      assert verify_request_structure(input, ["name", "command"]) == {:error, "Invalid body structure"}
    end
  end


  describe "Testing whether all dependencies are included as tasks" do
    test "with valid dependencies" do
      input = %{
        "tasks" => [
          %{
            "name" => "task-1",
            "command" => "echo 'Hello World!' >> /tmp/hello",
            "requires" => [
              "task-2"
            ]
          },
          %{
            "name" => "task-2",
            "command" => "touch /tmp/hello",
          }
        ]
      }

      assert verify_task_dependencies(input) == :ok
    end

    test "with invalid dependencies" do
      input = %{
        "tasks" => [
          %{
            "name" => "task-1",
            "command" => "echo 'Hello World!' > /tmp/hello",
            "requires" => [
              "task-2"
            ]
          }
        ]
      }

      assert verify_task_dependencies(input) == {:error, "Invalid task dependency"}
    end
  end
end
