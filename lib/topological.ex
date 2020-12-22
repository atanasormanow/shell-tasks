defmodule Topological do
  @moduledoc """
  A module for sorting tasks
  """

  @doc """
  The sort function sorts tasks topologically.
  Depending on the opt value, the tasks would have the following format:
    :list - a list of tasks containing a "name" and a "command" field
    :commands - a string of the commands representing a bash script
              (shebang included)
  """
  def sort(tasks, opt) do
    t_tasks = transform(tasks)

    sorted_names =
      t_tasks
      |> sort(Map.keys(t_tasks), [])
      |> Enum.reverse()

    case opt do
      :list -> task_list(t_tasks, sorted_names)
      :commands -> task_commands(t_tasks, sorted_names)
      _ -> {:error, "invalid option"}
    end
  end

  defp task_list(tasks, task_names) do
    task_names
    |> Enum.map(fn task_name ->
      %{
        name: task_name,
        command: tasks[task_name]["command"]
      }
    end)
  end

  defp task_commands(tasks, task_names) do
    shebang = "#!/usr/bin/env bash"

    task_commands =
      task_names
      |> Enum.map(fn task_name -> tasks[task_name]["command"] end)
      |> Enum.join("\n")

    shebang <> "\n\n" <> task_commands
  end

  # TODO sort should detect cyclic dependencies

  # NOTE the tasks have to form a DAG, in case there is a cycle
  # sort wont be able to detect it, and will act as if the loop point
  # was just an already processed dependency

  # NOTE both detecting a cycle and doing a topological sort use DFS.
  # Therefore with enough memmory it is possible to do both
  # with a single traversal.

  # Returns the names of the sorted tasks, but in reversed order
  defp sort(_tasks, [], result), do: result

  defp sort(tasks, [name | names], result) do
    case Kernel.get_in(tasks, [name, "requires"]) do
      # no dependencies -> add to result and continue
      nil ->
        sort(tasks, names, [name | result])

      # get deps that are not in result
      deps ->
        case Enum.filter(
               deps,
               fn dep -> !Enum.member?(result, dep) end
             ) do
          # no dependencies -> add to result and continue
          [] ->
            sort(tasks, names, [name | result])

          filtered_deps ->
            processed_deps =
              filtered_deps
              # process deps separately, keep result in acc
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

            # add current name dep to result
            # remove current call's result from the names
            sort(tasks, names -- processed_deps, [name | processed_deps])
        end
    end
  end

  defp transform(tasks_from_response) do
    Map.new(
      tasks_from_response,
      fn task ->
        {
          task["name"],
          Map.drop(task, ["name"])
        }
      end
    )
  end
end
