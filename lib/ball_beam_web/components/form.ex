defmodule BallBeamWeb.Components.Form do
  use Phoenix.Component

  def form_group(assigns) do
    ~H"""
    <div class="space-y-6 sm:space-y-5">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def form_field(assigns) do
    ~H"""
    <div class="w-full sm:grid sm:grid-cols-3 sm:items-start sm:pt-2">
      <label
        for="first-name"
        class="sm:col-span-2 block text-md font-bold text-gray-700 sm:mt-px sm:pt-2"
      >
        <%= @label %>
      </label>
      <div class="mt-1 sm:col-span-1 sm:mt-0 text-right">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  # def submit(assigns) do
  #   ~H"""
  #   <%= submit(@form, "Submit") %>
  #   """
  # end

  def form_input_classes(),
    do:
      "block w-full max-w-lg rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:max-w-xs sm:text-md"
end
