defmodule WeatherApp.DBSetup do
  alias WeatherApp.Repo

  def setup do
    # Check if the database exists
    case Repo.__adapter__.storage_up(Repo.config) do
      :ok ->
        IO.puts("Database created successfully")
      {:error, :already_up} ->
        IO.puts("Database already exists")
      {:error, term} ->
        IO.puts("Error creating database: #{inspect(term)}")
        System.halt(1)
    end

    # Run migrations
    case run_migrations() do
      {:ok, _, _} ->
        IO.puts("Migrations completed successfully")
      {:error, {_, reason}, _} ->
        IO.puts("Error running migrations: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp run_migrations do
    Ecto.Migrator.with_repo(Repo, &Ecto.Migrator.run(&1, :up, all: true))
  end
end