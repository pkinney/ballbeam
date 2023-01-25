defmodule BallBeamWeb.Home do
  use BallBeamWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(active: :controller)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.body>
      <div class="full flex flex-row divide-x divide-solid divide-slate-400">
        <div class="w-2/3 pr-8">
          <%= live_render(@socket, BallBeamWeb.BallBeam, id: "ball_beam") %>
        </div>
        <div class="w-1/3 pl-8">
          <.tabs>
            <.tab label="Manual" active={@active == :manual} click="manual" />
            <.tab label="Controller" active={@active == :controller} click="controller" />
          </.tabs>
          <%= case @active do %>
            <% :manual -> %>
              <%= live_render(@socket, BallBeamWeb.Manual, id: "manual") %>
            <% :controller -> %>
              <%= live_render(@socket, BallBeamWeb.Controller, id: "controller") %>
          <% end %>
        </div>
      </div>
    </.body>
    """
  end

  @impl true
  def handle_event("manual", _, socket), do: {:noreply, socket |> assign(active: :manual)}
  def handle_event("controller", _, socket), do: {:noreply, socket |> assign(active: :controller)}
end
