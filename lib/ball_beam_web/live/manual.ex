defmodule BallBeamWeb.Manual do
  use BallBeamWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex w-full flex-col items-center justify-center">
      <div class="relative pt-4">
        <.form :let={f} for={:beam} phx-change="update">
          <%= range_input(f, :angle,
            class:
              "form-range manual-range h-64 w-2 appearance-none bg-transparent p-0 focus:shadow-none focus:outline-none focus:ring-0",
            style: "-webkit-appearance: slider-vertical",
            min: -4.5,
            max: 4.5,
            step: "any"
          ) %>
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update", %{"beam" => %{"angle" => angle_str}}, socket) do
    {angle, ""} = Float.parse(angle_str)
    :ok = BallBeam.Beam.command(angle)
    {:noreply, socket}
  end
end
