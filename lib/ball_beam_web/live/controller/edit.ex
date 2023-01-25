defmodule BallBeamWeb.Controller.Edit do
  use BallBeamWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    BallBeam.Controller.subscribe()

    {:ok,
     socket
     |> assign(controller: BallBeam.Controller.get_status())
     |> put_changeset()}
  end

  defp put_changeset(socket) do
    socket
    |> assign(
      changeset: socket.assigns.controller.pid.config |> Map.take(~w(kp ki kd)a),
      changed: false
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-2 border-t border-t-gray-600">
      <.form :let={f} for={:controller} phx-change="changed" phx-submit="submit">
        <.form_field form={f} label="Kp" field={:kp}>
          <%= text_input(f, :kp, value: @changeset.kp, class: [form_input_classes(), "text-right"]) %>
        </.form_field>
        <.form_field form={f} label="Ki" field={:ki}>
          <%= text_input(f, :ki, value: @changeset.ki, class: [form_input_classes(), "text-right"]) %>
        </.form_field>
        <.form_field form={f} label="Kd" field={:kd}>
          <%= text_input(f, :kd, value: @changeset.kd, class: [form_input_classes(), "text-right"]) %>
          <%= if @changed do %>
            <div class="mt-4 w-full flex flex-row justify-end space-x-2 items-center">
              <.button label="Cancel" click="cancel" style="secondary" />
              <.button label="Submit" type="submit" />
            </div>
          <% end %>
        </.form_field>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("edit", _, socket) do
    {:noreply, socket |> assign(edit: true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, socket |> put_changeset()}
  end

  def handle_event(
        "changed",
        %{"controller" => changeset},
        socket
      ) do
    {:noreply, socket |> assign(changed: true, changeset: atomize_keys(changeset))}
  end

  def handle_event(
        "submit",
        %{"controller" => %{"kp" => kp_str, "ki" => ki_str, "kd" => kd_str}},
        socket
      ) do
    {kp, ""} = Float.parse(kp_str)
    {ki, ""} = Float.parse(ki_str)
    {kd, ""} = Float.parse(kd_str)

    BallBeam.Controller.set_config(kp: kp, ki: ki, kd: kd)
    {:noreply, socket |> assign(changed: false)}
  end

  @impl true
  def handle_info({:controller, status}, %{assigns: %{changed: false}} = socket) do
    {:noreply,
     socket
     |> assign(controller: status)
     |> put_changeset()}
  end

  def handle_info({:controller, status}, socket) do
    {:noreply,
     socket
     |> assign(controller: status)}
  end

  defp atomize_keys(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
