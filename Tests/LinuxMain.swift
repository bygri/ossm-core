import XCTest
@testable import OSSMCoreTests

XCTMain([

  // Calendar
  testCase(CalendarTests.allTests),

  // Configuration
  testCase(ConfigurationTests.allTests),
  testCase(PersistenceTests.allTests),

  // Economy
  testCase(TransactionTests.allTests),

  // Geography
  testCase(LocationTests.allTests),

  // Localization
  testCase(LocalizationTests.allTests),

  // Population
  testCase(NamesTests.allTests),
  testCase(SimTests.allTests),

  // Teams
  testCase(ClubTests.allTests),

  // Utilities
  testCase(ColorTests.allTests),
  testCase(NodeConvertibleEnumTests.allTests),

])
