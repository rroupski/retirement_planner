defmodule RetirementPlannerWeb.RetirementGoalLive.FormComponent do
  use RetirementPlannerWeb, :live_component

  alias RetirementPlanner.Planning

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage retirement_goal records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="retirement_goal-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:target_retirement_age]} type="number" label="Target retirement age" />
        <.input field={@form[:desired_annual_income]} type="number" label="Desired annual income" step="any" />
        <.input field={@form[:current_age]} type="number" label="Current age" />
        <.input field={@form[:inflation_rate]} type="number" label="Inflation rate" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Retirement goal</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{retirement_goal: retirement_goal} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Planning.change_retirement_goal(retirement_goal))
     end)}
  end

  @impl true
  def handle_event("validate", %{"retirement_goal" => retirement_goal_params}, socket) do
    changeset = Planning.change_retirement_goal(socket.assigns.retirement_goal, retirement_goal_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"retirement_goal" => retirement_goal_params}, socket) do
    save_retirement_goal(socket, socket.assigns.action, retirement_goal_params)
  end

  defp save_retirement_goal(socket, :edit, retirement_goal_params) do
    case Planning.update_retirement_goal(socket.assigns.retirement_goal, retirement_goal_params) do
      {:ok, retirement_goal} ->
        notify_parent({:saved, retirement_goal})

        {:noreply,
         socket
         |> put_flash(:info, "Retirement goal updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_retirement_goal(socket, :new, retirement_goal_params) do
    # Add current user ID to the params
    retirement_goal_params_with_user = Map.put(retirement_goal_params, "user_id", socket.assigns.current_user.id)
    
    case Planning.create_retirement_goal(retirement_goal_params_with_user) do
      {:ok, retirement_goal} ->
        notify_parent({:saved, retirement_goal})

        {:noreply,
         socket
         |> put_flash(:info, "Retirement goal created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
