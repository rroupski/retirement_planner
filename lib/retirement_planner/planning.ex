defmodule RetirementPlanner.Planning do
  @moduledoc """
  The Planning context for retirement calculations and projections.
  """

  import Ecto.Query, warn: false
  alias RetirementPlanner.Repo
  alias RetirementPlanner.Planning.{RetirementAccount, Investment, RetirementGoal, ProjectionResult}

  @doc """
  Calculate compound growth for retirement planning.
  """
  def compound_growth(principal, monthly_contribution, annual_rate, years) when is_number(principal) and 
                                                                                 is_number(monthly_contribution) and 
                                                                                 is_number(annual_rate) and 
                                                                                 is_number(years) do
    monthly_rate = annual_rate / 12
    months = years * 12
    
    # Future value of current principal
    principal_growth = principal * :math.pow(1 + annual_rate, years)
    
    # Future value of monthly contributions (annuity)
    if monthly_rate > 0 do
      contribution_growth = monthly_contribution * 
        ((:math.pow(1 + monthly_rate, months) - 1) / monthly_rate)
      
      principal_growth + contribution_growth
    else
      principal_growth + (monthly_contribution * months)
    end
  end

  @doc """
  Calculate required monthly savings to reach retirement goal.
  """
  def required_monthly_savings(current_balance, target_amount, annual_rate, years) when is_number(current_balance) and 
                                                                                        is_number(target_amount) and 
                                                                                        is_number(annual_rate) and 
                                                                                        is_number(years) do
    monthly_rate = annual_rate / 12
    months = years * 12
    
    # Future value of current balance
    future_current = current_balance * :math.pow(1 + annual_rate, years)
    
    # Amount needed from monthly contributions
    needed_from_contributions = target_amount - future_current
    
    if needed_from_contributions <= 0 do
      0
    else
      if monthly_rate > 0 do
        needed_from_contributions * monthly_rate / 
          (:math.pow(1 + monthly_rate, months) - 1)
      else
        needed_from_contributions / months
      end
    end
  end

  @doc """
  Calculate retirement income needed adjusted for inflation.
  """
  def inflation_adjusted_income(desired_income, inflation_rate, years_until_retirement) when is_number(desired_income) and 
                                                                                             is_number(inflation_rate) and 
                                                                                             is_number(years_until_retirement) do
    desired_income * :math.pow(1 + inflation_rate, years_until_retirement)
  end

  @doc """
  Calculate total retirement nest egg needed (using 4% rule).
  """
  def retirement_nest_egg_needed(annual_income_needed, withdrawal_rate \\ 0.04) when is_number(annual_income_needed) and 
                                                                                     is_number(withdrawal_rate) do
    annual_income_needed / withdrawal_rate
  end

  @doc """
  Calculate weighted portfolio return based on investment allocations.
  """
  def calculate_portfolio_return(investments) when is_list(investments) do
    total_allocation = Enum.reduce(investments, Decimal.new(0), fn inv, acc ->
      Decimal.add(acc, inv.allocation_percentage || Decimal.new(0))
    end)
    
    if Decimal.gt?(total_allocation, Decimal.new(0)) do
      weighted_return = Enum.reduce(investments, Decimal.new(0), fn inv, acc ->
        weight = Decimal.div(inv.allocation_percentage || Decimal.new(0), total_allocation)
        contribution = Decimal.mult(weight, inv.expected_return || Decimal.new(0))
        Decimal.add(acc, contribution)
      end)
      
      Decimal.to_float(weighted_return) / 100
    else
      0.07  # Default 7% return if no investments defined
    end
  end

  @doc """
  Create comprehensive retirement projection.
  """
  def create_retirement_projection(user_id) do
    with {:ok, goal} <- get_user_retirement_goal(user_id),
         {:ok, accounts} <- list_user_retirement_accounts(user_id),
         {:ok, investments} <- list_user_investments(user_id) do
      
      years_until_retirement = goal.target_retirement_age - goal.current_age
      current_total_balance = Enum.reduce(accounts, Decimal.new(0), fn acc, sum ->
        Decimal.add(sum, acc.current_balance || Decimal.new(0))
      end)
      
      current_annual_contributions = Enum.reduce(accounts, Decimal.new(0), fn acc, sum ->
        contribution = Decimal.add(acc.annual_contribution || Decimal.new(0), 
                                   acc.employer_match || Decimal.new(0))
        Decimal.add(sum, contribution)
      end)
      
      portfolio_return = calculate_portfolio_return(investments)
      inflation_adjusted_income = inflation_adjusted_income(
        Decimal.to_float(goal.desired_annual_income),
        Decimal.to_float(goal.inflation_rate) / 100,
        years_until_retirement
      )
      
      nest_egg_needed = retirement_nest_egg_needed(inflation_adjusted_income)
      
      projected_balance = compound_growth(
        Decimal.to_float(current_total_balance),
        Decimal.to_float(current_annual_contributions) / 12,
        portfolio_return,
        years_until_retirement
      )
      
      shortfall = nest_egg_needed - projected_balance
      
      recommended_monthly_savings = if shortfall > 0 do
        required_monthly_savings(
          Decimal.to_float(current_total_balance),
          nest_egg_needed,
          portfolio_return,
          years_until_retirement
        )
      else
        0
      end
      
      %{
        projected_balance: projected_balance,
        nest_egg_needed: nest_egg_needed,
        shortfall: max(shortfall, 0),
        recommended_monthly_savings: recommended_monthly_savings,
        years_until_retirement: years_until_retirement,
        inflation_adjusted_income: inflation_adjusted_income
      }
    end
  end

  # CRUD functions for retirement accounts
  def list_user_retirement_accounts(user_id) do
    accounts = Repo.all(from a in RetirementAccount, where: a.user_id == ^user_id)
    {:ok, accounts}
  end

  def get_retirement_account!(id), do: Repo.get!(RetirementAccount, id)

  def create_retirement_account(attrs \\ %{}) do
    %RetirementAccount{}
    |> RetirementAccount.changeset(attrs)
    |> Repo.insert()
  end

  def update_retirement_account(%RetirementAccount{} = account, attrs) do
    account
    |> RetirementAccount.changeset(attrs)
    |> Repo.update()
  end

  def delete_retirement_account(%RetirementAccount{} = account) do
    Repo.delete(account)
  end

  def change_retirement_account(%RetirementAccount{} = account, attrs \\ %{}) do
    RetirementAccount.changeset(account, attrs)
  end

  # CRUD functions for investments
  def list_user_investments(user_id) do
    investments = Repo.all(from i in Investment, where: i.user_id == ^user_id)
    {:ok, investments}
  end

  def create_investment(attrs \\ %{}) do
    %Investment{}
    |> Investment.changeset(attrs)
    |> Repo.insert()
  end

  def update_investment(%Investment{} = investment, attrs) do
    investment
    |> Investment.changeset(attrs)
    |> Repo.update()
  end

  def change_investment(%Investment{} = investment, attrs \\ %{}) do
    Investment.changeset(investment, attrs)
  end

  # CRUD functions for retirement goals
  def get_user_retirement_goal(user_id) do
    case Repo.get_by(RetirementGoal, user_id: user_id) do
      nil -> {:error, :not_found}
      goal -> {:ok, goal}
    end
  end

  def get_retirement_goal!(id), do: Repo.get!(RetirementGoal, id)

  def create_retirement_goal(attrs \\ %{}) do
    %RetirementGoal{}
    |> RetirementGoal.changeset(attrs)
    |> Repo.insert()
  end

  def update_retirement_goal(%RetirementGoal{} = goal, attrs) do
    goal
    |> RetirementGoal.changeset(attrs)
    |> Repo.update()
  end

  def change_retirement_goal(%RetirementGoal{} = goal, attrs \\ %{}) do
    RetirementGoal.changeset(goal, attrs)
  end

  # CRUD functions for projection results
  def create_projection_result(attrs \\ %{}) do
    %ProjectionResult{}
    |> ProjectionResult.changeset(attrs)
    |> Repo.insert()
  end
end
