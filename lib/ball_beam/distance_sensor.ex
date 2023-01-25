defmodule BallBeam.DistanceSensor do
  use GenServer
  alias TMF882X.Result
  require Logger

  # Low-pass filter for ball position, set to 1 to bypass
  @alpha 1.0

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @impl true
  def init(:ok) do
    {:ok, pid} = TMF882X.start_link(bus: "i2c-1")
    {:ok, %{pid: pid, last_dist: nil}}
  end

  @impl true
  def handle_info({:tmf882x, %Result{} = result}, state) do
    distance =
      result.measurements
      |> Enum.at(4)
      |> case do
        {distance, confidence} when confidence > 128 -> distance
        _ -> nil
      end
      |> convert_distance()
      |> filter_distance(state.last_dist)

    BallBeam.Ball.set_distance(distance)
    {:noreply, %{state | last_dist: distance}}
  end

  defp convert_distance(nil), do: nil
  defp convert_distance(d), do: d * 0.09621372525 + 2.620500685
  defp filter_distance(reading, nil), do: reading
  defp filter_distance(reading, last_dist), do: last_dist + @alpha * (reading - last_dist)
end
