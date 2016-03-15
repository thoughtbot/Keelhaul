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
    endpointURL: NSURL = NSURL(string: "https://keelhaul.io/api/v1/validate")!) {
    self.token = token
    self.receiptURL = receiptURL
    self.endpointURL = endpointURL
  }

  public final func validateReceipt(completion: (Bool, Receipt?, NSError?) -> Void) {
    guard hasReceipt else {
      completion(false, .None, KeelhaulError.MissingReceipt.toNSError())
      return
    }

    guard let request = validationRequest else {
      completion(false, .None, KeelhaulError.InvalidRequest.toNSError())
      return
    }

    session.dataTaskWithRequest(request) { data, response, error in
      guard let httpResponse = response as? NSHTTPURLResponse else {
        completion(false, .None, KeelhaulError.ResponseIsNotHTTP.toNSError(response?.description))
        return
      }

      switch httpResponse.statusCode {
      case 200..<300:
        guard let data = data else {
          return completion(false, .None, KeelhaulError.MissingReceiptData.toNSError(httpResponse.description))
        }

        do {
          let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
          let (receipt, error) = Receipt.parse(json)
          return completion(true, receipt, error)
        } catch let error as NSError {
          return completion(true, .None, error)
        }
      case 400:
        return completion(false, .None, KeelhaulError.MismatchingEnvironment.toNSError(httpResponse.description))
      case 401:
        return completion(false, .None, KeelhaulError.AuthenticationFailure.toNSError(httpResponse.description))
      case 403:
        return completion(false, .None, KeelhaulError.MismatchingDevice.toNSError(httpResponse.description))
      default:
        return completion(false, .None, KeelhaulError.FailureResponse.toNSError(httpResponse.description))
      }
    }.resume()
  }
}
