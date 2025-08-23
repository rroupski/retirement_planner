defmodule RetirementPlanner.Repo.Migrations.CreateRetirementGoals do
  use Ecto.Migration

  def change do
    create table(:retirement_goals) do
      add :target_retirement_age, :integer
      add :desired_annual_income, :decimal
      add :current_age, :integer
      add :inflation_rate, :decimal
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:retirement_goals, [:user_id])
  end
end
