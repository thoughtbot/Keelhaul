 public struct Keelhaul {
  private let receiptURL: NSURL?

  init() {
    receiptURL = NSBundle.mainBundle().appStoreReceiptURL
  }

  public var encodedAppStoreReceipt: NSData? {
    return base64AppStoreReceipt?.dataUsingEncoding(NSUTF8StringEncoding)
  }

  public var hasReceipt: Bool {
    return receiptURL?.checkResourceIsReachableAndReturnError(nil) ?? false
  }

  private var base64AppStoreReceipt: String? {
    guard let receiptURL = receiptURL,
      let appStoreReceipt = NSData(contentsOfURL: receiptURL) else { return .None }
    return appStoreReceipt.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
  }
}
