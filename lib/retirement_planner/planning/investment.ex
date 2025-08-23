defmodule RetirementPlanner.Planning.Investment do
  use Ecto.Schema
  import Ecto.Changeset
  alias RetirementPlanner.Accounts.User

  schema "investments" do
    field :name, :string
    field :symbol, :string
    field :allocation_percentage, :decimal
    field :expected_return, :decimal
    field :risk_level, :string
    
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @risk_levels ["Low", "Medium", "High"]

  @doc false
  def changeset(investment, attrs) do
    investment
    |> cast(attrs, [:name, :symbol, :allocation_percentage, :expected_return, :risk_level, :user_id])
    |> validate_required([:name, :allocation_percentage, :expected_return, :risk_level, :user_id])
    |> validate_inclusion(:risk_level, @risk_levels)
    |> validate_number(:allocation_percentage, greater_than: 0, less_than_or_equal_to: 100)
    |> validate_number(:expected_return, greater_than_or_equal_to: 0, less_than_or_equal_to: 30)
    |> foreign_key_constraint(:user_id)
  end
end
