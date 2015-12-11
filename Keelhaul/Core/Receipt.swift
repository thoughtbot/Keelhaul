struct Receipt {
  let ID: Int
  let bundleID: String
  let appVersion: String
  let creationDate: NSDate
  let requestDate: NSDate
  let purchaseDate: NSDate

  static func parse(json: AnyObject) -> (Receipt?, NSError?) {
    guard let json = json as? [String: AnyObject],
      let status = json["status"] as? Int else {
        let error = NSError(domain: "com.thoughtbot.keelhaul", code: 0, userInfo: .None)
        return (.None, error)
    }

    if status != 0 {
      let error = NSError(domain: "com.thoughtbot.keelhaul", code: status, userInfo: .None)
      return (.None, error)
    }

    guard let receiptDict = json["receipt"] as? [String: AnyObject],
      let id = receiptDict["download_id"] as? Int,
      let bundleId = receiptDict["bundle_id"] as? String,
      let appVersion = receiptDict["application_version"] as? String,
      let creationDateString = receiptDict["receipt_creation_date_ms"] as? String,
      let requestDateString = receiptDict["request_date_ms"] as? String,
      let purchaseDateString = receiptDict["original_purchase_date_ms"] as? String
    else {
      let error = NSError(domain: "com.thoughtbot.keelhaul", code: 0, userInfo: .None)
      return (.None, error)
    }

    let creationDate = dateFromTimeIntervalString(creationDateString)
    let requestDate = dateFromTimeIntervalString(requestDateString)
    let purchaseDate = dateFromTimeIntervalString(purchaseDateString)

    let receipt = Receipt(ID: id, bundleID: bundleId, appVersion: appVersion, creationDate: creationDate, requestDate: requestDate, purchaseDate: purchaseDate)
    return (receipt, .None)
  }
}

private func dateFromTimeIntervalString(string: String) -> NSDate {
  return NSDate(timeIntervalSince1970:NSTimeInterval(Int(string) ?? 0))
}
