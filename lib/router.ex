defmodule ShellTasksServer.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    {:ok, response, _} = read_body(conn)

    send_resp(conn, 200,
      Poison.decode!(response)["body"]["tasks"]
      |> Topological.sort(:list)
      |> Poison.encode!
    )
  end

  get "/shell-script" do
    {:ok, response, _} = read_body(conn)

    send_resp(conn, 200,
      Poison.decode!(response)["body"]["tasks"]
      |> Topological.sort(:command)
    )
  end

  match _ do
    send_resp(conn, 404, "Whoops!")
  end
end
