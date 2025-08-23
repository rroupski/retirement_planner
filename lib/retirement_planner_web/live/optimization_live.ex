defmodule RetirementPlannerWeb.OptimizationLive do
  use RetirementPlannerWeb, :live_view

  alias RetirementPlanner.{Planning, Optimization, Charts}
  alias RetirementPlanner.Planning.{RetirementGoal, RetirementAccount, Investment}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign_user_data(user)
     |> assign(:page_title, "Retirement Optimization")
     |> assign(:loading_optimization, false)
     |> assign(:available_monthly_amount, nil)
     |> assign(:optimization_results, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Retirement Optimization")
  end

  @impl true
  def handle_event("run_monte_carlo", _params, socket) do
    user_id = socket.assigns.current_user.id
    
    socket = assign(socket, :loading_optimization, true)
    send(self(), {:run_monte_carlo_simulation, user_id})
    
    {:noreply, socket}
  end

  def handle_event("run_asset_optimization", _params, socket) do
    user_id = socket.assigns.current_user.id
    
    socket = assign(socket, :loading_optimization, true)
    send(self(), {:run_asset_optimization, user_id})
    
    {:noreply, socket}
  end

  def handle_event("run_contribution_optimization", %{"monthly_amount" => monthly_amount}, socket) do
    user_id = socket.assigns.current_user.id
    
    case Float.parse(monthly_amount) do
      {amount, _} when amount > 0 ->
        socket = socket
        |> assign(:loading_optimization, true)
        |> assign(:available_monthly_amount, amount)
        
        send(self(), {:run_contribution_optimization, user_id, amount})
        {:noreply, socket}
      
      _ ->
        socket = put_flash(socket, :error, "Please enter a valid monthly amount")
        {:noreply, socket}
    end
  end

  def handle_event("run_timeline_optimization", _params, socket) do
    user_id = socket.assigns.current_user.id
    
    socket = assign(socket, :loading_optimization, true)
    send(self(), {:run_timeline_optimization, user_id})
    
    {:noreply, socket}
  end

  def handle_event("run_comprehensive_optimization", %{"monthly_amount" => monthly_amount}, socket) do
    user_id = socket.assigns.current_user.id
    
    case Float.parse(monthly_amount) do
      {amount, _} when amount > 0 ->
        socket = socket
        |> assign(:loading_optimization, true)
        |> assign(:available_monthly_amount, amount)
        
        send(self(), {:run_comprehensive_optimization, user_id, amount})
        {:noreply, socket}
      
      _ ->
        # Run without contribution optimization if no amount provided
        socket = assign(socket, :loading_optimization, true)
        send(self(), {:run_comprehensive_optimization, user_id, nil})
        {:noreply, socket}
    end
  end

  def handle_event("clear_results", _params, socket) do
    {:noreply, 
     socket
     |> assign(:optimization_results, nil)
     |> assign(:available_monthly_amount, nil)}
  end

  @impl true
  def handle_info({:run_monte_carlo_simulation, user_id}, socket) do
    case Optimization.monte_carlo_simulation(user_id, 5_000) do
      {:error, reason} ->
        {:noreply, 
         socket
         |> assign(:loading_optimization, false)
         |> put_flash(:error, "Error running Monte Carlo simulation: #{inspect(reason)}")}
      
      results ->
        monte_carlo_chart_data = Charts.monte_carlo_chart(results) |> Jason.encode!()
        
        optimization_results = %{
          monte_carlo: results,
          monte_carlo_chart_data: monte_carlo_chart_data
        }
        
        {:noreply,
         socket
         |> assign(:optimization_results, optimization_results)
         |> assign(:loading_optimization, false)
         |> put_flash(:info, "Monte Carlo simulation completed")}
    end
  end

  def handle_info({:run_asset_optimization, user_id}, socket) do
    case Optimization.optimize_asset_allocation(user_id) do
      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:loading_optimization, false)
         |> put_flash(:error, "Error running asset optimization: #{inspect(reason)}")}
      
      results ->
        rebalancing_chart_data = Charts.rebalancing_chart(results.rebalancing_recommendations) |> Jason.encode!()
        
        optimization_results = %{
          asset_optimization: results,
          rebalancing_chart_data: rebalancing_chart_data
        }
        
        {:noreply,
         socket
         |> assign(:optimization_results, optimization_results)
         |> assign(:loading_optimization, false)
         |> put_flash(:info, "Asset allocation optimization completed")}
    end
  end

  def handle_info({:run_contribution_optimization, user_id, monthly_amount}, socket) do
    case Optimization.optimize_contributions(user_id, monthly_amount) do
      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:loading_optimization, false)
         |> put_flash(:error, "Error running contribution optimization: #{inspect(reason)}")}
      
      results ->
        contribution_chart_data = Charts.contribution_optimization_chart(results) |> Jason.encode!()
        
        optimization_results = %{
          contribution_optimization: results,
          contribution_chart_data: contribution_chart_data
        }
        
        {:noreply,
         socket
         |> assign(:optimization_results, optimization_results)
         |> assign(:loading_optimization, false)
         |> put_flash(:info, "Contribution optimization completed")}
    end
  end

  def handle_info({:run_timeline_optimization, user_id}, socket) do
    case Optimization.optimize_retirement_timeline(user_id) do
      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:loading_optimization, false)
         |> put_flash(:error, "Error running timeline optimization: #{inspect(reason)}")}
      
      results ->
        timeline_chart_data = Charts.timeline_optimization_chart(results) |> Jason.encode!()
        
        optimization_results = %{
          timeline_optimization: results,
          timeline_chart_data: timeline_chart_data
        }
        
        {:noreply,
         socket
         |> assign(:optimization_results, optimization_results)
         |> assign(:loading_optimization, false)
         |> put_flash(:info, "Timeline optimization completed")}
    end
  end

  def handle_info({:run_comprehensive_optimization, user_id, monthly_amount}, socket) do
    case Optimization.generate_comprehensive_optimization(user_id, monthly_amount) do
      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:loading_optimization, false)
         |> put_flash(:error, "Error running comprehensive optimization: #{inspect(reason)}")}
      
      results ->
        # Generate all chart data
        monte_carlo_chart_data = if results.risk_analysis do
          Charts.monte_carlo_chart(results.risk_analysis) |> Jason.encode!()
        else
          nil
        end
        
        rebalancing_chart_data = if results.asset_allocation && length(results.asset_allocation.rebalancing_recommendations) > 0 do
          Charts.rebalancing_chart(results.asset_allocation.rebalancing_recommendations) |> Jason.encode!()
        else
          nil
        end
        
        contribution_chart_data = if results.contribution_strategy do
          Charts.contribution_optimization_chart(results.contribution_strategy) |> Jason.encode!()
        else
          nil
        end
        
        timeline_chart_data = if results.timeline_optimization do
          Charts.timeline_optimization_chart(results.timeline_optimization) |> Jason.encode!()
        else
          nil
        end
        
        optimization_results = %{
          comprehensive_results: results,
          monte_carlo_chart_data: monte_carlo_chart_data,
          rebalancing_chart_data: rebalancing_chart_data,
          contribution_chart_data: contribution_chart_data,
          timeline_chart_data: timeline_chart_data
        }
        
        {:noreply,
         socket
         |> assign(:optimization_results, optimization_results)
         |> assign(:loading_optimization, false)
         |> put_flash(:info, "Comprehensive optimization completed")}
    end
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

  defp format_percentage(value) when is_number(value) do
    float_value = if is_integer(value), do: value * 1.0, else: value
    "#{:erlang.float_to_binary(float_value, [{:decimals, 1}])}%"
  end

  defp impact_level_color(:critical), do: "bg-red-100 text-red-800 border-red-200"
  defp impact_level_color(:high), do: "bg-orange-100 text-orange-800 border-orange-200"
  defp impact_level_color(:medium), do: "bg-yellow-100 text-yellow-800 border-yellow-200"
  defp impact_level_color(:low), do: "bg-blue-100 text-blue-800 border-blue-200"
  defp impact_level_color(:minimal), do: "bg-gray-100 text-gray-800 border-gray-200"

  defp priority_badge_color(score) when score >= 150, do: "bg-red-100 text-red-800"
  defp priority_badge_color(score) when score >= 100, do: "bg-orange-100 text-orange-800"
  defp priority_badge_color(score) when score >= 75, do: "bg-yellow-100 text-yellow-800"
  defp priority_badge_color(_), do: "bg-green-100 text-green-800"

  defp priority_badge_text(score) when score >= 150, do: "Critical"
  defp priority_badge_text(score) when score >= 100, do: "High"
  defp priority_badge_text(score) when score >= 75, do: "Medium"
  defp priority_badge_text(_), do: "Low"
end
