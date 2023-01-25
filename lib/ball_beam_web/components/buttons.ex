defmodule BallBeamWeb.Components.Button do
  use Phoenix.Component

  attr :label, :string, required: true
  attr :click, :string, default: ""
  attr :data, :string, default: ""
  attr :style, :string, default: "primary"
  attr :type, :string, default: "button"

  def button(assigns) do
    ~H"""
    <button
      phx-click={@click}
      phx-value-data={@data}
      type={@type}
      class={[
        "inline-flex items-center rounded border border-transparent px-2.5 py-1.5 text-xs font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2",
        class_for_style(@style)
      ]}
    >
      <%= @label %>
    </button>
    """
  end

  defp class_for_style("primary"),
    do: "bg-indigo-600 text-white hover:bg-indigo-700 focus:transparent "

  defp class_for_style("secondary"),
    do: "bg-indigo-100 text-indigo-700 hover:bg-indigo-200 focus:none "

  defp class_for_style("white"),
    do: "bg-white text-gray-700 hover:bg-gray-50 focus:none "
end
