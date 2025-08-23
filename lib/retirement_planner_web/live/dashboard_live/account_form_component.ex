defmodule RetirementPlannerWeb.DashboardLive.AccountFormComponent do
  use RetirementPlannerWeb, :live_component

  alias RetirementPlanner.Planning
  alias RetirementPlanner.Planning.RetirementAccount

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Add your retirement accounts to track your current savings</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="account-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:name]}
          type="text"
          label="Account Name"
          required
          placeholder="e.g., My 401(k) at Company X"
        />
        
        <.input
          field={@form[:account_type]}
          type="select"
          label="Account Type"
          prompt="Choose account type"
          options={[
            {"401(k)", "401k"},
            {"403(b)", "403b"},
            {"Traditional IRA", "IRA"},
            {"Roth IRA", "Roth IRA"},
            {"SEP-IRA", "SEP-IRA"},
            {"Simple IRA", "Simple IRA"},
            {"Pension", "Pension"},
            {"Other", "Other"}
          ]}
          required
        />
        
        <.input
          field={@form[:current_balance]}
          type="number"
          label="Current Balance ($)"
          min="0"
          step="0.01"
          required
          placeholder="e.g., 25000"
        />
        
        <.input
          field={@form[:annual_contribution]}
          type="number"
          label="Your Annual Contribution ($)"
          min="0"
          step="0.01"
          placeholder="e.g., 6000 (optional)"
        />
        
        <.input
          field={@form[:employer_match]}
          type="number"
          label="Annual Employer Match ($)"
          min="0"
          step="0.01"
          placeholder="e.g., 3000 (optional)"
        />
        
        <:actions>
          <.button phx-disable-with="Saving...">Save Account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{account: account} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Planning.change_retirement_account(account))
     end)}
  end

  @impl true
  def handle_event("validate", %{"retirement_account" => account_params}, socket) do
    changeset = Planning.change_retirement_account(socket.assigns.account, account_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"retirement_account" => account_params}, socket) do
    save_account(socket, socket.assigns.action, account_params)
  end

  defp save_account(socket, :edit_account, account_params) do
    case Planning.update_retirement_account(socket.assigns.account, account_params) do
      {:ok, account} ->
        notify_parent({:saved, account})

        {:noreply,
         socket
         |> put_flash(:info, "Account updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_account(socket, :new_account, account_params) do
    account_params_with_user = Map.put(account_params, "user_id", socket.assigns.account.user_id)
    
    case Planning.create_retirement_account(account_params_with_user) do
      {:ok, account} ->
        notify_parent({:saved, account})

        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
