defmodule RetirementPlannerWeb.RetirementGoalLive.Show do
  use RetirementPlannerWeb, :live_view

  alias RetirementPlanner.Planning

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:retirement_goal, Planning.get_retirement_goal!(id))}
  end

  defp page_title(:show), do: "Show Retirement goal"
  defp page_title(:edit), do: "Edit Retirement goal"
end
