import XCTest
@testable import CalendarTests
@testable import ConfigurationTests
@testable import GeographyTests
@testable import LocalizationTests
@testable import PopulationTests

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
