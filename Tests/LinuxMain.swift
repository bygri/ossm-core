import XCTest
@testable import CalendarTests
@testable import GeographyTests
@testable import LocalizationTests

XCTMain([
  testCase(CalendarTests.allTests),
  testCase(GeographyTests.allTests),
  testCase(LocalizationTests.allTests),
])
