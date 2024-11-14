defmodule WeatherApp.TemperatureOperations do
  alias WeatherApp.Repo
  alias WeatherApp.Temperature
  require Logger

  def insert_temperature do
    # Ensure all necessary applications are started
    {:ok, _} = Application.ensure_all_started(:hackney)
    {:ok, _} = Application.ensure_all_started(:httpoison)
    {:ok, _} = Application.ensure_all_started(:ecto)
    {:ok, _} = Application.ensure_all_started(:postgrex)

    # Debug: Print out all existing ETS tables
    Logger.debug("Existing ETS tables: #{inspect(:ets.all())}")

    # Start the Repo if it's not already started
    start_repo()

    # Debug: Print out all existing ETS tables again
    Logger.debug("ETS tables after Repo start: #{inspect(:ets.all())}")

    # Fetch temperature data
    case HTTPoison.get("http://localhost:4000/temperature") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        temperature = data["temperature"]
        timestamp = data["timestamp"]

        # Create changeset and insert into database
        changeset = Temperature.changeset(%Temperature{}, %{value: temperature, timestamp: timestamp})

        case Repo.insert(changeset) do
          {:ok, inserted_temp} ->
            Logger.info("Temperature #{temperature} at #{timestamp} inserted successfully")
            {:ok, inserted_temp}
          {:error, changeset} ->
            Logger.error("Error inserting temperature: #{inspect(changeset.errors)}")
            {:error, changeset.errors}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.error("Received unexpected status code: #{status_code}")
        {:error, :unexpected_status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Error fetching temperature: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def loop_insert do
    Enum.each(1..10, fn _ ->
      insert_temperature()
      Process.sleep(1000)
    end)

    count = Repo.aggregate(Temperature, :count, :id)
    Logger.info("Total rows in the temperatures table: #{count}")
  end

  defp start_repo do
    case Repo.start_link() do
      {:ok, pid} -> 
        Logger.debug("Repo started successfully")
        {:ok, pid}
      {:error, {:already_started, pid}} -> 
        Logger.debug("Repo was already started")
        {:error, {:already_started, pid}}
      error -> 
        Logger.error("Failed to start Repo: #{inspect(error)}")
        error
    end
  end
end