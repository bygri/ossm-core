
public struct Date {

  let daysPerYear: Int = 365

  var year: Int
  var day: Int
  var hour: Int
  var minute: Int
  var second: Int

  init(year: Int, day: Int, hour: Int, minute: Int, second: Int) {
    self.year = year
    self.day = day
    self.hour = hour
    self.minute = minute
    self.second = second
  }

  init(seconds: Int) {
    hour = seconds / 3600
    minute = (seconds % 3600) / 60
    second = (seconds % 3600) % 60

    day = hour / 24
    hour = hour % 24

    year = day / daysPerYear
    day = day % daysPerYear
  }

  mutating func addSecond() {
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

    if day >= daysPerYear {
      year += 1
      day = 0
    }
  }
}
