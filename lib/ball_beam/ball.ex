defmodule BallBeam.Ball do
  use GenServer

  @doc "used by DistanceSensor to update the ball position"
  @spec set_distance(float()) :: :ok
  def set_distance(distance), do: GenServer.cast(__MODULE__, {:set_distance, distance})

  @doc "Get the most recent to ball position"
  @spec get_distance() :: float()
  def get_distance(), do: GenServer.call(__MODULE__, :get_distance)

  @doc "Subscribe to ball position updates"
  @spec subscribe() :: :ok
  def subscribe(), do: Phoenix.PubSub.subscribe(BallBeam.PubSub, "ball")

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @impl true
  def init(:ok), do: {:ok, nil}

  @impl true
  def handle_cast({:set_distance, distance}, _) do
    :telemetry.execute(~w(ball_beam ball)a, %{distance: distance})
    Phoenix.PubSub.broadcast(BallBeam.PubSub, "ball", {:ball, distance})
    {:noreply, distance}
  end

  @impl true
  def handle_call(:get_distance, _, state), do: {:reply, state, state}
end
