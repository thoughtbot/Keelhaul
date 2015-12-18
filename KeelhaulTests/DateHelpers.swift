import Foundation

private let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!

func dateWith(year year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> NSDate {
  let components = NSDateComponents()
  components.year = year
  components.month = month
  components.day = day
  components.hour = hour
  components.minute = minute
  components.second = second
  components.timeZone = NSTimeZone(abbreviation: "UTC")
  return calendar.dateFromComponents(components)!
}
