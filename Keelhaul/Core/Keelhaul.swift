public final class Keelhaul {
  private let endpointURL: NSURL
  private let receiptURL: NSURL?
  private let token: String

  private var validationRequest: NSURLRequest? {
    guard let receiptData = base64AppStoreReceipt,
      let identifier = UIDevice.currentDevice().identifierForVendor?.UUIDString
      else { return .None }

    let request = NSMutableURLRequest(URL: endpointURL)
    request.allHTTPHeaderFields = ["Content-Type": "application/json"]
    request.HTTPMethod = "POST"

    let jsonObject = [
      "receipt": [
        "data": receiptData,
        "token": identifier,
      ]
    ]
    let options = NSJSONWritingOptions.init(rawValue: 0)
    try! request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonObject, options: options)

    return request
  }

  private lazy var session: NSURLSession = {
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    config.HTTPAdditionalHeaders = ["Authorization": "Token token=\"\(self.token)\""]
    let session = NSURLSession(configuration: config)
    return session
  }()

  public init(token: String,
    receiptURL: NSURL? = NSBundle.mainBundle().appStoreReceiptURL,
    endpointURL: NSURL = NSURL(string: "https://keelhaul.io/api/v1/validate")!) {
    self.token = token
    self.receiptURL = receiptURL
    self.endpointURL = endpointURL
  }

  private var hasReceipt: Bool {
    return receiptURL?.checkResourceIsReachableAndReturnError(nil) ?? false
  }

  private var base64AppStoreReceipt: String? {
    guard let receiptURL = receiptURL,
      let appStoreReceipt = NSData(contentsOfURL: receiptURL) else { return .None }
    let options = NSDataBase64EncodingOptions.init(rawValue: 0)
    return appStoreReceipt.base64EncodedStringWithOptions(options)
  }

  public final func validateReceipt(completion: (Bool, Receipt?, NSError?) -> Void) {
    guard hasReceipt else {
      let error = NSError(domain: "com.thoughtbot.keelhaul", code: KeelhaulError.MissingReceipt.rawValue, userInfo: nil)
      completion(false, .None, error)
      return
    }

    guard let request = validationRequest else {
      let error = NSError(domain: "com.thoughtbot.keelhaul", code: KeelhaulError.NoReceiptURL.rawValue, userInfo: nil)
      completion(false, .None, error)
      return
    }

    session.dataTaskWithRequest(request) { data, response, error in
      guard let httpResponse = response as? NSHTTPURLResponse else {
        let error = NSError(domain: "com.thoughtbot.keelhaul",
          code: KeelhaulError.ResponseIsNotHTTP.rawValue,
          userInfo: ["response": response ?? "Response is not HTTP."])
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
