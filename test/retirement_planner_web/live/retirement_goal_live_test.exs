defmodule RetirementPlannerWeb.RetirementGoalLiveTest do
  use RetirementPlannerWeb.ConnCase

  import Phoenix.LiveViewTest
  import RetirementPlanner.PlanningFixtures

  @create_attrs %{target_retirement_age: 42, desired_annual_income: "120.5", current_age: 42, inflation_rate: "120.5"}
  @update_attrs %{target_retirement_age: 43, desired_annual_income: "456.7", current_age: 43, inflation_rate: "456.7"}
  @invalid_attrs %{target_retirement_age: nil, desired_annual_income: nil, current_age: nil, inflation_rate: nil}

  defp create_retirement_goal(%{user: user}) do
    retirement_goal = retirement_goal_fixture(%{user_id: user.id})
    %{retirement_goal: retirement_goal}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_retirement_goal]

    test "lists all retirement_goals", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/goals")

      assert html =~ "Listing Retirement goals"
    end

    test "saves new retirement_goal", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/goals")

      assert index_live |> element("a", "New Retirement goal") |> render_click() =~
               "New Retirement goal"

      assert_patch(index_live, ~p"/goals/new")

      assert index_live
             |> form("#retirement_goal-form", retirement_goal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#retirement_goal-form", retirement_goal: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/goals")

      html = render(index_live)
      assert html =~ "Retirement goal created successfully"
    end

    test "updates retirement_goal in listing", %{conn: conn, retirement_goal: retirement_goal} do
      {:ok, index_live, _html} = live(conn, ~p"/goals")

      assert index_live |> element("#retirement_goals-#{retirement_goal.id} a", "Edit") |> render_click() =~
               "Edit Retirement goal"

      assert_patch(index_live, ~p"/goals/#{retirement_goal}/edit")

      assert index_live
             |> form("#retirement_goal-form", retirement_goal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#retirement_goal-form", retirement_goal: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/goals")

      html = render(index_live)
      assert html =~ "Retirement goal updated successfully"
    end

    test "deletes retirement_goal in listing", %{conn: conn, retirement_goal: retirement_goal} do
      {:ok, index_live, _html} = live(conn, ~p"/goals")

      assert index_live |> element("#retirement_goals-#{retirement_goal.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#retirement_goals-#{retirement_goal.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_retirement_goal]

    test "displays retirement_goal", %{conn: conn, retirement_goal: retirement_goal} do
      {:ok, _show_live, html} = live(conn, ~p"/goals/#{retirement_goal}")

      assert html =~ "Show Retirement goal"
    end

    test "updates retirement_goal within modal", %{conn: conn, retirement_goal: retirement_goal} do
      {:ok, show_live, _html} = live(conn, ~p"/goals/#{retirement_goal}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Retirement goal"

      assert_patch(show_live, ~p"/goals/#{retirement_goal}/edit")

      assert show_live
             |> form("#retirement_goal-form", retirement_goal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#retirement_goal-form", retirement_goal: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/goals/#{retirement_goal}")

      html = render(show_live)
      assert html =~ "Retirement goal updated successfully"
    end
  end
end
