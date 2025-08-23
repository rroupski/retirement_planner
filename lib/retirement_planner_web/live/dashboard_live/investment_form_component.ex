defmodule RetirementPlannerWeb.DashboardLive.InvestmentFormComponent do
  use RetirementPlannerWeb, :live_component

  alias RetirementPlanner.Planning
  alias RetirementPlanner.Planning.Investment

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Define your investment allocations for more accurate projections</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="investment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:name]}
          type="text"
          label="Investment Name"
          required
          placeholder="e.g., S&P 500 Index Fund"
        />
        
        <.input
          field={@form[:symbol]}
          type="text"
          label="Symbol (Optional)"
          placeholder="e.g., VOO, VTSAX"
        />
        
        <.input
          field={@form[:allocation_percentage]}
          type="number"
          label="Allocation Percentage (%)"
          min="0.1"
          max="100"
          step="0.1"
          required
          placeholder="e.g., 70"
        />
        
        <.input
          field={@form[:expected_return]}
          type="number"
          label="Expected Annual Return (%)"
          min="0"
          max="30"
          step="0.1"
          required
          placeholder="e.g., 7.5"
        />
        
        <.input
          field={@form[:risk_level]}
          type="select"
          label="Risk Level"
          prompt="Choose risk level"
          options={[
            {"Low", "Low"},
            {"Medium", "Medium"},
            {"High", "High"}
          ]}
          required
        />
        
        <div class="mt-4 p-4 bg-blue-50 rounded-lg">
          <h4 class="text-sm font-medium text-blue-900 mb-2">Investment Guidelines:</h4>
          <ul class="text-sm text-blue-700 space-y-1">
            <li>• <strong>Stocks/Equity Funds:</strong> Typically 6-10% expected return, Medium-High risk</li>
            <li>• <strong>Bonds/Bond Funds:</strong> Typically 2-5% expected return, Low-Medium risk</li>
            <li>• <strong>Index Funds:</strong> Typically 7-9% expected return, Medium risk</li>
            <li>• <strong>Target Date Funds:</strong> Typically 6-8% expected return, Medium risk</li>
          </ul>
        </div>
        
        <:actions>
          <.button phx-disable-with="Saving...">Save Investment</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{investment: investment} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Planning.change_investment(investment))
     end)}
  end

  @impl true
  def handle_event("validate", %{"investment" => investment_params}, socket) do
    changeset = Planning.change_investment(socket.assigns.investment, investment_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"investment" => investment_params}, socket) do
    save_investment(socket, socket.assigns.action, investment_params)
  end

  defp save_investment(socket, :edit_investment, investment_params) do
    case Planning.update_investment(socket.assigns.investment, investment_params) do
      {:ok, investment} ->
        notify_parent({:saved, investment})

        {:noreply,
         socket
         |> put_flash(:info, "Investment updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_investment(socket, :new_investment, investment_params) do
    investment_params_with_user = Map.put(investment_params, "user_id", socket.assigns.investment.user_id)
    
    case Planning.create_investment(investment_params_with_user) do
      {:ok, investment} ->
        notify_parent({:saved, investment})

        {:noreply,
         socket
         |> put_flash(:info, "Investment created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
