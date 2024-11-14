# lib/weather_app/repo.ex
defmodule WeatherApp.Repo do
  use Ecto.Repo,
    otp_app: :weather_app,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    config = Keyword.merge(config, [
      database: "weather_app_dev",
      username: "weather_app",
      password: "password",
      hostname: "localhost"
    ])
    {:ok, config}
  end
end