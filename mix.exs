defmodule WeatherApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :weather_app,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: true,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {WeatherApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.5"},
      {:jason, "~> 1.2"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0"},
      {:httpoison, "~> 1.8"}
    ]
  end
end