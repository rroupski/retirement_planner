defmodule RetirementPlanner.Repo.Migrations.CreateRetirementAccounts do
  use Ecto.Migration

  def change do
    create table(:retirement_accounts) do
      add :name, :string
      add :account_type, :string
      add :current_balance, :decimal
      add :annual_contribution, :decimal
      add :employer_match, :decimal
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:retirement_accounts, [:user_id])
  end
end
