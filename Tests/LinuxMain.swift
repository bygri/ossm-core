import XCTest
@testable import OSSMCoreTests

XCTMain([

  // Calendar
  testCase(CalendarTests.allTests),

  // Configuration
  testCase(ConfigurationTests.allTests),

  // Geography
  testCase(GeographyTests.allTests),

  // Localization
  testCase(LocalizationTests.allTests),

  // Models
  testCase(ClubTests.allTests),
  testCase(PersistenceTests.allTests),

  // Population
  testCase(NamesTests.allTests),

])
