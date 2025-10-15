# StockPort Development Roadmap

A comprehensive guide for building the StockPort SwiftUI app incrementally with MVVM + Combine architecture.

## Project Overview

**StockPort** is a modern iOS stock portfolio management app built with SwiftUI, MVVM, and Combine. The app allows users to manage their stock portfolio, buy/sell stocks, and track their investments with real-time data.

### Architecture
- **SwiftUI** for UI
- **MVVM** pattern for separation of concerns
- **Combine** for reactive programming
- **UserDefaults** for local persistence
- **Mock data** for development and testing

---

## Development Steps

### ✅ Step 0 — Project Skeleton (COMPLETED)
**Commit:** `init: project skeleton`

**What was delivered:**
- Xcode project with folder structure (Models/, ViewModels/, Views/, Network/, Persistence/, Resources/, Tests/)
- Empty SwiftUI App entry point named `StockPortApp`
- Basic data models: Stock, User, PortfolioItem, Transaction
- BaseViewModel for common functionality
- NetworkManager with mock data support
- UserSession and PortfolioStore for persistence
- SplashView as placeholder welcome screen
- Comprehensive README with run instructions
- Test targets configured with empty test files
- Sample stocks.json with 10 mock stocks

**How to test:**
- Open Xcode and build the project (should compile without errors)
- Run the app - should show animated splash screen with StockPort branding
- Run unit test target (empty tests should pass)
- Verify folder structure in Xcode navigator matches requirements

**Known Limitations:**
- No authentication flow yet
- No real network calls (mock data only)
- Basic UI without navigation

---

### ✅ Step 1 — Authentication Screens + Local Auth (COMPLETED)
**Commit:** `feat(auth): login & signup UI + local auth logic`

**What was delivered:**
- LoginView and SignupView with modern SwiftUI design
- AuthViewModel with comprehensive input validation:
  - Email format validation using regex
  - Password minimum 8 characters requirement
  - Confirm password matching validation
- UserStore for local user persistence with UserDefaults
- HomeView placeholder with logout functionality
- Updated main app to handle authentication flow with smooth transitions
- UserSession singleton for global authentication state management
- Seeded test user (test@stockport.com / Test@123)

**Tests:**
- Unit tests for AuthViewModel validation methods
- UI tests for complete login/signup flows
- UI tests for input validation error handling

**How to test:**
- Launch app - should show login screen
- Sign up with new credentials (email: newuser@example.com, password: NewPassword123)
- Logout and login with test credentials (test@stockport.com / Test@123)
- Try invalid email format - should show validation error
- Try short password - should show validation error
- Verify session persists across app relaunch

**Acceptance criteria:**
- Login/Signup flows work locally with proper validation
- Errors are shown and handled gracefully
- Session persists across app relaunch
- Unit & UI tests pass

---

### 🔄 Step 2 — Mock Stock Data + Network Layer (IN PROGRESS)
**Commit:** `feat(network): mock network & stocks JSON`

**What to deliver:**
- Enhanced NetworkManager that simulates REST calls with artificial delay
- Stock model with JSON decoding capabilities
- Endpoint functions: `fetchAllStocks()`, `fetchStock(symbol:)`
- Error handling: network error, decoding error, and timeout simulation
- Integration with existing stocks.json resource

**Tests:**
- Unit tests for correct JSON decoding
- Unit tests simulating network errors and ensuring proper error types
- Integration tests calling fetchAllStocks() from test or debug view

**How to test:**
- Call `fetchAllStocks()` from a test or small debug view to list stocks
- Verify stocks decode correctly from JSON
- Test network error scenarios and ensure NetworkManager returns proper error types

**Acceptance criteria:**
- Stocks decode correctly from JSON
- Network layer returns predictable errors for test scenarios
- Mock network calls work with artificial delays

---

### 📋 Step 3 — Portfolio Page (PLANNED)
**Commit:** `feat(portfolio): portfolio list + total value`

**What to deliver:**
- PortfolioView (Home) showing:
  - Top summary: Total portfolio value (sum of quantity × current price)
  - List of purchased stocks: name, symbol, current price, quantity, total value per line
  - Pull-to-refresh that re-fetches stock prices (from mock NetworkManager)
- PortfolioViewModel that:
  - Loads user portfolio from Persistence/ (persisted purchases)
  - Merges portfolio quantities with latest prices from NetworkManager
  - Publishes total value and list updates
- Sample persisted portfolio seeded for test user (e.g., AAPL: 2, TSLA: 1)

**Tests:**
- Unit tests for PortfolioViewModel computations (total value calculation)
- UI test: open app while logged in, see portfolio seeded values displayed and total computed

**How to test:**
- Verify total value matches (quantity × displayed price)
- Pull-to-refresh modifies prices (mock change) and total updates
- Test edge cases: zero holdings handled gracefully

**Acceptance criteria:**
- Portfolio shows correct totals and updates on refresh
- Edge cases: zero holdings handled gracefully

---

### 📋 Step 4 — Buy / Sell Stock Flow (PLANNED)
**Commit:** `feat(trade): buy & sell UI + update persistence`

**What to deliver:**
- TradeView reachable from Portfolio for selecting a stock (search by symbol)
- Stock detail section with current price and daily change
- Buy and Sell controls:
  - Input for quantity (integer > 0)
  - Buy button: decreases cash balance (if you simulate cash) and increases holdings
  - Sell button: only enabled if user owns enough quantity
- Update Persistence/ so portfolio changes persist and PortfolioViewModel picks up updates
- Transaction model for history (symbol, qty, price, type, timestamp)

**Tests:**
- Unit tests for TradeViewModel to validate buy/sell logic (invalid qty, insufficient holdings, persistence)
- UI test for a full buy then see portfolio updated

**How to test:**
- Search for a stock (e.g., AAPL), buy 1 share — portfolio should show new quantity and total value
- Sell it back — quantity decreases
- Try to sell more than owned — app shows error

**Acceptance criteria:**
- Buying & selling update portfolio and persist across relaunch
- No negative quantities or inconsistent state

---

### 📋 Step 5 — Robustness & Edge Cases (PLANNED)
**Commit:** `chore(robustness): validation, error handling, offline`

**What to deliver:**
- Input validation improvements (prevent non-numeric input, clamp large quantities)
- Network retry/backoff for transient failures (simple exponential retry)
- Offline handling: if network unavailable, still show last known prices and mark them "stale"
- Concurrency safe persistence: ensure reads/writes use serial queue or `actor` to avoid races
- Clear error UIs for each failure: network, decoding, insufficient funds, invalid input

**Tests:**
- Unit tests simulating network failure + retries
- Unit tests verifying persistence concurrency does not corrupt data (simulate concurrent writes)

**How to test:**
- Turn off network simulation or force network error — app must show stale data and allow trades (with warnings)
- Rapidly perform buy/sell actions — state should remain consistent

**Acceptance criteria:**
- No crashes on network errors or rapid user actions
- Data stays consistent

---

### 📋 Step 6 — Polish, Charts, Transaction History (PLANNED)
**Commit:** `feat(ui): chart + history + polish`

**What to deliver:**
- Optional: simple stock line chart using `Charts` (or a minimal custom line view if unavailable)
- Transaction history view listing previous buys/sells with timestamps
- UI polish: SF Symbols, gradients, light/dark support, accessible font sizes
- Add unit tests covering new components

**How to test:**
- Open a stock detail, view its chart
- Go to Transaction history and confirm entries appear after trades

**Acceptance criteria:**
- Chart renders and history shows correct data

---

### 📋 Final Delivery (PLANNED)
**Commit:** `chore(final): docs, tests & demo`

**What to deliver:**
- README with:
  - Stepwise demo instructions
  - Sample test cases to run after each step
  - How to run unit/UI tests
- Full test coverage for core ViewModels (aim for >60%)
- A short video/GIF (optional) or sequence of screenshots showing the main flows

---

## Project Structure

```
StockPortfolio/
├── Models/                    # Data models
│   ├── Stock.swift           # Stock data model
│   ├── User.swift            # User authentication model
│   ├── PortfolioItem.swift   # Portfolio holdings model
│   └── Transaction.swift     # Buy/sell transaction model
├── ViewModels/               # MVVM view models
│   ├── BaseViewModel.swift   # Common functionality
│   ├── AuthViewModel.swift   # Authentication logic
│   ├── PortfolioViewModel.swift # Portfolio management
│   └── TradeViewModel.swift  # Buy/sell logic
├── Views/                    # SwiftUI views
│   ├── Auth/                 # Authentication views
│   │   ├── LoginView.swift
│   │   └── SignupView.swift
│   ├── SplashView.swift      # Welcome screen
│   ├── HomeView.swift        # Main portfolio view
│   └── TradeView.swift       # Buy/sell interface
├── Network/                  # Network layer
│   └── NetworkManager.swift  # Mock network calls
├── Persistence/              # Data persistence
│   ├── UserSession.swift     # Authentication state
│   ├── UserStore.swift       # User data storage
│   └── PortfolioStore.swift  # Portfolio data storage
├── Resources/                # Mock data and assets
│   └── stocks.json          # Sample stock data
└── Tests/                   # Unit and UI tests
    ├── StockPortfolioTests/     # Unit tests
    └── StockPortfolioUITests/   # UI tests
```

---

## Sample Credentials

For testing purposes, use these credentials:
- **Email:** `test@stockport.com`
- **Password:** `Test@123`

---

## Sample Mock Data

The app includes `Resources/stocks.json` with 10 sample stocks:
- AAPL (Apple Inc.) - $174.26
- TSLA (Tesla, Inc.) - $258.14
- GOOGL (Alphabet Inc.) - $135.50
- MSFT (Microsoft Corporation) - $378.85
- AMZN (Amazon.com, Inc.) - $145.30
- META (Meta Platforms, Inc.) - $312.45
- NVDA (NVIDIA Corporation) - $875.20
- NFLX (Netflix, Inc.) - $485.75
- AMD (Advanced Micro Devices, Inc.) - $128.90
- INTC (Intel Corporation) - $42.15

---

## Testing Strategy

### Unit Tests
- AuthViewModel validation methods
- PortfolioViewModel calculations
- TradeViewModel buy/sell logic
- NetworkManager error handling
- Persistence layer concurrency

### UI Tests
- Complete authentication flows
- Portfolio display and refresh
- Buy/sell stock workflows
- Error handling and validation
- Navigation between screens

### Test Coverage Goals
- Core ViewModels: >60% coverage
- Critical user flows: 100% UI test coverage
- Error scenarios: Comprehensive testing

---

## Known Limitations

### Current (Step 1)
- No real network calls (mock data only)
- Basic UI without advanced navigation
- Local persistence only (no cloud sync)

### Planned Limitations
- Mock data only (no real stock API integration)
- Local persistence only (no cloud sync)
- Simulated network delays for testing purposes
- Basic chart implementation (if Charts framework unavailable)

---

## Development Notes

### Commit Strategy
- Small, logical commits with clear messages
- Each step must be testable independently
- Include "How to test this step" in commit messages
- Document known limitations for each step

### Code Quality
- Modular, well-commented code
- MVVM pattern strictly followed
- Combine for reactive programming
- SwiftUI best practices
- Accessibility considerations

### Testing Requirements
- At least one unit test per ViewModel
- At least one UI test per major flow
- Error scenario testing
- Performance testing where applicable

---

This roadmap ensures a systematic, testable approach to building the StockPort app with clear deliverables and acceptance criteria for each step.
