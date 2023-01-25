defmodule BallBeamWeb.Controller do
  use BallBeamWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    BallBeam.Controller.subscribe()
    {:ok, socket |> assign(status: BallBeam.Controller.get_status(), set_point: 15.0)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex w-full flex-col items-center justify-center">
      <div class="w-full grid grid-cols-3 items-center pt-2 mb-1">
        <p class="sm:col-span-2 block text-md font-bold text-gray-700 sm:mt-px sm:pt-2">
          PID Control
        </p>
        <div class="sm:col-span-1 sm:mt-0 text-right">
          <%= if @status.enabled do %>
            <.button label="Disable" click="disable" style="secondary" />
          <% else %>
            <.button label="Enable" click="enable" />
          <% end %>
        </div>
      </div>

      <%= if @status.enabled do %>
        <.form :let={f} for={:set_point} phx-change="changed" phx-submit="submit" class="w-full">
          <.form_field form={f} label="Set Point" field={:set_point}>
            <%= select(
              f,
              :set_point,
              [{"5", 5}, {"10", 10.0}, {"15", 15.0}, {"20", 20.0}, {"25", 25.0}],
              value: @status.pid.set_point_prev,
              class: [form_input_classes(), "text-right"]
            ) %>
          </.form_field>
        </.form>
        <div class="w-full grid grid-cols-3 items-center pt-2 mb-1">
          <p class="sm:col-span-2 block text-md font-bold text-gray-700 sm:mt-px sm:pt-2">
            Error
          </p>
          <div class="sm:col-span-1 sm:mt-0 text-right">
            <%= @status.pid.e0 |> format_error() %>
          </div>
        </div>
        <%= live_render(@socket, BallBeamWeb.Controller.Edit, id: "ball_beam_edit") %>
      <% else %>
      <% end %>
    </div>
    """
  end

  defp format_set_point(nil), do: "--"
  defp format_set_point(d), do: :erlang.float_to_binary(d, decimals: 0) <> " cm"
  defp format_error(nil), do: "--"
  defp format_error(err), do: :erlang.float_to_binary(err, decimals: 2) <> " cm"

  @impl true
  def handle_event("disable", _, socket) do
    BallBeam.Controller.disable()
    {:noreply, socket}
  end

  def handle_event("enable", _, socket) do
    BallBeam.Controller.enable()
    {:noreply, socket}
  end

  def handle_event("changed", %{"set_point" => %{"set_point" => set_str}}, socket) do
    {set, ""} = Float.parse(set_str)
    BallBeam.Controller.set_target(set)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:controller, status}, socket) do
    {:noreply, socket |> assign(status: status)}
  end
end
