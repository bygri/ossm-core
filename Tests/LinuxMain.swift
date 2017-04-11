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
  testCase(TransactionTests.allTests),
  // Utilities
  testCase(ColorTests.allTests),
  testCase(NodeConvertibleEnumTests.allTests),

  // Population
  testCase(NamesTests.allTests),

])
