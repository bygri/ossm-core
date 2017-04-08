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

  // Population
  testCase(NamesTests.allTests),

])
