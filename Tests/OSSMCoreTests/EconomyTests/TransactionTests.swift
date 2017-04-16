import XCTest
import Fluent
@testable import OSSMCore

class TransactionTests: XCTestCase {

  static var allTests = [
    ("testCashOnHand", testCashOnHand),
    ("testAccountBalances", testAccountBalances),
  ]

  func testCashOnHand() throws {
    let driver = try MemoryDriver()
    let database = Database(driver)
    try Team.prepare(database)
    try Transaction.prepare(database)
    try Club.prepare(database)
    // Create a team
    let team = Team(displayName: "Team", clubId: nil, locationId: 0, cashOnHand: 0)
    try team.save()
    XCTAssertEqual(team.cashOnHand, 0)
    // Now add a bank transaction
    let transaction = Transaction(
      teamId: team.id!,
      date: Date(seconds: 0),
      creditAccount: .ticketSales,
      debitAccount: .cashOnHand,
      amount: 100
    )
    try transaction.save()
    // Reload team from database and check cash on hand
    guard let reloadTeam = try Team.find(team.id) else {
      XCTFail()
      return
    }
    XCTAssertEqual(reloadTeam.cashOnHand, 100)
  }

  func testAccountBalances() throws {
    let driver = try MemoryDriver()
    let database = Database(driver)
    try Team.prepare(database)
    try Transaction.prepare(database)
    // Create a team
    let team = Team(displayName: "Team", clubId: nil, locationId: 0, cashOnHand: 0)
    try team.save()
    XCTAssertEqual(team.cashOnHand, 0)
    // Ticket sales of 100
    try Transaction(
      teamId: team.id!,
      date: Date(seconds: 0),
      creditAccount: .ticketSales,
      debitAccount: .cashOnHand,
      amount: 100
    ).save()
    // Player wages of 40
    try Transaction(
      teamId: team.id!,
      date: Date(seconds: 0),
      creditAccount: .cashOnHand,
      debitAccount: .playerWages,
      amount: 40
    ).save()
    // Now check the balances
    XCTAssertEqual(try team.currentBalance(of: .ticketSales), 100)
    XCTAssertEqual(try team.currentBalance(of: .playerWages), -40)
    XCTAssertEqual(try team.currentBalance(of: .cashOnHand), -60)
  }

}
