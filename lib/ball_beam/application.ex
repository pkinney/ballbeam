defmodule BallBeam.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Telemetry supervisor
        BallBeamWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: BallBeam.PubSub},
        # Start the Endpoint (http/https)
        BallBeamWeb.Endpoint,
        # Start a worker by calling: BallBeam.Worker.start_link(arg)
        {CubDB, data_dir: Application.get_env(:ball_beam, :cubdb_dir), name: :db},
        BallBeam.Beam,
        BallBeam.Ball,
        BallBeam.Controller
      ] ++ children(target())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BallBeam.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      BallBeam.Sim
    ]
  end

  def children(_target) do
    [
      BallBeam.Servo,
      BallBeam.DistanceSensor
    ]
  end

  def target() do
    Application.get_env(:ball_beam, :target)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BallBeamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
