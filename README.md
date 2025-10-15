# StockPort - SwiftUI Stock Portfolio App

A modern iOS stock portfolio management app built with SwiftUI, MVVM, and Combine.

## Features

- User authentication (login/signup)
- Stock portfolio management
- Buy/sell stock functionality
- Real-time portfolio valuation
- Transaction history
- Offline support with stale data indicators

## Getting Started

### Prerequisites

- Xcode 15+
- iOS 17.0+
- macOS 14.0+ (for development)

### Installation

1. Clone the repository
2. Open `StockPortfolio.xcodeproj` in Xcode
3. Build and run the project

### Sample Credentials

For testing purposes, use these credentials:

- **Email:** `test@stockport.com`
- **Password:** `Test@123`

## Project Structure

```
StockPortfolio/
├── Models/           # Data models
├── ViewModels/       # MVVM view models
├── Views/           # SwiftUI views
│   └── Auth/        # Authentication views
├── Network/         # Network layer
├── Persistence/     # Data persistence
├── Resources/       # Mock data and assets
└── Tests/          # Unit and UI tests
```

## Running Tests

### Unit Tests
```bash
# Run unit tests
xcodebuild test -scheme StockPortfolio -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests
```bash
# Run UI tests
xcodebuild test -scheme StockPortfolio -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:StockPortfolioUITests
```

## Development

This project follows an incremental development approach with the following steps:

1. **Step 0:** Project skeleton and basic setup
2. **Step 1:** Authentication screens and local auth logic
3. **Step 2:** Mock stock data and network layer
4. **Step 3:** Portfolio page with total value calculation
5. **Step 4:** Buy/sell stock functionality
6. **Step 5:** Robustness and edge case handling
7. **Step 6:** UI polish, charts, and transaction history

## Known Limitations

- Currently uses mock data only (no real stock API integration)
- Local persistence only (no cloud sync)
- Simulated network delays for testing purposes

## License

This project is for educational purposes.
