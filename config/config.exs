import Config

config :weather_app, WeatherApp.Repo,
  database: "weather_app_dev",
  username: "weather_app",
  password: "password",
  hostname: "localhost",
  pool_size: 10

config :weather_app, ecto_repos: [WeatherApp.Repo]

config :logger, level: :info