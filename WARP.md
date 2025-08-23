# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

RetirementPlanner is an Elixir Phoenix web application for retirement planning calculations and projections. It uses Phoenix LiveView for interactive UI, PostgreSQL for data persistence, and Tailwind CSS for styling.

## Development Commands

### Setup and Dependencies
```bash
# Initial setup - installs dependencies, sets up database, and builds assets
mix setup

# Install dependencies only
mix deps.get

# Database operations
mix ecto.create              # Create database
mix ecto.migrate            # Run migrations
mix ecto.reset              # Drop and recreate database with seeds
mix ecto.create --quiet && mix ecto.migrate --quiet  # Quiet setup for tests
```

### Development Server
```bash
# Start Phoenix server
mix phx.server

# Start Phoenix server with IEx console
iex -S mix phx.server
```
Server runs on `localhost:4000`

### Asset Management
```bash
# Setup assets (install Tailwind and esbuild if missing)
mix assets.setup

# Build assets for development
mix assets.build

# Build and minify assets for production
mix assets.deploy
```

### Testing
```bash
# Run all tests
mix test

# Run tests in watch mode
mix test --stale

# Run specific test file
mix test test/retirement_planner/planning_test.exs

# Run tests with coverage
mix test --cover
```

### Code Quality
```bash
# Format code
mix format

# Check formatting
mix format --check-formatted
```

## Architecture Overview

### Domain Structure
The application follows Phoenix's context pattern with clear domain boundaries:

#### Contexts
- **RetirementPlanner.Accounts**: User authentication and management (uses Phoenix generators)
- **RetirementPlanner.Planning**: Core retirement planning domain with business logic

#### Planning Domain Models
- **RetirementGoal**: User's retirement parameters (target age, desired income, current age, inflation rate)
- **RetirementAccount**: Retirement accounts (401k, IRA, etc.) with balances and contributions  
- **Investment**: Investment allocations with expected returns and risk levels
- **ProjectionResult**: Calculated retirement projections and recommendations

### Key Business Logic
The `RetirementPlanner.Planning` context contains sophisticated financial calculations:

- **Compound Growth Calculations**: Projects account balances using compound interest
- **Portfolio Return Calculation**: Weighted returns based on investment allocations
- **Retirement Projections**: Comprehensive analysis using 4% withdrawal rule
- **Inflation Adjustment**: Accounts for inflation in retirement income needs
- **Gap Analysis**: Calculates shortfall and required monthly savings

### Web Layer
- **Phoenix LiveView**: Interactive dashboard with real-time calculations (`DashboardLive`)
- **User Authentication**: Complete auth system with registration, login, password reset
- **Responsive UI**: Tailwind CSS with mobile-first design
- **Asset Pipeline**: esbuild for JavaScript, Tailwind for CSS

### Database
- PostgreSQL with Ecto migrations
- Decimal fields for financial precision
- Foreign key constraints and data validation
- Timestamps for audit trails

## Development Patterns

### Financial Calculations
- All monetary values use `Decimal` type for precision
- Calculations convert to float only when needed for math operations
- Input validation ensures reasonable bounds (ages 0-100, returns 0-30%)
- Business rules enforce data integrity (retirement age > current age)

### Phoenix Conventions
- Contexts contain business logic and data access
- LiveViews handle user interactions and real-time updates
- Components in `CoreComponents` module for reusable UI elements
- Routes organized by authentication requirements

### Testing Structure
- `test/support/` contains shared test utilities (`DataCase`, `ConnCase`)
- Tests organized by context (`accounts_test.exs`, planning domain tests)
- Factory pattern for test data generation

## Configuration Notes

### Database
- Development: PostgreSQL (configured in `config/dev.exs`)
- Test: Separate test database with quiet migrations
- Production: Database URL from environment

### Assets
- Tailwind CSS with custom brand colors and Phoenix LiveView integration
- esbuild for JavaScript compilation
- Heroicons integration for UI icons
- Static assets served from `priv/static/assets/`

### Authentication
- bcrypt for password hashing
- Phoenix generated authentication system
- Session-based authentication with CSRF protection
- Email confirmation and password reset flows
