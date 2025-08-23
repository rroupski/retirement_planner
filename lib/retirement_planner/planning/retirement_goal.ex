defmodule RetirementPlanner.Planning.RetirementGoal do
  use Ecto.Schema
  import Ecto.Changeset
  alias RetirementPlanner.Accounts.User
  alias RetirementPlanner.Planning.ProjectionResult

  schema "retirement_goals" do
    field :target_retirement_age, :integer
    field :desired_annual_income, :decimal
    field :current_age, :integer
    field :inflation_rate, :decimal
    
    belongs_to :user, User
    has_many :projection_results, ProjectionResult

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(retirement_goal, attrs) do
    retirement_goal
    |> cast(attrs, [:target_retirement_age, :desired_annual_income, :current_age, :inflation_rate, :user_id])
    |> validate_required([:target_retirement_age, :desired_annual_income, :current_age, :inflation_rate, :user_id])
    |> validate_number(:target_retirement_age, greater_than: 0, less_than: 100)
    |> validate_number(:desired_annual_income, greater_than: 0)
    |> validate_number(:current_age, greater_than: 0, less_than: 100)
    |> validate_number(:inflation_rate, greater_than_or_equal_to: 0, less_than: 20)
    |> validate_retirement_age_greater_than_current()
    |> foreign_key_constraint(:user_id)
  end

  defp validate_retirement_age_greater_than_current(changeset) do
    current_age = get_field(changeset, :current_age)
    target_age = get_field(changeset, :target_retirement_age)
    
    if current_age && target_age && target_age <= current_age do
      add_error(changeset, :target_retirement_age, "must be greater than current age")
    else
      changeset
    end
  end
end
