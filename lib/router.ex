defmodule ShellTasksServer.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    {:ok, response, _} = read_body(conn)
    tasks_sorted
    = Poison.decode!(response)["body"]["tasks"]
      |> Topological.sort
      |> Poison.encode!
    send_resp(conn, 200, tasks_sorted)
  end

  get "/shell-script" do
    send_resp(conn, 200, "soonTM")
  end

  match _ do
    send_resp(conn, 404, "Whoops!")
  end
end
