import Fluent

extension Team {

  /**
    Calculate and return the current balance of an Account for this team. May be
    a slow operation.
  */
  public func currentBalance(of account: Account) throws -> Int {
    // TODO: IMPROVE: this is a good candidate for improving once Fluent's API has settled.
    // Hopefully there is a method for summing this in the DB, otherwise we go
    // with direct SQL.
    var balance = try Transaction.makeQuery().filter("team_id", id).filter("credit_account", account.rawValue).all().reduce(0) { acc, t in
      return acc + t.amount
    }
    balance = try Transaction.makeQuery().filter("team_id", id).filter("debit_account", account.rawValue).all().reduce(balance) { acc, t in
      return acc - t.amount
    }
    return balance
  }

  /**
    Recalculate and set the current balance of the cash on hand account.
    Save the Team object afterwards.
  */
  public func recalculateCashOnHand() throws {
    cashOnHand = try currentBalance(of: .cashOnHand) * -1
    try save()
  }

}
