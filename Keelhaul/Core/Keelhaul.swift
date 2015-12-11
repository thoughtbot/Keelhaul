public class Keelhaul {
  private let receiptURL: NSURL?
  private let token: String

  public var validationRequest: NSURLRequest? {
    #if DEBUG
    let endpoint = "http://localhost:5000/api/v1/validate?sandbox=1"
    #else
    let endpoint = "http://keelhaul.io/api/v1/validate?sandbox=0"
    #endif

    guard let receiptData = encodedAppStoreReceipt else { return .None }

    let request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
    request.HTTPMethod = "POST"
    request.HTTPBody = receiptData

    return request
  }

  lazy var session: NSURLSession = {
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    config.HTTPAdditionalHeaders = ["HTTP_AUTHORIZATION": "Token token=\"\(self.token)\""]
    let session = NSURLSession(configuration: config)
    return session
  }()

  init(token: String) {
    self.receiptURL = NSBundle.mainBundle().appStoreReceiptURL
    self.token = token
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
    guard let request = validationRequest else {
      let error = NSError(domain: "com.thoughtbot.keelhaul", code: 9000, userInfo: nil)
      completion(.None, error)
      return
    }

    session.dataTaskWithRequest(request) { data, response, error in
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
