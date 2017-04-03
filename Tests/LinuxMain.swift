import XCTest
@testable import CalendarTests
@testable import GeographyTests
@testable import LocalizationTests
@testable import PopulationTests

XCTMain([
  testCase(CalendarTests.allTests),
  testCase(GeographyTests.allTests),
  testCase(LocalizationTests.allTests),
  // Population
  testCase(NamesTests.allTests),
])
