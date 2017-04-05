import XCTest
@testable import CalendarTests
@testable import ConfigurationTests
@testable import GeographyTests
@testable import LocalizationTests
@testable import PopulationTests

XCTMain([
  testCase(CalendarTests.allTests),
  testCase(ConfigurationTests.allTests),
  testCase(GeographyTests.allTests),
  testCase(LocalizationTests.allTests),
  // Population
  testCase(NamesTests.allTests),
])
