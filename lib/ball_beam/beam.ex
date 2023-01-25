defmodule BallBeam.Beam do
  use GenServer

  @doc "Used to set the commanded beam angle"
  @spec command(float()) :: :ok
  def command(angle), do: GenServer.cast(__MODULE__, {:command, angle})

  @doc "Returns the most recent command"
  @spec get_command() :: float()
  def get_command(), do: GenServer.call(__MODULE__, :get_command)

  @spec subscribe() :: :ok
  def subscribe(), do: Phoenix.PubSub.subscribe(BallBeam.PubSub, "beam")

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @impl true
  def init(:ok) do
    {:ok, 0.0}
  end

  @impl true
  def handle_call(:get_command, _, command) do
    {:reply, command, command}
  end

  @impl true
  def handle_cast({:command, command}, _) do
    :ok = actuator().command_beam_angle(command)
    :telemetry.execute(~w(ball_beam beam)a, %{command: command})
    Phoenix.PubSub.broadcast(BallBeam.PubSub, "beam", {:beam, command})
    {:noreply, command}
  end

  defp actuator() do
    Application.get_env(:ball_beam, :actuator, BallBeam.Servo)
  end
end
