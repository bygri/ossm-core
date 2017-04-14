import Fluent

public final class Transaction: Entity {

  public let teamId: Identifier

  /// The date the transaction was entered.
  public let date: Date

  public let creditAccount: Account

  public let debitAccount: Account

  public let amount: Int

  public let storage = Storage()

  public func team() throws -> Parent<Transaction, Team> {
    return parent(id: teamId)
  }

  public init(
    teamId: Identifier,
    date: Date,
    creditAccount: Account,
    debitAccount: Account,
    amount: Int
  ) {
    self.teamId = teamId
    self.date = date
    self.creditAccount = creditAccount
    self.debitAccount = debitAccount
    self.amount = amount
  }

  public init(row: Row) throws {
    teamId = try row.get("team_id")
    date = try row.get("date")
    creditAccount = try row.get("credit_account")
    debitAccount = try row.get("debit_account")
    amount = try row.get("amount")
  }

  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("team_id", teamId)
    try row.set("date", date)
    try row.set("credit_account", creditAccount)
    try row.set("debit_account", debitAccount)
    try row.set("amount", amount)
    try row.set(idKey, id)
    return row
  }

  public func didCreate() {
    // If the transaction affected cash on hand, recalculate cash on hand.
    if creditAccount == .cashOnHand || debitAccount == .cashOnHand {
      // TODO IMPROVE: `didCreate()` cannot throw, but `team().get()` can throw.
      // This is a wishy-washy 'silent fail'.
      try? team().get()?.recalculateCashOnHand()
    }
  }

}

extension Transaction: Preparation {

  public static func prepare(_ database: Fluent.Database) throws {
    try database.create(self) { t in
      t.id()
      t.foreignId(for: Team.self)
      t.int("date")
      t.int("credit_account")
      t.int("debit_account")
      t.int("amount")
    }
  }

  public static func revert(_ database: Fluent.Database) throws {
    try database.delete(self)
  }

}
