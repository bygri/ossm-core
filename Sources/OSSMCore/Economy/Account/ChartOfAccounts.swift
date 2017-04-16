/**
  OSSM's standard chart of accounts.

  Remember, to increase the balance of an account use:
  - a debit for an asset
  - a credit for a liability
  - a credit for revenue
  - a debit for an expense
*/
public enum Account: Int {
  // Assets
  /// Current
  case cashOnHand = 100
  /// Fixed
  case stadiumAsset = 150
  // Liabilities
  /// Current
  case bankLoan = 200
  // Revenue
  case ticketSales = 300
  case merchandiseSales = 310
  case membershipFees = 320
  case sponsorship = 330
  case prizes = 340
  // Expenses
  case playerWages = 400
  case staffWages = 410
  case stadiumMaintenance = 420
  case stadiumRental = 430
  case interestExpense = 440
  case competitionFees = 450
  // case depreciation -?
  // case incomeTax -?
}
