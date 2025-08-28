defmodule RetirementPlanner.PlanningFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RetirementPlanner.Planning` context.
  """

  alias RetirementPlanner.Planning

  @doc """
  Generate a retirement_goal.
  """
  def retirement_goal_fixture(attrs \\ %{}) do
    user = RetirementPlanner.AccountsFixtures.user_fixture()
    
    {:ok, retirement_goal} =
      attrs
      |> Enum.into(%{
        target_retirement_age: 65,
        desired_annual_income: Decimal.new("80000"),
        current_age: 30,
        inflation_rate: Decimal.new("2.5"),
        user_id: user.id
      })
      |> Planning.create_retirement_goal()

    retirement_goal
  end

  @doc """
  Generate a retirement_account.
  """
  def retirement_account_fixture(attrs \\ %{}) do
    user = RetirementPlanner.AccountsFixtures.user_fixture()
    
    {:ok, retirement_account} =
      attrs
      |> Enum.into(%{
        account_type: "401k",
        account_name: "Company 401k",
        current_balance: Decimal.new("50000"),
        annual_contribution: Decimal.new("6000"),
        employer_match: Decimal.new("3000"),
        user_id: user.id
      })
      |> Planning.create_retirement_account()

    retirement_account
  end

  @doc """
  Generate an investment.
  """
  def investment_fixture(attrs \\ %{}) do
    user = RetirementPlanner.AccountsFixtures.user_fixture()
    
    {:ok, investment} =
      attrs
      |> Enum.into(%{
        name: "S&P 500 Index Fund",
        asset_class: "stocks",
        expected_return: Decimal.new("7.0"),
        allocation_percentage: Decimal.new("70.0"),
        user_id: user.id
      })
      |> Planning.create_investment()

    investment
  end
end
