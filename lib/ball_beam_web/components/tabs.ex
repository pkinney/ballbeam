defmodule BallBeamWeb.Components.Tabs do
  use Phoenix.Component

  def tabs(assigns) do
    ~H"""
    <div class="border-b border-gray-200">
      <nav class="-mb-px flex space-x-8" aria-label="Tabs">
        <%= render_slot(@inner_block) %>
      </nav>
    </div>
    """
  end

  def tab(%{active: true} = assigns) do
    ~H"""
    <a
      href="#"
      phx-click={@click}
      class="whitespace-nowrap border-b-2 border-indigo-500 px-1 py-2 text-sm font-medium text-indigo-600"
    >
      <%= @label %>
    </a>
    """
  end

  def tab(assigns) do
    ~H"""
    <a
      href="#"
      phx-click={@click}
      class="whitespace-nowrap border-b-2 border-transparent px-1 py-2 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
    >
      <%= @label %>
    </a>
    """
  end
end
