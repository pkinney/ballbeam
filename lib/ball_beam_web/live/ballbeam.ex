defmodule BallBeamWeb.BallBeam do
  use BallBeamWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    BallBeam.Ball.subscribe()
    BallBeam.Beam.subscribe()
    BallBeam.Controller.subscribe()

    {:ok,
     socket
     |> assign(
       ball_distance: BallBeam.Ball.get_distance(),
       beam_angle: BallBeam.Beam.get_command(),
       controller: BallBeam.Controller.get_status()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <svg
      class="aspect-[80/25] w-full text-blue-600"
      viewbox="0 0 800 250"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <linearGradient x1="50%" y1="50.034%" x2="10%" y2="7.2%" id="grad1">
          <stop offset="0%" stop-color="currentColor" />
          <stop stop-opacity="0" offset="100%" stop-color="white" />
        </linearGradient>
      </defs>
      <g fill-rule="nonzero" fill="none">
        <path d="M 0,250 h90 l-45,-100 z" class="fill-slate-400"></path>
        <g
          transform={"rotate(#{-@beam_angle} 45 150)"}
          class={[@controller.enabled && "transition-all"]}
        >
          <circle
            class="fill-blue-600 transition-all"
            cx="0"
            cy="100"
            r="20"
            transform={"translate(#{@ball_distance |> ball_distance_to_screen_y()})"}
            }
          />
          <path d="M 45,150 h755 v-30 h-755 z" class="fill-slate-800"></path>
          <%= if @controller.enabled do %>
            if @controller.enabled
            <path
              d="M -12,145 h24 l-12,-22 z"
              class="fill-green-500 transition-all"
              transform={"translate(#{@controller.pid.set_point_prev |> ball_distance_to_screen_y()})"}
            />
          <% end %>
        </g>
      </g>
    </svg>
    <div class="mt-4 flex flex-row items-center justify-between text-2xl">
      <.dt label="Beam Angle"><%= @beam_angle |> format_angle() %></.dt>
      <.dt label="Position"><%= @ball_distance |> format_distance() %></.dt>
    </div>
    """
  end

  defp format_distance(nil), do: "--"
  defp format_distance(dist), do: :erlang.float_to_binary(dist, decimals: 1) <> "cm"

  defp format_angle(nil), do: "--"
  defp format_angle(dist) when not is_float(dist), do: format_angle(dist / 1)
  defp format_angle(dist), do: :erlang.float_to_binary(dist, decimals: 1) <> "deg"

  defp ball_distance_to_screen_y(dist) do
    screen_start = 40
    screen_beam_length = 755
    screen_radius = 20
    ball_start = 2.5
    ball_end = 28
    scale = (screen_beam_length - screen_radius * 2) / (ball_end - ball_start)
    screen_start + screen_radius + scale * (dist - ball_start)
  end

  @impl true
  def handle_info({:ball, distance}, socket) do
    {:noreply, socket |> assign(ball_distance: distance)}
  end

  def handle_info({:beam, angle}, socket) do
    {:noreply, socket |> assign(beam_angle: angle)}
  end

  def handle_info({:controller, controller}, socket) do
    {:noreply, socket |> assign(controller: controller)}
  end
end
