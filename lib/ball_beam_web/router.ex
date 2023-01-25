defmodule BallBeamWeb.Router do
  use BallBeamWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BallBeamWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BallBeamWeb do
    pipe_through :browser

    live "/", Home
  end

  scope "/" do
    pipe_through :browser

    live_dashboard "/dashboard", metrics: BallBeamWeb.Telemetry
  end
end
