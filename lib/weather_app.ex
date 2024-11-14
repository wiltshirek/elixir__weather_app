defmodule WeatherApp do
  use Application

  def start(_type, _args) do
    children = [
      WeatherApp.Repo,
      {Plug.Cowboy, scheme: :http, plug: WeatherApp.Endpoint, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: WeatherApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end