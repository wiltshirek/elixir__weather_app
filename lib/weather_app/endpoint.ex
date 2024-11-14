defmodule WeatherApp.Endpoint do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/temperature" do
    temperature = :rand.uniform() * 100 |> Float.round(2)
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{temperature: temperature, timestamp: timestamp}))
  end

  post "/temperature" do
    {:ok, body, conn} = read_body(conn)
    
    case Jason.decode(body) do
      {:ok, %{"temperature" => temperature, "timestamp" => timestamp}} ->
        changeset = WeatherApp.Temperature.changeset(%WeatherApp.Temperature{}, %{temperature: temperature, timestamp: timestamp})
        
        case WeatherApp.Repo.insert(changeset) do
          {:ok, _temperature} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Jason.encode!(%{message: "Temperature recorded successfully"}))
          
          {:error, changeset} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Jason.encode!(%{errors: changeset.errors}))
        end
      
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{error: "Invalid JSON payload"}))
    end
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(%{error: "Not found"}))
  end
end