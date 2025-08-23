defmodule RetirementPlanner.Repo.Migrations.CreateProjectionResults do
  use Ecto.Migration

  def change do
    create table(:projection_results) do
      add :projected_balance, :decimal
      add :monthly_shortfall, :decimal
      add :recommended_monthly_savings, :decimal
      add :projected_at, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)
      add :retirement_goal_id, references(:retirement_goals, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:projection_results, [:user_id])
    create index(:projection_results, [:retirement_goal_id])
  end
end
