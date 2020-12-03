defmodule Topological do
  @moduledoc """
  A module for sorting tasks
  """

  # TODO: typespecs
  # TODO: should work with:
  # - cyclic dependencies
  # - invalid dependencies (TODO: validate)

  def sort(tasks) do
    t_tasks = transform(tasks)
    sort(t_tasks, Map.keys(t_tasks))
  end

  defp sort(tasks, []), do: []
  defp sort(tasks, t_names) do
    [t | t_names_rest] = t_names
    case Kernel.get_in(tasks, [t, "requires"]) do
      nil ->  [t | sort(tasks, t_names_rest)]
      deps -> Enum.filter(
          deps,
          &(Enum.member?(t_names, &1)))
          ++ [t | sort(tasks, t_names_rest -- deps)]
    end
  end

  defp transform(tasks_from_response) do
    Map.new(
      tasks_from_response,
      fn task -> {
        task["name"],
        Map.drop(task, ["name"])
      } end
    )
  end

  #########
  # INPUT #
  #########

  #%{
  #  "task-1" => %{"command" => "touch /tmp/file1"},
  #  "task-2" => %{"command" => "cat /tmp/file1", "requires" => ["task-3"]},
  #  "task-3" => %{
  #    "command" => "echo 'Hello World!' > /tmp/file1",
  #    "requires" => ["task-1"]
  #  },
  #  "task-4" => %{
  #    "command" => "rm /tmp/file1",
  #    "requires" => ["task-2", "task-3"]
  #  }
  #}

end
