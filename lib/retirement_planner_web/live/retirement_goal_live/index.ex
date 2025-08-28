defmodule RetirementPlannerWeb.RetirementGoalLive.Index do
  use RetirementPlannerWeb, :live_view

  alias RetirementPlanner.Planning
  alias RetirementPlanner.Planning.RetirementGoal

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    retirement_goals = Planning.list_user_retirement_goals(current_user.id)
    {:ok, stream(socket, :retirement_goals, retirement_goals)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Retirement goal")
    |> assign(:retirement_goal, Planning.get_retirement_goal!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Retirement goal")
    |> assign(:retirement_goal, %RetirementGoal{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Retirement goals")
    |> assign(:retirement_goal, nil)
  end

  @impl true
  def handle_info(
        {RetirementPlannerWeb.RetirementGoalLive.FormComponent, {:saved, retirement_goal}},
        socket
      ) do
    {:noreply, stream_insert(socket, :retirement_goals, retirement_goal)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    retirement_goal = Planning.get_retirement_goal!(id)
    {:ok, _} = Planning.delete_retirement_goal(retirement_goal)

    {:noreply, stream_delete(socket, :retirement_goals, retirement_goal)}
  end
end
