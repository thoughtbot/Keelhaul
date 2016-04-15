import Foundation

public struct Receipt {
  public let ID: Int
  public let bundleID: String
  public let appVersion: String
  public let creationDate: NSDate
  public let requestDate: NSDate
  public let purchaseDate: NSDate

  static func parse(json: AnyObject) -> (Receipt?, NSError?) {
    guard let json = json as? [String: AnyObject] else {
      return (.None, KeelhaulError.MalformedResponseJSON.toNSError())
    }

    guard let id = json["download_id"] as? Int,
      let bundleId = json["bundle_id"] as? String,
      let appVersion = json["application_version"] as? String,
      let creationDateString = json["receipt_creation_date_ms"] as? String,
      let requestDateString = json["request_date_ms"] as? String,
      let purchaseDateString = json["original_purchase_date_ms"] as? String
    else {
      return (.None, KeelhaulError.InsufficientResponseJSON.toNSError())
    }

    let creationDate = dateFromTimeIntervalString(creationDateString)
    let requestDate = dateFromTimeIntervalString(requestDateString)
    let purchaseDate = dateFromTimeIntervalString(purchaseDateString)

    let receipt = Receipt(ID: id,
      bundleID: bundleId,
      appVersion: appVersion,
      creationDate: creationDate,
      requestDate: requestDate,
      purchaseDate: purchaseDate)
    return (receipt, .None)
  }
}

private func dateFromTimeIntervalString(string: String) -> NSDate {
  let milliSeconds = Int(string) ?? 0
  let interval = NSTimeInterval(milliSeconds / 1000)
  return NSDate(timeIntervalSince1970: interval)
}
