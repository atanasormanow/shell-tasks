defmodule Topological do
  @moduledoc """
  A module for sorting tasks
  """

  # TODO: typespecs
  # TODO: should work with:
  # - cyclic dependencies
  # - invalid dependencies (TODO: validate)

  def sort(tasks, opt \\ :list) do
    t_tasks = transform(tasks)

    sort(t_tasks, Map.keys(t_tasks), [])
    |> Enum.reverse
    |> (fn task_names ->
      case opt do
        :list -> task_list(t_tasks, task_names)
        :command -> task_commands(t_tasks, task_names)
        _ -> {:error, "invalid option" }
      end
    end).()
  end

  defp task_list(tasks, task_names) do
    task_names
    |> Enum.map(
      fn task_name ->
        %{
          name: task_name,
          command: tasks[task_name]["command"]
        }
      end
    )
  end

  defp task_commands(tasks, task_names) do
    shebang = "#!/usr/bin/env bash"

    task_names
    |> Enum.map( fn task_name -> tasks[task_name]["command"] end)
    |> Enum.join("\n")
    |> (fn commands -> shebang <> "\n" <> commands end).()
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

end
