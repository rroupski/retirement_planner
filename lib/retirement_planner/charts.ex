defmodule RetirementPlanner.Charts do
  @moduledoc """
  Functions for generating chart configurations for retirement planning visualizations.
  """

  alias RetirementPlanner.Planning

  @doc """
  Generate a pie chart configuration for account allocation.
  """
  def account_allocation_chart(accounts) when is_list(accounts) do
    if Enum.empty?(accounts) do
      empty_chart_config("No Accounts", "Add retirement accounts to see allocation")
    else
      # TODO: do I need it?
      _total =
        Enum.reduce(accounts, Decimal.new(0), fn acc, sum ->
          Decimal.add(sum, acc.current_balance || Decimal.new(0))
        end)

      {labels, values, colors} =
        Enum.reduce(accounts, {[], [], []}, fn account, {labels, values, colors} ->
          balance = Decimal.to_float(account.current_balance || Decimal.new(0))

          {
            [account.name | labels],
            [balance | values],
            [account_type_color(account.account_type) | colors]
          }
        end)

      %{
        type: "pie",
        data: %{
          labels: Enum.reverse(labels),
          datasets: [
            %{
              data: Enum.reverse(values),
              backgroundColor: Enum.reverse(colors),
              borderWidth: 2,
              borderColor: "#ffffff"
            }
          ]
        },
        options: %{
          responsive: true,
          maintainAspectRatio: false,
          plugins: %{
            title: %{
              display: true,
              text: "Account Allocation",
              font: %{size: 16, weight: "bold"}
            },
            legend: %{
              position: "bottom",
              labels: %{
                padding: 20,
                usePointStyle: true
              }
            },
            tooltip: %{
              callbacks: %{
                label: "function(context) {
                  const value = new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD'
                  }).format(context.raw);
                  const total = context.dataset.data.reduce((a, b) => a + b, 0);
                  const percentage = ((context.raw / total) * 100).toFixed(1);
                  return context.label + ': ' + value + ' (' + percentage + '%)';
                }"
              }
            }
          }
        }
      }
    end
  end

  @doc """
  Generate a line chart configuration for retirement projection over time.
  """
  def retirement_projection_chart(projection, goal, accounts) do
    if is_nil(projection) or is_nil(goal) do
      empty_chart_config("Set Retirement Goal", "Add your retirement goal to see projections")
    else
      years_until_retirement = goal.target_retirement_age - goal.current_age

      current_total =
        Enum.reduce(accounts, Decimal.new(0), fn acc, sum ->
          Decimal.add(sum, acc.current_balance || Decimal.new(0))
        end)
        |> Decimal.to_float()

      # Generate year-by-year projections
      years = 0..years_until_retirement |> Enum.to_list()

      projected_values =
        Enum.map(years, fn year ->
          # TODO: do I need it?
          _age = goal.current_age + year

          if year == 0 do
            current_total
          else
            # Calculate compound growth for each year
            annual_contributions =
              Enum.reduce(accounts, 0, fn acc, sum ->
                contribution = Decimal.to_float(acc.annual_contribution || Decimal.new(0))
                match = Decimal.to_float(acc.employer_match || Decimal.new(0))
                sum + contribution + match
              end)

            Planning.compound_growth(
              current_total,
              annual_contributions / 12,
              # Default 7% return
              0.07,
              year
            )
          end
        end)

      ages = Enum.map(years, fn year -> goal.current_age + year end)
      target_line = List.duplicate(projection.nest_egg_needed, length(ages))

      %{
        type: "line",
        data: %{
          labels: ages,
          datasets: [
            %{
              label: "Projected Balance",
              data: projected_values,
              borderColor: "#10B981",
              backgroundColor: "rgba(16, 185, 129, 0.1)",
              borderWidth: 3,
              fill: true,
              tension: 0.4
            },
            %{
              label: "Target Nest Egg",
              data: target_line,
              borderColor: "#EF4444",
              backgroundColor: "transparent",
              borderWidth: 2,
              borderDash: [5, 5],
              fill: false,
              pointRadius: 0
            }
          ]
        },
        options: %{
          responsive: true,
          maintainAspectRatio: false,
          interaction: %{
            intersect: false,
            mode: "index"
          },
          plugins: %{
            title: %{
              display: true,
              text: "Retirement Projection Timeline",
              font: %{size: 16, weight: "bold"}
            },
            legend: %{
              position: "top"
            },
            tooltip: %{
              callbacks: %{
                label: "function(context) {
                  return context.dataset.label + ': ' + new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD',
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 0
                  }).format(context.raw);
                }"
              }
            }
          },
          scales: %{
            x: %{
              title: %{
                display: true,
                text: "Age"
              },
              grid: %{
                color: "rgba(0, 0, 0, 0.1)"
              }
            },
            y: %{
              title: %{
                display: true,
                text: "Account Balance"
              },
              ticks: %{
                callback: "function(value) {
                  return new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD',
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 0,
                    notation: 'compact'
                  }).format(value);
                }"
              },
              grid: %{
                color: "rgba(0, 0, 0, 0.1)"
              }
            }
          }
        }
      }
    end
  end

  @doc """
  Generate a doughnut chart configuration for investment allocations.
  """
  def investment_allocation_chart(investments) when is_list(investments) do
    if Enum.empty?(investments) do
      empty_chart_config(
        "No Investment Allocations",
        "Add investments to see allocation breakdown"
      )
    else
      {labels, values, colors} =
        Enum.reduce(investments, {[], [], []}, fn investment, {labels, values, colors} ->
          allocation = Decimal.to_float(investment.allocation_percentage || Decimal.new(0))

          {
            [investment.name | labels],
            [allocation | values],
            [risk_level_color(investment.risk_level) | colors]
          }
        end)

      %{
        type: "doughnut",
        data: %{
          labels: Enum.reverse(labels),
          datasets: [
            %{
              data: Enum.reverse(values),
              backgroundColor: Enum.reverse(colors),
              borderWidth: 2,
              borderColor: "#ffffff",
              hoverOffset: 4
            }
          ]
        },
        options: %{
          responsive: true,
          maintainAspectRatio: false,
          plugins: %{
            title: %{
              display: true,
              text: "Investment Allocation",
              font: %{size: 16, weight: "bold"}
            },
            legend: %{
              position: "bottom",
              labels: %{
                padding: 20,
                usePointStyle: true
              }
            },
            tooltip: %{
              callbacks: %{
                label: "function(context) {
                  return context.label + ': ' + context.raw + '%';
                }"
              }
            }
          },
          cutout: "60%"
        }
      }
    end
  end

  @doc """
  Generate a bar chart showing monthly savings scenarios.
  """
  def savings_scenarios_chart(projection, goal) do
    if is_nil(projection) or is_nil(goal) do
      empty_chart_config("Savings Analysis", "Set your retirement goal to see savings scenarios")
    else
      current_monthly =
        if projection.shortfall > 0 do
          projection.recommended_monthly_savings
        else
          0
        end

      scenarios = [
        {"Current Path", current_monthly},
        {"Conservative (+$500)", current_monthly + 500},
        {"Moderate (+$1000)", current_monthly + 1000},
        {"Aggressive (+$2000)", current_monthly + 2000}
      ]

      {labels, values} = Enum.unzip(scenarios)

      colors = ["#EF4444", "#F59E0B", "#10B981", "#3B82F6"]

      %{
        type: "bar",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: "Monthly Savings",
              data: values,
              backgroundColor: colors,
              borderColor: colors,
              borderWidth: 1,
              borderRadius: 6
            }
          ]
        },
        options: %{
          responsive: true,
          maintainAspectRatio: false,
          plugins: %{
            title: %{
              display: true,
              text: "Monthly Savings Scenarios",
              font: %{size: 16, weight: "bold"}
            },
            legend: %{
              display: false
            },
            tooltip: %{
              callbacks: %{
                label: "function(context) {
                  return 'Monthly Savings: ' + new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD'
                  }).format(context.raw);
                }"
              }
            }
          },
          scales: %{
            x: %{
              grid: %{
                display: false
              }
            },
            y: %{
              title: %{
                display: true,
                text: "Monthly Amount"
              },
              ticks: %{
                callback: "function(value) {
                  return new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD'
                  }).format(value);
                }"
              },
              grid: %{
                color: "rgba(0, 0, 0, 0.1)"
              }
            }
          }
        }
      }
    end
  end

  # Private helper functions

  # TODO: where can I show subtitle?
  defp empty_chart_config(title, _subtitle) do
    %{
      type: "doughnut",
      data: %{
        labels: ["No Data"],
        datasets: [
          %{
            data: [1],
            backgroundColor: ["#E5E7EB"],
            borderWidth: 0
          }
        ]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        plugins: %{
          title: %{
            display: true,
            text: title,
            font: %{size: 16, weight: "bold"}
          },
          legend: %{
            display: false
          },
          tooltip: %{
            enabled: false
          }
        },
        events: [],
        cutout: "60%"
      }
    }
  end

  defp account_type_color("401k"), do: "#3B82F6"
  defp account_type_color("403b"), do: "#8B5CF6"
  defp account_type_color("IRA"), do: "#10B981"
  defp account_type_color("Roth IRA"), do: "#F59E0B"
  defp account_type_color("SEP-IRA"), do: "#EF4444"
  defp account_type_color("Simple IRA"), do: "#84CC16"
  defp account_type_color("Pension"), do: "#06B6D4"
  defp account_type_color("Other"), do: "#6B7280"
  defp account_type_color(_), do: "#9CA3AF"

  @doc """
  Generate Monte Carlo simulation results visualization.
  """
  def monte_carlo_chart(monte_carlo_results) do
    success_rate = monte_carlo_results.success_rate

    # Create a gauge chart showing success probability
    %{
      type: "doughnut",
      data: %{
        labels: ["Success Probability", "Risk"],
        datasets: [
          %{
            data: [success_rate, 100 - success_rate],
            backgroundColor: [get_success_color(success_rate), "#E5E7EB"],
            borderWidth: 0,
            cutout: "80%"
          }
        ]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        plugins: %{
          title: %{
            display: true,
            text: "Monte Carlo Success Rate",
            font: %{size: 16, weight: "bold"}
          },
          legend: %{
            display: false
          },
          tooltip: %{
            callbacks: %{
              label: "function(context) {
                if (context.dataIndex === 0) {
                  return 'Success Rate: ' + context.raw.toFixed(1) + '%';
                } else {
                  return 'Risk: ' + context.raw.toFixed(1) + '%';
                }
              }"
            }
          }
        },
        elements: %{
          arc: %{
            roundedCornersFor: 0
          }
        }
      }
    }
  end

  @doc """
  Generate efficient frontier visualization.
  """
  def efficient_frontier_chart(asset_optimization) do
    if is_nil(asset_optimization.optimal_allocation) do
      empty_chart_config("Asset Optimization", "Run optimization to see efficient frontier")
    else
      # Create scatter plot showing risk vs return
      efficient_frontier = Map.get(asset_optimization, :efficient_frontier, [])

      frontier_points =
        efficient_frontier
        |> Enum.map(fn portfolio ->
          %{x: portfolio.target_volatility * 100, y: portfolio.expected_return * 100}
        end)

      # Add current and optimal portfolio points
      optimal_point = %{
        x: asset_optimization.target_volatility * 100,
        y: asset_optimization.expected_return * 100
      }

      %{
        type: "scatter",
        data: %{
          datasets: [
            %{
              label: "Efficient Frontier",
              data: frontier_points,
              backgroundColor: "#3B82F6",
              borderColor: "#3B82F6",
              showLine: true,
              fill: false,
              pointRadius: 4
            },
            %{
              label: "Optimal Portfolio",
              data: [optimal_point],
              backgroundColor: "#10B981",
              borderColor: "#10B981",
              pointRadius: 8
            }
          ]
        },
        options: %{
          responsive: true,
          maintainAspectRatio: false,
          plugins: %{
            title: %{
              display: true,
              text: "Efficient Frontier Analysis",
              font: %{size: 16, weight: "bold"}
            },
            legend: %{
              position: "top"
            }
          },
          scales: %{
            x: %{
              title: %{
                display: true,
                text: "Risk (Volatility %)"
              },
              ticks: %{
                callback: "function(value) { return value + '%'; }"
              }
            },
            y: %{
              title: %{
                display: true,
                text: "Expected Return (%)"
              },
              ticks: %{
                callback: "function(value) { return value + '%'; }"
              }
            }
          }
        }
      }
    end
  end

  @doc """
  Generate asset allocation rebalancing recommendations chart.
  """
  def rebalancing_chart(rebalancing_recommendations) do
    if Enum.empty?(rebalancing_recommendations) do
      empty_chart_config("Portfolio Rebalancing", "Your portfolio is well balanced")
    else
      {labels, current_data, target_data} =
        rebalancing_recommendations
        |> Enum.map(fn rec ->
          {
            rec.asset_class,
            rec.current_allocation * 100,
            rec.target_allocation * 100
          }
        end)
        |> unzip3()

      %{
        type: "bar",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: "Current Allocation",
              data: current_data,
              backgroundColor: "#EF4444",
              borderColor: "#DC2626",
              borderWidth: 1
            },
            %{
              label: "Target Allocation",
              data: target_data,
              backgroundColor: "#10B981",
              borderColor: "#059669",
              borderWidth: 1
            }
          ]
        },
        options: %{
          responsive: true,
          maintainAspectRatio: false,
          plugins: %{
            title: %{
              display: true,
              text: "Portfolio Rebalancing Recommendations",
              font: %{size: 16, weight: "bold"}
            },
            legend: %{
              position: "top"
            },
            tooltip: %{
              callbacks: %{
                label: "function(context) {
                  return context.dataset.label + ': ' + context.raw.toFixed(1) + '%';
                }"
              }
            }
          },
          scales: %{
            x: %{
              grid: %{
                display: false
              }
            },
            y: %{
              title: %{
                display: true,
                text: "Allocation Percentage"
              },
              ticks: %{
                callback: "function(value) { return value + '%'; }"
              },
              beginAtZero: true
            }
          }
        }
      }
    end
  end

  @doc """
  Generate retirement timeline optimization chart.
  """
  def timeline_optimization_chart(timeline_optimization) do
    scenarios = timeline_optimization.scenarios_analyzed

    if Enum.empty?(scenarios) do
      empty_chart_config("Timeline Optimization", "No scenarios available")
    else
      # TODO: do I need it?
      _feasible_scenarios = Enum.filter(scenarios, & &1.feasible)

      {ages, success_rates, overall_scores} =
        scenarios
        |> Enum.map(fn scenario ->
          {
            scenario.retirement_age,
            scenario.success_rate,
            Map.get(scenario, :overall_score, scenario.success_rate)
          }
        end)
        |> unzip3()

      # Highlight optimal retirement age if available
      optimal_age =
        if timeline_optimization.optimal_retirement_age do
          timeline_optimization.optimal_retirement_age.retirement_age
        else
          nil
        end

      %{
        type: "line",
        data: %{
          labels: ages,
          datasets: [
            %{
              label: "Success Rate",
              data: success_rates,
              borderColor: "#3B82F6",
              backgroundColor: "rgba(59, 130, 246, 0.1)",
              borderWidth: 2,
              fill: false,
              yAxisID: "y"
            },
            %{
              label: "Overall Score",
              data: overall_scores,
              borderColor: "#10B981",
              backgroundColor: "rgba(16, 185, 129, 0.1)",
              borderWidth: 2,
              fill: false,
              yAxisID: "y"
            }
          ]
        },
        options: %{
          responsive: true,
          maintainAspectRatio: false,
          interaction: %{
            intersect: false,
            mode: "index"
          },
          plugins: %{
            title: %{
              display: true,
              text: "Retirement Age Optimization",
              font: %{size: 16, weight: "bold"}
            },
            legend: %{
              position: "top"
            },
            annotation: get_optimal_age_annotation(optimal_age)
          },
          scales: %{
            x: %{
              title: %{
                display: true,
                text: "Retirement Age"
              }
            },
            y: %{
              title: %{
                display: true,
                text: "Score (%)"
              },
              beginAtZero: true,
              max: 100
            }
          }
        }
      }
    end
  end

  @doc """
  Generate contribution optimization chart.
  """
  def contribution_optimization_chart(contribution_optimization) do
    if is_nil(contribution_optimization) do
      empty_chart_config(
        "Contribution Optimization",
        "Set available monthly amount to see optimization"
      )
    else
      allocations = contribution_optimization.recommended_allocations

      if Enum.empty?(allocations) do
        empty_chart_config(
          "Contribution Optimization",
          "No contribution recommendations available"
        )
      else
        {labels, amounts, colors} =
          allocations
          |> Enum.map(fn allocation ->
            color =
              case allocation.priority do
                # Red for high priority (employer match)
                :high -> "#EF4444"
                # Orange for medium priority (tax optimization)
                :medium -> "#F59E0B"
                # Gray for low priority
                :low -> "#6B7280"
                _ -> "#9CA3AF"
              end

            {
              allocation.account_name,
              allocation.monthly_amount,
              color
            }
          end)
          |> unzip3()

        %{
          type: "doughnut",
          data: %{
            labels: labels,
            datasets: [
              %{
                data: amounts,
                backgroundColor: colors,
                borderWidth: 2,
                borderColor: "#ffffff",
                hoverOffset: 4
              }
            ]
          },
          options: %{
            responsive: true,
            maintainAspectRatio: false,
            plugins: %{
              title: %{
                display: true,
                text: "Optimized Monthly Contributions",
                font: %{size: 16, weight: "bold"}
              },
              legend: %{
                position: "bottom",
                labels: %{
                  padding: 20,
                  usePointStyle: true
                }
              },
              tooltip: %{
                callbacks: %{
                  label: "function(context) {
                    return context.label + ': $' + context.raw.toFixed(0) + '/month';
                  }"
                }
              }
            },
            cutout: "50%"
          }
        }
      end
    end
  end

  # Private helper functions for optimization charts

  defp unzip3(list) do
    list
    |> Enum.reduce({[], [], []}, fn {a, b, c}, {acc_a, acc_b, acc_c} ->
      {[a | acc_a], [b | acc_b], [c | acc_c]}
    end)
    |> then(fn {a, b, c} -> {Enum.reverse(a), Enum.reverse(b), Enum.reverse(c)} end)
  end

  defp get_success_color(success_rate) do
    cond do
      # Green
      success_rate >= 90 -> "#10B981"
      # Lime
      success_rate >= 80 -> "#84CC16"
      # Orange
      success_rate >= 70 -> "#F59E0B"
      # Red
      success_rate >= 60 -> "#EF4444"
      # Dark red
      true -> "#DC2626"
    end
  end

  defp get_optimal_age_annotation(nil), do: %{}

  defp get_optimal_age_annotation(optimal_age) do
    %{
      annotations: [
        %{
          type: "line",
          scaleID: "x",
          value: optimal_age,
          borderColor: "#10B981",
          borderWidth: 3,
          borderDash: [5, 5],
          label: %{
            content: "Optimal Age: #{optimal_age}",
            enabled: true,
            position: "top"
          }
        }
      ]
    }
  end

  defp risk_level_color("Low"), do: "#10B981"
  defp risk_level_color("Medium"), do: "#F59E0B"
  defp risk_level_color("High"), do: "#EF4444"
  defp risk_level_color(_), do: "#6B7280"
end
