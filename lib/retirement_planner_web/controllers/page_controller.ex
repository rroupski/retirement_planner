defmodule RetirementPlannerWeb.PageController do
  use RetirementPlannerWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/dashboard")
    else
      # The home page is often custom made,
      # so skip the default app layout.
      render(conn, :home, layout: false)
    end
  end
end
