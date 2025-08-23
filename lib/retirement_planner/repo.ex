defmodule RetirementPlanner.Repo do
  use Ecto.Repo,
    otp_app: :retirement_planner,
    adapter: Ecto.Adapters.Postgres
end
