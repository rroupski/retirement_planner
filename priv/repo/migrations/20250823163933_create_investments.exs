defmodule RetirementPlanner.Repo.Migrations.CreateInvestments do
  use Ecto.Migration

  def change do
    create table(:investments) do
      add :name, :string
      add :symbol, :string
      add :allocation_percentage, :decimal
      add :expected_return, :decimal
      add :risk_level, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:investments, [:user_id])
  end
end
