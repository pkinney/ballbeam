defmodule BallBeamWeb.Components.Text do
  use Phoenix.Component

  def page_title(assigns) do
    ~H"""
    <header class="bg-white shadow">
      <div class="mx-auto max-w-7xl px-4 py-4 sm:px-4 lg:px-8">
        <h1 class="text-3xl font-bold tracking-tight text-gray-900"><%= @title %></h1>
      </div>
    </header>
    """
  end

  def body(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl py-2 sm:px-6 lg:px-8">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def heading(assigns) do
    ~H"""
    <div class="w-full">
      <h1 class="border-b border-b-gray-900 text-2xl font-bold tracking-tight text-gray-900">
        <%= render_slot(@inner_block) %>
      </h1>
    </div>
    """
  end

  def link_to(assigns) do
    ~H"""
    <a href={@href} class="text-indigo-600 hover:text-indigo-900"><%= render_slot(@inner_block) %></a>
    """
  end

  def dt(assigns) do
    ~H"""
    <div class="flex flex-row items-center space-x-2">
      <dt class=""><%= @label %></dt>:
      <dd class="flex-auto tabular-nums"><%= render_slot(@inner_block) %></dd>
    </div>
    """
  end
end
