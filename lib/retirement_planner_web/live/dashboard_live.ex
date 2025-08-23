defmodule RetirementPlannerWeb.DashboardLive do
  use RetirementPlannerWeb, :live_view

  alias RetirementPlanner.Planning
  alias RetirementPlanner.Planning.{RetirementGoal, RetirementAccount, Investment}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    
    {:ok,
     socket
     |> assign_user_data(user)
     |> assign(:page_title, "Retirement Dashboard")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Retirement Dashboard")
  end

  defp apply_action(socket, :new_goal, _params) do
    socket
    |> assign(:page_title, "New Retirement Goal")
    |> assign(:goal, %RetirementGoal{user_id: socket.assigns.current_user.id})
  end

  defp apply_action(socket, :edit_goal, %{"id" => id}) do
    goal = Planning.get_retirement_goal!(id)
    socket
    |> assign(:page_title, "Edit Retirement Goal")
    |> assign(:goal, goal)
  end

  defp apply_action(socket, :new_account, _params) do
    socket
    |> assign(:page_title, "New Retirement Account")
    |> assign(:account, %RetirementAccount{user_id: socket.assigns.current_user.id})
  end

  defp apply_action(socket, :new_investment, _params) do
    socket
    |> assign(:page_title, "New Investment")
    |> assign(:investment, %Investment{user_id: socket.assigns.current_user.id})
  end

  @impl true
  def handle_info({RetirementPlannerWeb.DashboardLive.GoalFormComponent, {:saved, _goal}}, socket) do
    {:noreply, 
     socket
     |> assign_user_data(socket.assigns.current_user)
     |> put_flash(:info, "Goal updated successfully")}
  end

  def handle_info({RetirementPlannerWeb.DashboardLive.AccountFormComponent, {:saved, _account}}, socket) do
    {:noreply, 
     socket
     |> assign_user_data(socket.assigns.current_user)
     |> put_flash(:info, "Account saved successfully")}
  end

  def handle_info({RetirementPlannerWeb.DashboardLive.InvestmentFormComponent, {:saved, _investment}}, socket) do
    {:noreply, 
     socket
     |> assign_user_data(socket.assigns.current_user)
     |> put_flash(:info, "Investment saved successfully")}
  end

  defp assign_user_data(socket, user) do
    case Planning.get_user_retirement_goal(user.id) do
      {:ok, goal} -> 
        {:ok, accounts} = Planning.list_user_retirement_accounts(user.id)
        {:ok, investments} = Planning.list_user_investments(user.id)
        projection = Planning.create_retirement_projection(user.id)
        
        socket
        |> assign(:has_goal, true)
        |> assign(:goal, goal)
        |> assign(:accounts, accounts)
        |> assign(:investments, investments)
        |> assign(:projection, projection)
        
      {:error, :not_found} -> 
        {:ok, accounts} = Planning.list_user_retirement_accounts(user.id)
        {:ok, investments} = Planning.list_user_investments(user.id)
        
        socket
        |> assign(:has_goal, false)
        |> assign(:goal, %RetirementGoal{user_id: user.id})
        |> assign(:accounts, accounts)
        |> assign(:investments, investments)
        |> assign(:projection, nil)
    end
  end

  defp format_currency(amount) when is_number(amount) do
    Number.Currency.number_to_currency(amount, precision: 0)
  end
  
  defp format_currency(decimal) do
    decimal
    |> Decimal.to_float()
    |> format_currency()
  end

  defp risk_badge_class("Low"), do: "bg-green-100 text-green-800"
  defp risk_badge_class("Medium"), do: "bg-yellow-100 text-yellow-800"
  defp risk_badge_class("High"), do: "bg-red-100 text-red-800"
  defp risk_badge_class(_), do: "bg-gray-100 text-gray-800"
end
