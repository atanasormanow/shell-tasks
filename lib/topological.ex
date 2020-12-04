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
    sort(t_tasks, Map.keys(t_tasks), [])
  end

  # the order is reversed!
  defp sort(_tasks, [], result), do: result
  defp sort(tasks, [name | names], result) do
    case Kernel.get_in(tasks, [name, "requires"]) do

      nil -> sort(tasks, names, [name | result])

      deps ->
        case Enum.filter(
          deps,
          fn dep -> !Enum.member?(result, dep) end
        ) do

          [] -> sort(tasks, names, [name | result])

          filtered_deps ->
            filtered_deps
            |> List.foldl(
              result,
              fn dep, acc ->
                if Enum.member?(acc, dep) do
                  acc
                else
                  sort(tasks, [dep], acc)
                end
              end
            )
            |>
            (fn
              result -> sort(tasks, names -- result, [name | result])
            end).()
        end
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
