defmodule BallBeam.Servo do
  use GenServer

  require Logger

  @doc """
  Command the servo to put the beam at the given angle.
  """
  @spec command_beam_angle(float()) :: :ok
  def command_beam_angle(beam_angle), do: GenServer.cast(__MODULE__, {:beam_angle, beam_angle})

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @impl true
  def init(:ok) do
    :timer.send_after(100, :connect)
    :timer.send_interval(100, :telem)
    {:ok, nil}
  end

  @impl true
  def handle_cast({:beam_angle, _}, nil), do: {:noreply, nil}

  def handle_cast({:beam_angle, beam_angle}, pid) do
    goal_position = beam_angle |> beam_angle_to_servo_angle()
    :ok = Robotis.write(pid, 1, :goal_position, goal_position)
    {:noreply, pid}
  end

  # Figure out what servo angle to set to achieve the given beam angle
  defp beam_angle_to_servo_angle(beam_angle) do
    # servo arm length
    a = 0.030
    # beam arm length
    c = 0.306
    alpha = beam_angle * :math.pi() / 180.0
    q = c * :math.sin(alpha) / a
    beta = q |> max(-1.0) |> min(1.0) |> :math.asin()
    beta * 180.0 / :math.pi() + 90
  end

  @impl true
  # Retry connection to servo until established
  def handle_info(:connect, nil) do
    port = Application.get_env(:ball_beam, :servo_port)
    Logger.info("[#{__MODULE__}] Attempting to connect to servo (#{inspect(port)})...")

    Robotis.start_link(uart_port: port, baud: 1_000_000)
    |> case do
      {:ok, pid} ->
        Logger.info("[#{__MODULE__}] Connected to servo")
        :ok = Robotis.write(pid, 1, :torque_enable, true)
        :ok = Robotis.write(pid, 1, :status_return_level, :ping_read)
        {:noreply, pid}

      e ->
        Logger.warning("[#{__MODULE__}] Unable to connect to servo: #{inspect(e)}")
        :timer.send_after(100, :connect)
        {:noreply, nil}
    end
  end

  def handle_info(:telem, pid) do
    {:ok, voltage} = Robotis.read(pid, 1, :present_input_voltage)
    {:ok, current} = Robotis.read(pid, 1, :present_current)
    {:ok, position} = Robotis.read(pid, 1, :present_position)

    :telemetry.execute(~w(servo)a, %{
      current: current,
      voltage: voltage,
      position: position
    })

    {:noreply, pid}
  end
end
