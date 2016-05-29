import XCTest
@testable import ossmcoreTestSuite

XCTMain([
	testCase(DBTests.allTests),
	testCase(UserTests.allTests),
	testCase(LocationTests.allTests),
	testCase(ClubTests.allTests),
])
