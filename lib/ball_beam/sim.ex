defmodule BallBeam.Sim do
  use GenServer

  @tick_interval 10
  @t @tick_interval / 1000.0
  @ball_update_interval 100
  @min_x 2.5
  @max_x 27.2
  @bounce 0.4

  def command_beam_angle(angle), do: GenServer.cast(__MODULE__, {:command, angle})

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @impl true
  def init(:ok) do
    {:ok, _} = :timer.send_interval(@tick_interval, :tick)
    {:ok, _} = :timer.send_interval(@ball_update_interval, :update_ball)
    {:ok, %{beam_angle: 0.0, x: 10.0, xd: 0.0}}
  end

  @impl true
  def handle_info(:tick, state) do
    # 981 cm/s^2
    g = 980.665
    alpha = -1 * state.beam_angle * :math.pi() / 180.0
    xdd = 5 / 7 * g * alpha
    xd = state.xd + xdd * @t
    x = state.x + xd * @t

    cond do
      x <= @min_x -> {:noreply, %{state | x: @min_x, xd: -xd * @bounce}}
      x >= @max_x -> {:noreply, %{state | x: @max_x, xd: -xd * @bounce}}
      true -> {:noreply, %{state | x: x, xd: xd}}
    end
  end

  def handle_info(:update_ball, state) do
    :ok = BallBeam.Ball.set_distance(state.x)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:command, angle}, state) do
    {:noreply, %{state | beam_angle: angle}}
  end
end
