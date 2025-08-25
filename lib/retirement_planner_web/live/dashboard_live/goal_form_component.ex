defmodule RetirementPlannerWeb.DashboardLive.GoalFormComponent do
  use RetirementPlannerWeb, :live_component

  alias RetirementPlanner.Planning

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Set your retirement planning goals to get personalized projections</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="goal-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:current_age]}
          type="number"
          label="Current Age"
          min="18"
          max="100"
          required
        />
        <.input
          field={@form[:target_retirement_age]}
          type="number"
          label="Target Retirement Age"
          min="50"
          max="100"
          required
        />
        <.input
          field={@form[:desired_annual_income]}
          type="number"
          label="Desired Annual Income in Retirement"
          min="0"
          step="1000"
          required
          placeholder="e.g., 80000"
        />
        <.input
          field={@form[:inflation_rate]}
          type="number"
          label="Expected Annual Inflation Rate (%)"
          min="0"
          max="10"
          step="0.1"
          required
          placeholder="e.g., 2.5"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Goal</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{goal: goal} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Planning.change_retirement_goal(goal))
     end)}
  end

  @impl true
  def handle_event("validate", %{"retirement_goal" => goal_params}, socket) do
    changeset = Planning.change_retirement_goal(socket.assigns.goal, goal_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"retirement_goal" => goal_params}, socket) do
    save_goal(socket, socket.assigns.action, goal_params)
  end

  defp save_goal(socket, :edit_goal, goal_params) do
    case Planning.update_retirement_goal(socket.assigns.goal, goal_params) do
      {:ok, goal} ->
        notify_parent({:saved, goal})

        {:noreply,
         socket
         |> put_flash(:info, "Goal updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_goal(socket, :new_goal, goal_params) do
    goal_params_with_user = Map.put(goal_params, "user_id", socket.assigns.goal.user_id)

    case Planning.create_retirement_goal(goal_params_with_user) do
      {:ok, goal} ->
        notify_parent({:saved, goal})

        {:noreply,
         socket
         |> put_flash(:info, "Goal created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
