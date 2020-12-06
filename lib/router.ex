defmodule ShellTasksServer.Router do
  @moduledoc """
  A module for handling requests
  """

  alias Request.Verification

  use Plug.Router

  plug :match
  plug :dispatch

  post "/" do
    {:ok, response, _} = read_body(conn)
    IO.inspect(response)
    response_body = Poison.decode!(response)

    case validate_and_sort(response_body, :list) do

      {:error, msg} -> send_resp(conn, 400, msg)

      sorted_tasks ->
        send_resp(
          conn,
          200,
          Poison.encode!(sorted_tasks)
        )
    end
  end

  post "/shell-script" do
    {:ok, response, _} = read_body(conn)
    response_body = Poison.decode!(response)

    case validate_and_sort(response_body, :commands) do

      {:error, msg} -> send_resp(conn, 400, msg)

      sorted_tasks ->
        send_resp(
          conn,
          200,
          sorted_tasks
        )
    end
  end

  match _ do
    send_resp(conn, 404, "Whoops!")
  end

  defp validate_and_sort(body, opt) do
    with :ok <- Verification.verify_request_structure(body, ["name", "command"]),
         :ok <- Verification.verify_task_dependencies(body),
    do: Topological.sort(body["tasks"], opt)
  end
end
