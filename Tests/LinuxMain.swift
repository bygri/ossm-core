import XCTest
@testable import OSSMCoreTests

XCTMain([

  // Calendar
  testCase(CalendarTests.allTests),

  // Configuration
  testCase(ConfigurationTests.allTests),

  // Geography
  testCase(LocationTests.allTests),

  // Localization
  testCase(LocalizationTests.allTests),

  // Models
  testCase(ClubTests.allTests),
  testCase(PersistenceTests.allTests),
  // Utilities
  testCase(ColorTests.allTests),

  // Population
  testCase(NamesTests.allTests),

])
