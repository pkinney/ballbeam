defmodule BallBeam.Controller do
  use GenServer

  def enable(), do: GenServer.cast(__MODULE__, :enable)
  def disable(), do: GenServer.cast(__MODULE__, :disable)
  def set_target(target), do: GenServer.cast(__MODULE__, {:set_target, target})
  def set_config(config), do: GenServer.cast(__MODULE__, {:set_config, config})
  def get_status(), do: GenServer.call(__MODULE__, :get_status)
  def subscribe(), do: Phoenix.PubSub.subscribe(BallBeam.PubSub, "controller")

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @impl true
  def init(:ok) do
    BallBeam.Ball.subscribe()
    {:ok, %{enabled: false, target: 15.0} |> load_config() |> put_pid()}
  end

  defp put_pid(state) do
    pid =
      PIDControl.new(
        [
          tau: 0.5,
          output_max: 4.5,
          output_min: -4.5,
          zero_d_on_set_point_change: true,
          use_system_t: true,
          telemetry: true
        ] ++ state.config
      )

    Map.put(state, :pid, pid)
  end

  @impl true
  def handle_info({:ball, distance}, %{enabled: true} = state) do
    pid = PIDControl.step(state.pid, state.target, distance)
    BallBeam.Beam.command(-pid.output)
    {:noreply, %{state | pid: pid} |> publish()}
  end

  def handle_info({:ball, _}, state), do: {:noreply, state}

  @impl true
  def handle_cast(:enable, state),
    do: {:noreply, %{state | enabled: true} |> put_pid() |> publish()}

  def handle_cast(:disable, state), do: {:noreply, %{state | enabled: false} |> publish()}

  def handle_cast({:set_target, target}, state),
    do: {:noreply, %{state | target: target} |> publish()}

  def handle_cast({:set_config, config}, state),
    do: {:noreply, %{state | config: config} |> store_config() |> put_pid() |> publish()}

  @impl true
  def handle_call(:get_status, _, state), do: {:reply, state, state}

  defp publish(state) do
    Phoenix.PubSub.broadcast(BallBeam.PubSub, "controller", {:controller, state})
    state
  end

  defp load_config(state), do: Map.put(state, :config, CubDB.get(:db, :pid_config, []))

  defp store_config(state) do
    CubDB.put(:db, :pid_config, state.config)
    state
  end
end
