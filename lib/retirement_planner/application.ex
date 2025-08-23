defmodule RetirementPlanner.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RetirementPlannerWeb.Telemetry,
      RetirementPlanner.Repo,
      {DNSCluster, query: Application.get_env(:retirement_planner, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RetirementPlanner.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RetirementPlanner.Finch},
      # Start a worker by calling: RetirementPlanner.Worker.start_link(arg)
      # {RetirementPlanner.Worker, arg},
      # Start to serve requests, typically the last entry
      RetirementPlannerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RetirementPlanner.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RetirementPlannerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
