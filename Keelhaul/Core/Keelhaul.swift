import Foundation

public final class Keelhaul {
  // MARK: - Private Static Properties

  private let endpointURL: NSURL
  private let receiptURL: NSURL?
  private let token: String

  // MARK: - Private Computed Properties

  private var validationRequest: NSURLRequest? {
    guard let receiptData = base64AppStoreReceipt,
      let deviceHash = deviceIdentifier?.SHA256
      else { return .None }

    let request = NSMutableURLRequest(URL: endpointURL)
    request.allHTTPHeaderFields = ["Content-Type": "application/json"]
    request.HTTPMethod = "POST"

    let jsonObject = [
      "receipt": [
        "data": receiptData,
        "device_hash": deviceHash,
      ]
    ]
    let options = NSJSONWritingOptions.init(rawValue: 0)
    try! request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonObject, options: options)

    return request
  }

  private var hasReceipt: Bool {
    return receiptURL?.checkResourceIsReachableAndReturnError(nil) ?? false
  }

  private var base64AppStoreReceipt: String? {
    guard let receiptURL = receiptURL,
      let appStoreReceipt = NSData(contentsOfURL: receiptURL) else { return .None }
    let options = NSDataBase64EncodingOptions(rawValue: 0)
    return appStoreReceipt.base64EncodedStringWithOptions(options)
  }

  // MARK: - Private Lazy Properties

  private lazy var session: NSURLSession = {
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    config.HTTPAdditionalHeaders = ["Authorization": "Token token=\"\(self.token)\""]
    let session = NSURLSession(configuration: config)
    return session
  }()

  private lazy var deviceIdentifier: String? = {
    #if os(iOS)
      return UIDevice.currentDevice().identifierForVendor?.UUIDString
    #elseif os(OSX)
      let platformExpert: io_service_t
      let service = "IOPlatformExpertDevice"
      let key = kIOPlatformSerialNumberKey
      let allocator = kCFAllocatorDefault
      platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching(service))
      let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, key, allocator, 0)
      IOObjectRelease(platformExpert)
      return serialNumberAsCFString.takeUnretainedValue() as? String
    #endif
  }()

  // MARK: - Public Methods

  public init(token: String,
    receiptURL: NSURL? = NSBundle.mainBundle().appStoreReceiptURL,
    endpointURL: NSURL = NSURL(string: "https://keelhaul.thoughtbot.com/api/v1/validate")!,
    useSandbox: Bool = false) {
      let components = NSURLComponents(URL: endpointURL, resolvingAgainstBaseURL: false)
      components!.queryItems = [NSURLQueryItem(name: "sandbox", value: useSandbox ? "1" : "0")]
      self.token = token
      self.receiptURL = receiptURL
      self.endpointURL = components!.URL!
  }

  public final func validateReceipt(completion: (Receipt?, NSError?) -> Void) {
    guard hasReceipt else {
      completion(.None, KeelhaulError.MissingReceipt.toNSError())
      return
    }

    guard let request = validationRequest else {
      completion(.None, KeelhaulError.MissingDeviceHash.toNSError())
      return
    }

    session.dataTaskWithRequest(request) { data, response, error in
      guard let httpResponse = response as? NSHTTPURLResponse else {
        return completion(.None, KeelhaulError.InvalidHTTPResponse.toNSError(response?.description))
      }
      
      guard let data = data else {
        return completion(.None, KeelhaulError.MissingResponseData.toNSError(httpResponse.description))
      }

      guard httpResponse.statusCode != 401 else {
        return completion(.None, KeelhaulError.InvalidDeveloperAPIKey.toNSError(httpResponse.description))
      }

      guard [200, 400].contains(httpResponse.statusCode) else {
        return completion(.None, KeelhaulError.InvalidResponse.toNSError(httpResponse.description))
      }

      guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else {
        return completion(.None, KeelhaulError.MalformedResponseJSON.toNSError(httpResponse.description))
      }

      switch httpResponse.statusCode {
      case 200:
        let (receipt, error) = Receipt.parse(json)
        return completion(receipt, error)
      case 400:
        let error = KeelhaulError.parse(json)
        return completion(.None, error.toNSError(httpResponse.description))
      default:
        return completion(.None, KeelhaulError.InvalidResponse.toNSError(httpResponse.description))
      }
    }.resume()
  }
}
