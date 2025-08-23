defmodule RetirementPlanner.Planning.ProjectionResult do
  use Ecto.Schema
  import Ecto.Changeset
  alias RetirementPlanner.Accounts.User
  alias RetirementPlanner.Planning.RetirementGoal

  schema "projection_results" do
    field :projected_balance, :decimal
    field :monthly_shortfall, :decimal
    field :recommended_monthly_savings, :decimal
    field :projected_at, :utc_datetime
    
    belongs_to :user, User
    belongs_to :retirement_goal, RetirementGoal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(projection_result, attrs) do
    projection_result
    |> cast(attrs, [:projected_balance, :monthly_shortfall, :recommended_monthly_savings, :projected_at, :user_id, :retirement_goal_id])
    |> validate_required([:projected_balance, :monthly_shortfall, :recommended_monthly_savings, :projected_at, :user_id])
    |> validate_number(:projected_balance, greater_than_or_equal_to: 0)
    |> validate_number(:monthly_shortfall, greater_than_or_equal_to: 0)
    |> validate_number(:recommended_monthly_savings, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:retirement_goal_id)
  end
end
