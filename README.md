# RetirementPlanner

A comprehensive Elixir Phoenix web application for retirement planning calculations and projections. Plan your financial future with sophisticated compound growth calculations, portfolio analysis, and retirement gap analysis.

## ✨ Features

- **Interactive Dashboard**: Real-time retirement calculations using Phoenix LiveView
- **Comprehensive Planning**: Set retirement goals, manage multiple accounts (401k, IRA, etc.)
- **Investment Analysis**: Portfolio allocation with weighted return calculations
- **Financial Projections**: Advanced compound growth modeling with inflation adjustments
- **Gap Analysis**: Calculate retirement shortfall and required monthly savings
- **4% Withdrawal Rule**: Industry-standard retirement income projections
- **User Authentication**: Complete auth system with registration, login, and password reset
- **Responsive Design**: Mobile-first UI built with Tailwind CSS

## 🚀 Getting Started

### Prerequisites

- Elixir 1.14+ and Erlang/OTP 25+
- PostgreSQL 14+
  - Hints:
    Ensure PostgreSQL is installed and running before proceeding.
    In development, the project uses the "postgres" user, perhaps create the user "postgres", so you don't have to change the config/dev.exs database configuration:
    ```bash
    psql -d postgres -c "CREATE USER postgres WITH SUPERUSER CREATEDB CREATEROLE;"
    ```

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/rroupski/retirement_planner.git
   cd retirement_planner
   ```

2. Install dependencies and set up the database:
   ```bash
   mix setup
   ```
   This command will:
   - Install Elixir dependencies with `mix deps.get`
   - Create and migrate the database
   - Install and build assets

3. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

4. Visit [`localhost:4000`](http://localhost:4000) in your browser

### Alternative Setup Commands

```bash
# Install dependencies only
mix deps.get

# Database operations
mix ecto.create              # Create database
mix ecto.migrate             # Run migrations
mix ecto.reset               # Drop and recreate database with seeds

# Start server with IEx console
iex -S mix phx.server

# Asset management
mix assets.setup             # Install Tailwind and esbuild
mix assets.build             # Build assets for development
mix assets.deploy            # Build and minify for production
```

## 🧪 Testing

```bash
# Run all tests
mix test

# Run tests in watch mode
mix test --stale

# Run with coverage
mix test --cover

# Run specific test file
mix test test/retirement_planner/planning_test.exs
```

## 🏗️ Architecture

### Domain Structure

The application follows Phoenix's context pattern with clear domain boundaries:

#### Core Contexts
- **RetirementPlanner.Accounts**: User authentication and management
- **RetirementPlanner.Planning**: Core retirement planning domain with business logic

#### Planning Domain Models
- **RetirementGoal**: User's retirement parameters (target age, income, inflation rate)
- **RetirementAccount**: Retirement accounts (401k, IRA) with balances and contributions
- **Investment**: Investment allocations with expected returns and risk levels
- **ProjectionResult**: Calculated retirement projections and recommendations

### Key Features

- **Financial Precision**: All monetary calculations use `Decimal` type for accuracy
- **Sophisticated Calculations**: Compound growth, portfolio returns, inflation adjustments
- **Real-time UI**: Phoenix LiveView for interactive dashboard updates
- **Data Validation**: Input validation with reasonable bounds and business rules
- **Responsive Design**: Mobile-first approach with Tailwind CSS

## 🛠️ Development

### Code Quality

```bash
# Format code
mix format

# Check formatting
mix format --check-formatted
```

### Database

- **Development**: PostgreSQL (configured in `config/dev.exs`)
- **Test**: Separate test database with quiet migrations
- **Production**: Database URL from environment variables

## 📦 Tech Stack

- **Backend**: Elixir 1.14+, Phoenix 1.7+
- **Frontend**: Phoenix LiveView, Tailwind CSS, Alpine.js
- **Database**: PostgreSQL with Ecto
- **Assets**: esbuild (JavaScript), Tailwind CSS
- **Authentication**: Phoenix generated auth system with bcrypt
- **Testing**: ExUnit with factory pattern

## 🚀 Deployment

Ready to run in production? Check the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

The application is configured for deployment with:
- Environment-based configuration
- Asset compilation and minification
- Database migrations
- SSL/HTTPS support

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`mix test`)
4. Format code (`mix format`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [Phoenix Framework](https://www.phoenixframework.org/)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/)
- [Elixir](https://elixir-lang.org/)
- [Ecto](https://hexdocs.pm/ecto/)
- [Tailwind CSS](https://tailwindcss.com/)
