defmodule Dipex.Application do
  @moduledoc false

  use Application
  use Supervisor

  def start(_type, _args) do
    children = [
      DipexWeb.Endpoint,
      FlexStream
    ]

    opts = [strategy: :one_for_one, name: Dipex.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    DipexWeb.Endpoint.config_change(changed, removed)

    :ok
  end
end
