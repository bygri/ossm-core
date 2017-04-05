import Foundation

/*
  A timeline of the game simulation.

  Keeps track of the game timeline in memory and should persist to database on every tick.
*/
public final class Timeline {

  public init() {
    gameDate = Date(year: 0, day: 0, hour: 0, minute: 0, second: 0)
    timer = Timer(timeInterval: 1, repeats: true) { [weak self] timer in
       self?.timerTick()
    }
  }

  private var gameDate: Date
  private var timer: Timer?

  /// tick the timer every second to add a second to the game time
  func timerTick() {
    gameDate.addSecond()

    // TODO: add any other date time events here (ie. games every 7 days, training every day at certain hour etc.)
  }
}
