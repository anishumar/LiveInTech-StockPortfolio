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
- **Singleton Pattern** for NetworkManager (easy API migration)

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

### ✅ Step 6 — Polish, Charts, Transaction History (COMPLETED)
**Commit:** `feat(ui): chart + history + polish`

**What was delivered:**
- Custom stock line chart implementation with gradients and fill areas
- Transaction history view listing previous buys/sells with timestamps
- UI polish: SF Symbols, gradients, light/dark support, accessible font sizes
- Enhanced portfolio view with mini charts and improved navigation
- Comprehensive unit tests for new components

**How to test:**
- View portfolio with mini charts for each stock
- Access transaction history via clock icon in portfolio
- Filter transactions by buy/sell type
- Test chart rendering with different stock data

**Acceptance criteria:**
- Chart renders correctly with proper colors and scaling
- Transaction history shows all trades with proper formatting
- UI polish enhances user experience without breaking functionality

---

## 🚀 **Step 7 — Advanced Portfolio Analytics & Enhanced UX (PLANNED)**

### Overview
Enhance the portfolio with advanced analytics, better financial insights, and improved user experience.

### 📋 Step 7.1 — Portfolio Analytics Dashboard
**Commit:** `feat(analytics): portfolio dashboard with financial insights`

**What to deliver:**
- **Current Amount vs Total Invested**: Clear display of current portfolio value vs total amount invested
- **Portfolio Performance Graph**: Historical portfolio value tracking over time
- **Category Distribution**: Equity, Debt, Hybrid, and Other asset class breakdown
- **Performance Metrics**: ROI, annualized returns, and risk metrics
- **Analytics View**: Dedicated analytics tab with comprehensive insights

**Implementation Plan:**
1. Create `PortfolioAnalyticsViewModel` for calculations
2. Add `PortfolioAnalyticsView` with dashboard layout
3. Implement historical data tracking in `PortfolioStore`
4. Create category classification system for stocks
5. Add performance calculation algorithms

**Tests:**
- Unit tests for analytics calculations
- UI tests for dashboard interactions
- Performance tests for large datasets

---

### 📋 Step 7.2 — Enhanced UX & Navigation
**Commit:** `feat(ux): enhanced navigation and user experience`

**What to deliver:**
- **Tab-based Navigation**: Portfolio, Analytics, Trade, History tabs
- **Quick Actions**: Swipe gestures and quick trade buttons
- **Search & Filter**: Advanced stock search with filters
- **Notifications**: Price alerts and portfolio updates
- **Settings**: User preferences and customization options

**Implementation Plan:**
1. Redesign main navigation with TabView
2. Add swipe gestures for quick actions
3. Implement advanced search functionality
4. Create notification system for price alerts
5. Add settings and preferences management

**Tests:**
- UI tests for navigation flows
- Gesture recognition tests
- Search functionality tests

---

### 📋 Step 7.3 — Advanced Features
**Commit:** `feat(advanced): watchlist, alerts, and portfolio insights`

**What to deliver:**
- **Watchlist**: Track stocks without owning them
- **Price Alerts**: Notifications for price movements
- **Portfolio Insights**: AI-powered recommendations and insights
- **Export Features**: CSV export of portfolio and transactions
- **Dark Mode**: Enhanced dark mode with custom themes

**Implementation Plan:**
1. Create watchlist functionality
2. Implement price alert system
3. Add portfolio insights and recommendations
4. Create export functionality
5. Enhance dark mode with custom themes

**Tests:**
- Watchlist functionality tests
- Alert system tests
- Export feature tests

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

## Singleton Pattern & API Migration Strategy

### NetworkManager Singleton
The `NetworkManager` uses a singleton pattern to centralize all network operations:

```swift
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    // Environment Configuration
    private let useMockData = true // Set to false for real API calls
    
    func fetchAllStocks() -> AnyPublisher<[Stock], NetworkError> {
        if useMockData {
            return fetchMockStocks()
        } else {
            return fetchRealStocks()
        }
    }
}
```

### Easy API Migration
To switch from mock data to real API calls:

1. **Change Environment Flag**: Set `useMockData = false`
2. **Implement Real API**: Update `fetchRealStocks()` method
3. **Configure Endpoints**: Update `baseURL` and `apiKey`
4. **No Other Changes**: All ViewModels and Views remain unchanged

### Future API Implementation Template
```swift
private func fetchRealStocks() -> AnyPublisher<[Stock], NetworkError> {
    let url = URL(string: "\(baseURL)/api/stocks")!
    var request = URLRequest(url: url)
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    return URLSession.shared.dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: [Stock].self, decoder: JSONDecoder())
        .mapError { /* Handle errors */ }
        .eraseToAnyPublisher()
}
```

## Known Limitations

### Current (Step 2)
- Mock data only (no real stock API integration)
- Local persistence only (no cloud sync)
- Simulated network delays for testing purposes

### Planned Limitations
- Local persistence only (no cloud sync)
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
- Singleton pattern for centralized network operations
- Easy API migration with environment flags

### Testing Requirements
- At least one unit test per ViewModel
- At least one UI test per major flow
- Error scenario testing
- Performance testing where applicable

---

This roadmap ensures a systematic, testable approach to building the StockPort app with clear deliverables and acceptance criteria for each step.
