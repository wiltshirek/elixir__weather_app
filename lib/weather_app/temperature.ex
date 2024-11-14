defmodule WeatherApp.Temperature do
  use Ecto.Schema
  import Ecto.Changeset

  schema "temperatures" do
    field :value, :float
    field :timestamp, :utc_datetime

    timestamps()
  end

  def changeset(temperature, attrs) do
    temperature
    |> cast(attrs, [:value, :timestamp])
    |> validate_required([:value, :timestamp])
  end
end