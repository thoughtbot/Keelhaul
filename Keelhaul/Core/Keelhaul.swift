public struct Keelhaul {
  static let appStoreReceiptURL = NSBundle.mainBundle().appStoreReceiptURL

  public static var encodedAppStoreReceipt: NSData? {
    return base64AppStoreReceipt?.dataUsingEncoding(NSUTF8StringEncoding)
  }

  public static var hasReceipt: Bool {
    return appStoreReceiptURL?.checkResourceIsReachableAndReturnError(nil) ?? false
  }

  static var base64AppStoreReceipt: String? {
    guard let receiptURL = appStoreReceiptURL,
      let appStoreReceipt = NSData(contentsOfURL: receiptURL) else { return .None }
    return appStoreReceipt.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
  }
}
