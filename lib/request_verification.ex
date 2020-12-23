defmodule Request.Verification do
  @moduledoc """
  A module for verifying the request body
  """

  @doc """
  Verify the body has the needed fields
  """
  def verify_request_structure(body, fields) do
    verified =
      is_map(body) && Map.has_key?(body, "tasks") && is_list(body["tasks"]) &&
        contains_fields?(body["tasks"], fields)

    if verified do
      :ok
    else
      {:error, "Invalid body structure"}
    end
  end

  @doc """
  Verify that all dependencies are available as tasks
  """
  def verify_task_dependencies(body) do
    tasks = body["tasks"]
    names = Enum.map(tasks, fn t -> t["name"] end)

    verified =
      tasks
      |> Enum.flat_map(fn t -> Map.get(t, "requires", []) end)
      |> Enum.all?(fn dep -> Enum.member?(names, dep) end)

    if verified do
      :ok
    else
      {:error, "Invalid task dependency"}
    end
  end

  defp contains_fields?(tasks, fields) do
    Enum.all?(
      tasks,
      fn
        t ->
          Enum.all?(
            fields,
            fn f -> Map.has_key?(t, f) end
          )
      end
    )
  end
end
