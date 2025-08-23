defmodule RetirementPlanner.Planning.RetirementAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias RetirementPlanner.Accounts.User

  schema "retirement_accounts" do
    field :name, :string
    field :account_type, :string
    field :current_balance, :decimal
    field :annual_contribution, :decimal
    field :employer_match, :decimal
    
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @account_types ["401k", "403b", "IRA", "Roth IRA", "SEP-IRA", "Simple IRA", "Pension", "Other"]

  @doc false
  def changeset(retirement_account, attrs) do
    retirement_account
    |> cast(attrs, [:name, :account_type, :current_balance, :annual_contribution, :employer_match, :user_id])
    |> validate_required([:name, :account_type, :current_balance, :user_id])
    |> validate_inclusion(:account_type, @account_types)
    |> validate_number(:current_balance, greater_than_or_equal_to: 0)
    |> validate_number(:annual_contribution, greater_than_or_equal_to: 0)
    |> validate_number(:employer_match, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
  end
end
