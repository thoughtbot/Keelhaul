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

  public init(token: String, receiptURL: NSURL? = NSBundle.mainBundle().appStoreReceiptURL) {
    self.token = token
    self.receiptURL = receiptURL
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

  public final func validateReceipt(completion: (Bool, Receipt?, NSError?) -> Void) {
    guard let request = validationRequest else {
      let error = NSError(domain: "com.thoughtbot.keelhaul", code: KeelhaulError.NoReceiptURL.rawValue, userInfo: nil)
      completion(false, .None, error)
      return
    }

    session.dataTaskWithRequest(request) { data, response, error in
      guard let httpResponse = response as? NSHTTPURLResponse else {
        let error = NSError(domain: "com.thoughtbot.keelhaul",
          code: KeelhaulError.ResponseIsNotHTTP.rawValue,
          userInfo: ["response": response ?? "F*ck this world, sir."])
        completion(false, .None, error)
        return
      }

      let code = httpResponse.statusCode
      if !(200..<300).contains(code) {
        let error = NSError(domain: "com.thoughtbot.keelhaul",
          code: KeelhaulError.FailureResponse.rawValue,
          userInfo: ["response": httpResponse])
        completion(false, .None, error)
        return
      }

      guard let data = data else {
        completion(true, .None, .None)
        return
      }

      do {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let (receipt, error) = Receipt.parse(json)
        completion(true, receipt, error)
      } catch let error as NSError {
        completion(true, .None, error)
      }
    }.resume()
  }
}
