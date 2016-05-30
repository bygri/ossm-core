import XCTest
@testable import OSSMCoreTestSuite

XCTMain([
	testCase(DBTests.allTests),
	testCase(UserTests.allTests),
	testCase(LocationTests.allTests),
	testCase(ClubTests.allTests),
])
