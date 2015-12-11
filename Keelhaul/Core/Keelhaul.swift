public class Keelhaul {
  private let receiptURL: NSURL?

  var validationRequest: NSURLRequest {
    return NSURLRequest()
  }

  lazy var session: NSURLSession = {
    return NSURLSession()
  }()

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

  final func validateReceipt(completion: (Receipt?, NSError?) -> Void) {
    session.dataTaskWithRequest(validationRequest) { data, response, error in
      if let data = data {
        do {
          let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
          completion(Receipt.parse(json))
        } catch let error as NSError {
          completion(.None, error)
        }
      } else {
        completion(.None, error)
      }
    }.resume()
  }
}
