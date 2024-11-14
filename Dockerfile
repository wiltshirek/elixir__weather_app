# Use an official Elixir runtime as a parent image
FROM elixir:latest

# Install PostgreSQL
RUN apt-get update && apt-get install -y postgresql postgresql-contrib

# Set up the app
WORKDIR /app
COPY . .

RUN mkdir -p priv/repo/migrations && \
    echo "defmodule WeatherApp.Repo.Migrations.CreateTemperaturesTable do\n\
  use Ecto.Migration\n\
  def change do\n\
    create_if_not_exists table(:temperatures) do\n\
      add :value, :float\n\
      add :timestamp, :utc_datetime\n\
      timestamps()\n\
    end\n\
  end\n\
end" > priv/repo/migrations/20240101000000_create_temperatures_table.exs


# Install hex package manager and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install mix dependencies
RUN mix deps.get

# Compile the project
RUN mix compile

# Set up the database
USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER weather_app WITH SUPERUSER PASSWORD 'password';" && \
    createdb -O weather_app weather_app_dev && \
    /etc/init.d/postgresql stop

# Switch back to root user
USER root

# Expose port 4000
EXPOSE 4000

# Create a startup script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Starting PostgreSQL..."\n\
service postgresql start\n\
echo "Setting up database..."\n\
mix ecto.create\n\
mix ecto.migrate\n\
echo "Starting web server..."\n\
elixir --sname weather_app -S mix run --no-halt\n\
' > /app/start.sh && chmod +x /app/start.sh

# Set the default command to run the startup script
CMD ["/app/start.sh"]