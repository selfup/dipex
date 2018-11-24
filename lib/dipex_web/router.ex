defmodule DipexWeb.Router do
  use DipexWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DipexWeb do
    pipe_through :api

    get("/", ApiController, :cmd)
  end
end
