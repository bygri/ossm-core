
public struct Date {
  let year: Int
  let day: Int
  let hour: Int
  let minute: Int
  let second: Int

  func addSecond() {
    second += 1

    if second >= 60 {
      minute += 1
      second = 0
    }

    if minute >= 60 {
      hour += 1
      minute = 0
    }

    if hour >= 24 {
      day += 1
      hour = 0
    }

    if day >= 365 {
      year += 1
      day = 0
    }
  }
}
