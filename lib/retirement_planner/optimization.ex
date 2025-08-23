defmodule RetirementPlanner.Optimization do
  @moduledoc """
  Advanced optimization algorithms for retirement planning.

  This module provides sophisticated optimization strategies including:
  - Monte Carlo simulation for risk assessment
  - Modern Portfolio Theory for asset allocation
  - Contribution optimization across account types
  - Retirement timeline optimization
  """

  alias RetirementPlanner.Planning

  @doc """
  Run Monte Carlo simulation to assess retirement success probability.

  Simulates thousands of market scenarios to determine the likelihood
  of meeting retirement goals under different conditions.
  """
  def monte_carlo_simulation(user_id, num_simulations \\ 10_000) do
    with {:ok, goal} <- Planning.get_user_retirement_goal(user_id),
         {:ok, accounts} <- Planning.list_user_retirement_accounts(user_id),
         {:ok, investments} <- Planning.list_user_investments(user_id) do
      years_until_retirement = goal.target_retirement_age - goal.current_age
      current_balance = calculate_total_balance(accounts)
      annual_contributions = calculate_total_contributions(accounts)

      # Run simulations
      successes =
        1..num_simulations
        |> Enum.map(fn _ ->
          simulate_retirement_scenario(
            current_balance,
            annual_contributions,
            years_until_retirement,
            investments
          )
        end)
        |> Enum.count(fn final_balance ->
          # 4% rule
          final_balance >= Decimal.to_float(goal.desired_annual_income) * 25
        end)

      success_rate = successes / num_simulations * 100

      %{
        success_rate: success_rate,
        simulations_run: num_simulations,
        recommendation: get_monte_carlo_recommendation(success_rate),
        risk_assessment: assess_risk_level(success_rate)
      }
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Calculate optimal asset allocation using Modern Portfolio Theory.

  Finds the efficient frontier and suggests optimal portfolio weights
  to maximize return for a given risk level or minimize risk for a target return.
  """
  def optimize_asset_allocation(user_id, risk_tolerance \\ :moderate) do
    with {:ok, goal} <- Planning.get_user_retirement_goal(user_id),
         {:ok, investments} <- Planning.list_user_investments(user_id) do
      years_until_retirement = goal.target_retirement_age - goal.current_age

      # Define asset classes with historical risk/return data
      asset_classes = get_asset_class_data()

      # Calculate efficient frontier
      efficient_frontier = calculate_efficient_frontier(asset_classes)

      # Select optimal portfolio based on risk tolerance and time horizon
      optimal_allocation =
        select_optimal_portfolio(
          efficient_frontier,
          risk_tolerance,
          years_until_retirement
        )

      # Compare with current allocation
      current_allocation = calculate_current_allocation(investments)

      rebalancing_recommendations =
        calculate_rebalancing_needs(
          current_allocation,
          optimal_allocation
        )

      %{
        optimal_allocation: optimal_allocation,
        current_allocation: current_allocation,
        rebalancing_recommendations: rebalancing_recommendations,
        expected_return: optimal_allocation.expected_return,
        expected_volatility: optimal_allocation.target_volatility,
        sharpe_ratio: optimal_allocation.sharpe_ratio
      }
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Optimize contribution strategy across different account types.

  Determines the optimal distribution of contributions to maximize
  tax advantages and employer matching benefits.
  """
  def optimize_contributions(user_id, available_monthly_amount) do
    with {:ok, goal} <- Planning.get_user_retirement_goal(user_id),
         {:ok, accounts} <- Planning.list_user_retirement_accounts(user_id) do
      # Calculate employer match opportunities
      match_opportunities = calculate_match_opportunities(accounts)

      # Optimize for tax efficiency
      tax_optimized_strategy =
        calculate_tax_optimized_contributions(
          accounts,
          available_monthly_amount,
          goal.current_age
        )

      # Prioritize contributions
      contribution_priority =
        prioritize_contributions(
          accounts,
          match_opportunities,
          tax_optimized_strategy,
          available_monthly_amount
        )

      %{
        recommended_allocations: contribution_priority,
        total_monthly_contributions: available_monthly_amount,
        employer_match_captured: calculate_total_match(contribution_priority),
        tax_savings_estimate: calculate_tax_savings(contribution_priority, goal.current_age),
        optimization_notes: generate_contribution_notes(contribution_priority)
      }
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Optimize retirement timeline based on different scenarios.

  Analyzes various retirement ages and withdrawal strategies to find
  the optimal balance between lifestyle and financial security.
  """
  def optimize_retirement_timeline(user_id, lifestyle_preferences \\ %{}) do
    with {:ok, goal} <- Planning.get_user_retirement_goal(user_id),
         {:ok, accounts} <- Planning.list_user_retirement_accounts(user_id) do
      current_balance = calculate_total_balance(accounts)
      annual_contributions = calculate_total_contributions(accounts)

      # Test different retirement ages
      retirement_scenarios =
        (goal.current_age + 5)..(goal.current_age + 40)
        |> Enum.map(fn retirement_age ->
          analyze_retirement_scenario(
            retirement_age,
            current_balance,
            annual_contributions,
            goal,
            lifestyle_preferences
          )
        end)

      # Find optimal scenarios
      optimal_scenario = find_optimal_retirement_age(retirement_scenarios)
      conservative_scenario = find_conservative_retirement_age(retirement_scenarios)
      aggressive_scenario = find_aggressive_retirement_age(retirement_scenarios)

      %{
        optimal_retirement_age: optimal_scenario,
        conservative_option: conservative_scenario,
        aggressive_option: aggressive_scenario,
        scenarios_analyzed: retirement_scenarios,
        recommendations: generate_timeline_recommendations(retirement_scenarios)
      }
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Generate comprehensive optimization recommendations.

  Combines all optimization strategies to provide actionable insights.
  """
  def generate_comprehensive_optimization(user_id, available_monthly_amount \\ nil) do
    with {:ok, _goal} <- Planning.get_user_retirement_goal(user_id),
         {:ok, _accounts} <- Planning.list_user_retirement_accounts(user_id) do
      # Run all optimizations
      monte_carlo = monte_carlo_simulation(user_id, 5_000)
      asset_optimization = optimize_asset_allocation(user_id)

      contribution_optimization =
        if available_monthly_amount do
          optimize_contributions(user_id, available_monthly_amount)
        else
          nil
        end

      timeline_optimization = optimize_retirement_timeline(user_id)

      # Calculate potential impact
      potential_improvements =
        calculate_optimization_impact(
          monte_carlo,
          asset_optimization,
          contribution_optimization,
          timeline_optimization
        )

      %{
        risk_analysis: monte_carlo,
        asset_allocation: asset_optimization,
        contribution_strategy: contribution_optimization,
        timeline_optimization: timeline_optimization,
        potential_improvements: potential_improvements,
        priority_actions: rank_optimization_actions(potential_improvements),
        next_review_date: calculate_next_review_date()
      }
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Private helper functions

  defp calculate_total_balance(accounts) do
    accounts
    |> Enum.reduce(Decimal.new(0), fn account, total ->
      Decimal.add(total, account.current_balance || Decimal.new(0))
    end)
    |> Decimal.to_float()
  end

  defp calculate_total_contributions(accounts) do
    accounts
    |> Enum.reduce(0, fn account, total ->
      contribution = Decimal.to_float(account.annual_contribution || Decimal.new(0))
      match = Decimal.to_float(account.employer_match || Decimal.new(0))
      total + contribution + match
    end)
  end

  defp simulate_retirement_scenario(current_balance, annual_contributions, years, investments) do
    # Use weighted average expected return from investments
    expected_return = calculate_portfolio_return(investments)
    volatility = calculate_portfolio_volatility(investments)

    # Simulate year by year with random returns
    1..years
    |> Enum.reduce(current_balance, fn _, balance ->
      # Generate random return using normal distribution approximation
      random_return = generate_random_return(expected_return, volatility)
      new_balance = balance * (1 + random_return) + annual_contributions
      # Ensure balance doesn't go negative
      max(new_balance, 0)
    end)
  end

  defp calculate_portfolio_return(investments) when length(investments) == 0, do: 0.07

  defp calculate_portfolio_return(investments) do
    total_allocation =
      investments
      |> Enum.reduce(Decimal.new(0), fn inv, acc ->
        Decimal.add(acc, inv.allocation_percentage)
      end)

    if Decimal.equal?(total_allocation, Decimal.new(0)) do
      # Default 7% if no allocations
      0.07
    else
      investments
      |> Enum.reduce(0, fn investment, acc ->
        weight =
          Decimal.to_float(investment.allocation_percentage) / Decimal.to_float(total_allocation)

        return = Decimal.to_float(investment.expected_return) / 100
        acc + weight * return
      end)
    end
  end

  defp calculate_portfolio_volatility(investments) when length(investments) == 0, do: 0.15

  defp calculate_portfolio_volatility(investments) do
    # Simplified volatility calculation based on risk levels
    risk_volatility_map = %{
      "Low" => 0.05,
      "Medium" => 0.15,
      "High" => 0.25
    }

    total_allocation =
      investments
      |> Enum.reduce(Decimal.new(0), fn inv, acc ->
        Decimal.add(acc, inv.allocation_percentage)
      end)

    if Decimal.equal?(total_allocation, Decimal.new(0)) do
      # Default volatility
      0.15
    else
      investments
      |> Enum.reduce(0, fn investment, acc ->
        weight =
          Decimal.to_float(investment.allocation_percentage) / Decimal.to_float(total_allocation)

        volatility = Map.get(risk_volatility_map, investment.risk_level, 0.15)
        acc + weight * volatility
      end)
    end
  end

  defp generate_random_return(expected_return, volatility) do
    # Simple normal distribution approximation using Box-Muller transform
    u1 = :rand.uniform()
    u2 = :rand.uniform()

    z = :math.sqrt(-2 * :math.log(u1)) * :math.cos(2 * :math.pi() * u2)
    expected_return + volatility * z
  end

  defp get_monte_carlo_recommendation(success_rate) do
    cond do
      success_rate >= 90 ->
        "Excellent - Your current strategy has a very high probability of success"

      success_rate >= 80 ->
        "Good - Minor adjustments could improve your success rate"

      success_rate >= 70 ->
        "Moderate - Consider increasing contributions or adjusting timeline"

      success_rate >= 60 ->
        "Concerning - Significant changes recommended to meet goals"

      true ->
        "High Risk - Major strategy revision needed"
    end
  end

  defp assess_risk_level(success_rate) do
    cond do
      success_rate >= 85 -> :low
      success_rate >= 70 -> :moderate
      success_rate >= 55 -> :high
      true -> :very_high
    end
  end

  defp get_asset_class_data do
    # Historical data for major asset classes (simplified)
    %{
      "US Stocks" => %{expected_return: 0.10, volatility: 0.20, correlation: %{}},
      "International Stocks" => %{expected_return: 0.09, volatility: 0.22, correlation: %{}},
      "Bonds" => %{expected_return: 0.04, volatility: 0.05, correlation: %{}},
      "REITs" => %{expected_return: 0.08, volatility: 0.18, correlation: %{}},
      "Commodities" => %{expected_return: 0.06, volatility: 0.25, correlation: %{}}
    }
  end

  defp calculate_efficient_frontier(asset_classes) do
    # Simplified efficient frontier calculation
    # In a full implementation, this would use matrix operations
    # to solve for optimal portfolio weights at different risk levels

    risk_levels = [0.05, 0.08, 0.12, 0.16, 0.20, 0.25]

    risk_levels
    |> Enum.map(fn target_volatility ->
      # Find portfolio with target volatility that maximizes return
      optimal_weights = optimize_for_target_risk(asset_classes, target_volatility)
      expected_return = calculate_portfolio_expected_return(asset_classes, optimal_weights)

      %{
        target_volatility: target_volatility,
        expected_return: expected_return,
        weights: optimal_weights,
        # Assuming 2% risk-free rate
        sharpe_ratio: (expected_return - 0.02) / target_volatility
      }
    end)
  end

  defp optimize_for_target_risk(_asset_classes, target_volatility) do
    # Simplified optimization - in practice would use quadratic programming
    # This is a placeholder that provides reasonable allocations

    case target_volatility do
      vol when vol <= 0.08 ->
        %{
          "US Stocks" => 0.20,
          "International Stocks" => 0.10,
          "Bonds" => 0.60,
          "REITs" => 0.05,
          "Commodities" => 0.05
        }

      vol when vol <= 0.12 ->
        %{
          "US Stocks" => 0.40,
          "International Stocks" => 0.20,
          "Bonds" => 0.30,
          "REITs" => 0.05,
          "Commodities" => 0.05
        }

      vol when vol <= 0.16 ->
        %{
          "US Stocks" => 0.50,
          "International Stocks" => 0.25,
          "Bonds" => 0.15,
          "REITs" => 0.05,
          "Commodities" => 0.05
        }

      vol when vol <= 0.20 ->
        %{
          "US Stocks" => 0.60,
          "International Stocks" => 0.25,
          "Bonds" => 0.05,
          "REITs" => 0.05,
          "Commodities" => 0.05
        }

      _ ->
        %{
          "US Stocks" => 0.50,
          "International Stocks" => 0.30,
          "Bonds" => 0.05,
          "REITs" => 0.10,
          "Commodities" => 0.05
        }
    end
  end

  defp calculate_portfolio_expected_return(asset_classes, weights) do
    weights
    |> Enum.reduce(0, fn {asset, weight}, acc ->
      expected_return = asset_classes[asset].expected_return
      acc + weight * expected_return
    end)
  end

  defp select_optimal_portfolio(efficient_frontier, risk_tolerance, years_until_retirement) do
    # Select portfolio based on risk tolerance and time horizon
    target_volatility =
      case {risk_tolerance, years_until_retirement} do
        {:conservative, _} -> 0.08
        {:moderate, years} when years > 20 -> 0.16
        {:moderate, years} when years > 10 -> 0.12
        {:moderate, _} -> 0.08
        {:aggressive, years} when years > 15 -> 0.20
        {:aggressive, years} when years > 5 -> 0.16
        {:aggressive, _} -> 0.12
        # Default for long time horizons
        {_, years} when years > 25 -> 0.16
        # Default for medium time horizons
        {_, years} when years > 10 -> 0.12
        # Default for short time horizons
        {_, _} -> 0.08
      end

    # Find closest portfolio in efficient frontier
    efficient_frontier
    |> Enum.min_by(fn portfolio ->
      abs(portfolio.target_volatility - target_volatility)
    end)
  end

  defp calculate_current_allocation(investments) when length(investments) == 0 do
    %{}
  end

  defp calculate_current_allocation(investments) do
    # Map investments to asset classes (simplified)
    investments
    |> Enum.group_by(fn investment ->
      # Simple mapping based on investment name/symbol
      cond do
        String.contains?(String.downcase(investment.name), "bond") ->
          "Bonds"

        String.contains?(String.downcase(investment.name), "reit") ->
          "REITs"

        String.contains?(String.downcase(investment.name), "international") ->
          "International Stocks"

        String.contains?(String.downcase(investment.name), "commodity") ->
          "Commodities"

        true ->
          "US Stocks"
      end
    end)
    |> Enum.map(fn {asset_class, invs} ->
      total_allocation =
        invs
        |> Enum.reduce(Decimal.new(0), fn inv, acc ->
          Decimal.add(acc, inv.allocation_percentage)
        end)
        |> Decimal.to_float()
        # Convert percentage to decimal
        |> Kernel./(100)

      {asset_class, total_allocation}
    end)
    |> Enum.into(%{})
  end

  defp calculate_rebalancing_needs(current_allocation, optimal_allocation) do
    all_assets =
      (Map.keys(optimal_allocation.weights) ++ Map.keys(current_allocation))
      |> Enum.uniq()

    all_assets
    |> Enum.map(fn asset ->
      current_weight = Map.get(current_allocation, asset, 0)
      optimal_weight = Map.get(optimal_allocation.weights, asset, 0)
      difference = optimal_weight - current_weight

      %{
        asset_class: asset,
        current_allocation: current_weight,
        target_allocation: optimal_weight,
        rebalancing_needed: difference,
        action: get_rebalancing_action(difference)
      }
    end)
    # Only significant changes
    |> Enum.filter(fn rebalance -> abs(rebalance.rebalancing_needed) > 0.05 end)
  end

  defp get_rebalancing_action(difference) do
    cond do
      difference > 0.05 -> "Increase allocation"
      difference < -0.05 -> "Decrease allocation"
      true -> "Maintain current allocation"
    end
  end

  defp calculate_match_opportunities(accounts) do
    accounts
    |> Enum.map(fn account ->
      match_amount = Decimal.to_float(account.employer_match || Decimal.new(0))
      contribution_amount = Decimal.to_float(account.annual_contribution || Decimal.new(0))

      # Estimate maximum possible match (simplified)
      estimated_max_match =
        case account.account_type do
          # Assume 50% match up to 6% of salary
          "401k" -> contribution_amount * 0.5
          "403b" -> contribution_amount * 0.5
          _ -> 0
        end

      %{
        account_id: account.id,
        account_name: account.name,
        current_match: match_amount,
        estimated_max_match: estimated_max_match,
        uncaptured_match: max(0, estimated_max_match - match_amount)
      }
    end)
  end

  defp calculate_tax_optimized_contributions(accounts, _available_amount, current_age) do
    # Prioritize based on tax advantages and age
    # Favor Roth when young
    roth_advantage = if current_age < 35, do: 1.2, else: 1.0
    # Favor traditional when older
    traditional_advantage = if current_age > 50, do: 1.2, else: 1.0

    accounts
    |> Enum.map(fn account ->
      tax_advantage =
        case account.account_type do
          "Roth IRA" -> roth_advantage
          "401k" -> traditional_advantage
          "403b" -> traditional_advantage
          "IRA" -> traditional_advantage
          _ -> 1.0
        end

      %{
        account: account,
        tax_advantage: tax_advantage,
        recommended_priority: calculate_priority_score(account, tax_advantage)
      }
    end)
    |> Enum.sort_by(& &1.recommended_priority, :desc)
  end

  defp calculate_priority_score(account, tax_advantage) do
    base_score = tax_advantage * 100

    # Add bonus for employer match
    match_bonus =
      if Decimal.to_float(account.employer_match || Decimal.new(0)) > 0 do
        # Very high priority for employer match
        200
      else
        0
      end

    base_score + match_bonus
  end

  defp prioritize_contributions(_accounts, match_opportunities, tax_strategy, available_amount) do
    remaining_amount = available_amount

    # First, maximize employer match
    {match_allocations, remaining_after_match} =
      allocate_for_matches(
        match_opportunities,
        remaining_amount
      )

    # Then, optimize remaining amount based on tax strategy
    remaining_allocations =
      allocate_remaining_amount(
        tax_strategy,
        remaining_after_match
      )

    match_allocations ++ remaining_allocations
  end

  defp allocate_for_matches(match_opportunities, available_amount) do
    {allocations, remaining} =
      match_opportunities
      |> Enum.reduce({[], available_amount}, fn opportunity,
                                                {acc_allocations, remaining_amount} ->
        if opportunity.uncaptured_match > 0 and remaining_amount > 0 do
          allocation_amount = min(opportunity.uncaptured_match, remaining_amount)

          new_allocation = %{
            account_name: opportunity.account_name,
            # Convert to monthly
            monthly_amount: allocation_amount / 12,
            reason: "Maximize employer match",
            priority: :high
          }

          {[new_allocation | acc_allocations], remaining_amount - allocation_amount}
        else
          {acc_allocations, remaining_amount}
        end
      end)

    {Enum.reverse(allocations), remaining}
  end

  defp allocate_remaining_amount(tax_strategy, remaining_amount) do
    # Allocate remaining amount based on tax optimization strategy
    tax_strategy
    |> Enum.reduce({[], remaining_amount}, fn strategy_item, {allocations, remaining} ->
      if remaining > 0 do
        # Calculate contribution limits (simplified)
        annual_limit = get_annual_contribution_limit(strategy_item.account.account_type)

        current_contribution =
          Decimal.to_float(strategy_item.account.annual_contribution || Decimal.new(0))

        available_room = max(0, annual_limit - current_contribution)

        allocation_amount = min(available_room, remaining)

        if allocation_amount > 0 do
          new_allocation = %{
            account_name: strategy_item.account.name,
            monthly_amount: allocation_amount / 12,
            reason: "Tax optimization",
            priority: :medium
          }

          {[new_allocation | allocations], remaining - allocation_amount}
        else
          {allocations, remaining}
        end
      else
        {allocations, remaining}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp get_annual_contribution_limit(account_type) do
    # 2024 contribution limits (simplified)
    case account_type do
      "401k" -> 23_000
      "403b" -> 23_000
      "IRA" -> 7_000
      "Roth IRA" -> 7_000
      "SEP-IRA" -> 69_000
      "Simple IRA" -> 16_000
      _ -> 6_000
    end
  end

  defp calculate_total_match(contribution_priority) do
    contribution_priority
    |> Enum.filter(fn allocation -> allocation.reason == "Maximize employer match" end)
    |> Enum.reduce(0, fn allocation, acc -> acc + allocation.monthly_amount * 12 end)
  end

  defp calculate_tax_savings(contribution_priority, current_age) do
    # Simplified tax savings calculation
    marginal_tax_rate = estimate_marginal_tax_rate(current_age)

    traditional_contributions =
      contribution_priority
      |> Enum.filter(fn allocation ->
        # Simplified check
        allocation.reason == "Tax optimization" and
          String.contains?(allocation.account_name, "401")
      end)
      |> Enum.reduce(0, fn allocation, acc -> acc + allocation.monthly_amount * 12 end)

    traditional_contributions * marginal_tax_rate
  end

  defp estimate_marginal_tax_rate(current_age) do
    # Simplified estimation based on typical retirement planning assumptions
    cond do
      # Assume lower income, 22% bracket
      current_age < 30 -> 0.22
      # Prime earning years, 24% bracket
      current_age < 45 -> 0.24
      # Peak earnings, 32% bracket
      current_age < 55 -> 0.32
      # Pre-retirement, potentially lower income
      true -> 0.24
    end
  end

  defp generate_contribution_notes(contribution_priority) do
    notes = []

    # Check for employer match optimization
    match_notes =
      contribution_priority
      |> Enum.filter(fn allocation -> allocation.reason == "Maximize employer match" end)
      |> case do
        [] ->
          []

        match_allocations ->
          total_match =
            Enum.reduce(match_allocations, 0, fn allocation, acc ->
              acc + allocation.monthly_amount * 12
            end)

          [
            "Capturing $#{:erlang.float_to_binary(total_match, [{:decimals, 0}])} in employer matching"
          ]
      end

    # Check for tax optimization
    tax_notes =
      contribution_priority
      |> Enum.filter(fn allocation -> allocation.reason == "Tax optimization" end)
      |> case do
        [] ->
          []

        _tax_allocations ->
          ["Optimized for current tax situation and retirement timeline"]
      end

    notes ++ match_notes ++ tax_notes
  end

  defp analyze_retirement_scenario(
         retirement_age,
         current_balance,
         annual_contributions,
         goal,
         lifestyle_preferences
       ) do
    years_until_retirement = retirement_age - goal.current_age

    if years_until_retirement < 5 do
      # Too soon to retire safely
      %{
        retirement_age: retirement_age,
        feasible: false,
        reason: "Insufficient time to accumulate adequate savings"
      }
    else
      # Project balance at retirement
      projected_balance =
        Planning.compound_growth(
          current_balance,
          annual_contributions / 12,
          # Conservative 7% return assumption
          0.07,
          years_until_retirement
        )

      # Calculate required nest egg using 4% rule
      required_nest_egg = Decimal.to_float(goal.desired_annual_income) * 25

      # Calculate success metrics
      success_rate = min(100, projected_balance / required_nest_egg * 100)

      # Consider lifestyle factors
      lifestyle_score = calculate_lifestyle_score(retirement_age, lifestyle_preferences)

      %{
        retirement_age: retirement_age,
        years_until_retirement: years_until_retirement,
        projected_balance: projected_balance,
        required_nest_egg: required_nest_egg,
        success_rate: success_rate,
        lifestyle_score: lifestyle_score,
        overall_score: (success_rate + lifestyle_score) / 2,
        feasible: success_rate >= 80
      }
    end
  end

  defp calculate_lifestyle_score(retirement_age, lifestyle_preferences) do
    base_score = 50

    # Adjust based on health considerations
    health_adjustment =
      case Map.get(lifestyle_preferences, :health_priority, :normal) do
        :high -> if retirement_age <= 62, do: 20, else: -10
        :low -> if retirement_age >= 70, do: 10, else: 0
        _ -> 0
      end

    # Adjust based on family considerations
    family_adjustment =
      case Map.get(lifestyle_preferences, :family_time, :normal) do
        :high -> if retirement_age <= 65, do: 15, else: 0
        :low -> if retirement_age >= 67, do: 10, else: 0
        _ -> 0
      end

    # Adjust based on career satisfaction
    career_adjustment =
      case Map.get(lifestyle_preferences, :career_satisfaction, :normal) do
        :high -> if retirement_age >= 67, do: 15, else: -5
        :low -> if retirement_age <= 62, do: 15, else: 0
        _ -> 0
      end

    total_score = base_score + health_adjustment + family_adjustment + career_adjustment
    # Clamp between 0 and 100
    max(0, min(100, total_score))
  end

  defp find_optimal_retirement_age(scenarios) do
    scenarios
    |> Enum.filter(& &1.feasible)
    |> case do
      [] ->
        nil

      feasible_scenarios ->
        Enum.max_by(feasible_scenarios, & &1.overall_score)
    end
  end

  defp find_conservative_retirement_age(scenarios) do
    scenarios
    |> Enum.filter(fn scenario ->
      scenario.feasible and scenario.success_rate >= 95
    end)
    |> case do
      [] ->
        nil

      conservative_scenarios ->
        Enum.min_by(conservative_scenarios, & &1.retirement_age)
    end
  end

  defp find_aggressive_retirement_age(scenarios) do
    scenarios
    |> Enum.filter(fn scenario ->
      scenario.feasible and scenario.success_rate >= 75
    end)
    |> case do
      [] ->
        nil

      aggressive_scenarios ->
        Enum.min_by(aggressive_scenarios, & &1.retirement_age)
    end
  end

  defp generate_timeline_recommendations(scenarios) do
    feasible_count = Enum.count(scenarios, & &1.feasible)

    recommendations = []

    # Add recommendation based on feasible scenarios
    feasibility_recommendation =
      case feasible_count do
        0 ->
          "Consider increasing contributions or extending retirement timeline"

        count when count < 5 ->
          "Limited retirement options - consider optimizing savings strategy"

        count when count < 15 ->
          "Good retirement flexibility with current strategy"

        _ ->
          "Excellent retirement flexibility - multiple viable options"
      end

    recommendations = [feasibility_recommendation | recommendations]

    # Add specific actionable recommendations
    earliest_feasible =
      scenarios
      |> Enum.filter(& &1.feasible)
      |> case do
        [] -> nil
        feasible -> Enum.min_by(feasible, & &1.retirement_age)
      end

    if earliest_feasible do
      action_recommendation =
        "Earliest feasible retirement: age #{earliest_feasible.retirement_age}"

      _recommendations = [action_recommendation | recommendations]
    end

    Enum.reverse(recommendations)
  end

  defp calculate_optimization_impact(
         monte_carlo,
         asset_optimization,
         contribution_optimization,
         timeline_optimization
       ) do
    impacts = %{}

    # Calculate Monte Carlo impact
    impacts =
      Map.put(impacts, :risk_reduction, %{
        current_success_rate: monte_carlo.success_rate,
        potential_improvement: calculate_risk_improvement_potential(monte_carlo.success_rate),
        impact_level: assess_impact_level(monte_carlo.success_rate)
      })

    # Calculate asset allocation impact
    if asset_optimization.rebalancing_recommendations != [] do
      _impacts =
        Map.put(impacts, :asset_rebalancing, %{
          expected_return_improvement: calculate_return_improvement(asset_optimization),
          rebalancing_actions: length(asset_optimization.rebalancing_recommendations),
          impact_level: :medium
        })
    end

    # Calculate contribution impact
    if contribution_optimization do
      _impacts =
        Map.put(impacts, :contribution_optimization, %{
          additional_employer_match: contribution_optimization.employer_match_captured,
          tax_savings: contribution_optimization.tax_savings_estimate,
          impact_level: assess_contribution_impact(contribution_optimization)
        })
    end

    # Calculate timeline impact
    if timeline_optimization.optimal_retirement_age do
      _impacts =
        Map.put(impacts, :timeline_optimization, %{
          optimal_age: timeline_optimization.optimal_retirement_age.retirement_age,
          years_flexibility:
            calculate_timeline_flexibility(timeline_optimization.scenarios_analyzed),
          impact_level: :high
        })
    end

    impacts
  end

  defp calculate_risk_improvement_potential(current_success_rate) do
    cond do
      # Already very good
      current_success_rate >= 90 -> 5
      # Some room for improvement
      current_success_rate >= 80 -> 15
      # Significant improvement possible
      current_success_rate >= 70 -> 25
      # Large improvement needed
      current_success_rate >= 60 -> 35
      # Major improvement required
      true -> 50
    end
  end

  defp assess_impact_level(success_rate) do
    cond do
      success_rate >= 85 -> :low
      success_rate >= 70 -> :medium
      success_rate >= 55 -> :high
      true -> :critical
    end
  end

  defp calculate_return_improvement(asset_optimization) do
    # Simplified calculation of potential return improvement from rebalancing
    significant_rebalances =
      asset_optimization.rebalancing_recommendations
      |> Enum.filter(fn rebalance -> abs(rebalance.rebalancing_needed) > 0.10 end)
      |> length()

    # Estimate improvement based on number of significant rebalancing actions
    # 0.5% improvement per significant rebalance
    significant_rebalances * 0.005
  end

  defp assess_contribution_impact(contribution_optimization) do
    total_improvement =
      contribution_optimization.employer_match_captured +
        contribution_optimization.tax_savings_estimate

    cond do
      total_improvement > 5000 -> :high
      total_improvement > 2000 -> :medium
      total_improvement > 500 -> :low
      true -> :minimal
    end
  end

  defp calculate_timeline_flexibility(scenarios) do
    feasible_scenarios = Enum.filter(scenarios, & &1.feasible)

    if length(feasible_scenarios) > 0 do
      ages = Enum.map(feasible_scenarios, & &1.retirement_age)
      Enum.max(ages) - Enum.min(ages)
    else
      0
    end
  end

  defp rank_optimization_actions(potential_improvements) do
    potential_improvements
    |> Enum.map(fn {action_type, impact_data} ->
      priority_score = calculate_action_priority(action_type, impact_data)

      %{
        action: action_type,
        priority_score: priority_score,
        impact_level: Map.get(impact_data, :impact_level, :low),
        description: generate_action_description(action_type, impact_data)
      }
    end)
    |> Enum.sort_by(& &1.priority_score, :desc)
  end

  defp calculate_action_priority(action_type, impact_data) do
    base_scores = %{
      # Highest priority - immediate impact
      contribution_optimization: 100,
      # Important for success probability
      risk_reduction: 80,
      # Medium priority - long-term impact
      asset_rebalancing: 60,
      # Lower priority - lifestyle choice
      timeline_optimization: 40
    }

    base_score = Map.get(base_scores, action_type, 50)

    # Adjust based on impact level
    impact_multiplier =
      case Map.get(impact_data, :impact_level, :low) do
        :critical -> 2.0
        :high -> 1.5
        :medium -> 1.2
        :low -> 1.0
        :minimal -> 0.8
      end

    round(base_score * impact_multiplier)
  end

  defp generate_action_description(action_type, impact_data) do
    case action_type do
      :contribution_optimization ->
        match_amount = Map.get(impact_data, :additional_employer_match, 0)

        "Optimize contribution strategy (potential $#{:erlang.float_to_binary(match_amount, [{:decimals, 0}])} in additional matching)"

      :risk_reduction ->
        current_rate = Map.get(impact_data, :current_success_rate, 0)

        "Improve retirement success probability from #{:erlang.float_to_binary(current_rate, [{:decimals, 1}])}%"

      :asset_rebalancing ->
        return_improvement = Map.get(impact_data, :expected_return_improvement, 0)
        improvement_percent = return_improvement * 100

        "Rebalance portfolio for #{:erlang.float_to_binary(improvement_percent, [{:decimals, 1}])}% potential return improvement"

      :timeline_optimization ->
        optimal_age = Map.get(impact_data, :optimal_age, 65)
        "Consider optimal retirement age of #{optimal_age}"

      _ ->
        "Optimization opportunity identified"
    end
  end

  defp calculate_next_review_date do
    # Recommend quarterly reviews for optimization
    Date.utc_today()
    # 3 months from now
    |> Date.add(90)
  end
end
