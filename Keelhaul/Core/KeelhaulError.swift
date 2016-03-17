import Foundation

private let keelhaulErrorDomain = "com.thoughtbot.Keelhaul"
private let appleErrorDomain = "com.thoughtbot.Keelhaul.Apple"

public enum KeelhaulError: Int {
  case MalformedRequestJSON = 21000
  case MalformedReceiptData = 21002
  case UnauthenticSignature = 21003
  case WrongSubscriptionPassword = 21004
  case AppleServerUnavailable = 21005
  case ExpiredSubscription = 21006
  case SanboxReceiptEnvMismatch = 21007
  case ProductionReceiptEnvMismatch = 21008

  case MalformedResponseJSON = 20000
  case InsufficientResponseJSON = 20001
  case MissingReceipt = 20002
  case MissingDeviceHash = 20003
  case InvalidHTTPResponse = 20004
  case MissingResponseData = 20005
  case InvalidResponse = 20006
  case InvalidDeveloperAPIKey = 20007
  case DeviceMismatch = 20009
  case UnknownSDKError = 20020

  func toNSError(info: String? = nil) -> NSError {
    let message: String

    let domain = rawValue >= 21000 ? appleErrorDomain : keelhaulErrorDomain

    switch self {
    case .MalformedResponseJSON: message = "Malformed response JSON."
    case .InsufficientResponseJSON: message = "Insufficient Response JSON."
    case .MissingReceipt: message = "No receipt was found. Request a receipt from Apple and try again."
    case .MissingDeviceHash: message = "Missing device identifier."
    case .InvalidHTTPResponse: message = "Response is not HTTP. Verify the endpoint and try again."
    case .MissingResponseData: message = "The server response contains no receipt data."
    case .InvalidResponse: message = "Invalid server response."
    case .InvalidDeveloperAPIKey: message = "The developer API key is invalid. Verify the API key and try again."
    case .DeviceMismatch: message = "Mismatching device. This receipt has been already validated with a different device."
    case .UnknownSDKError: message = "Unknown Keelhaul SDK error."
    case .MalformedRequestJSON: message = "The App Store could not read the JSON object you provided."
    case .MalformedReceiptData: message = "The data in the receipt-data property was malformed or missing."
    case .UnauthenticSignature: message = "The receipt could not be authenticated."
    case .WrongSubscriptionPassword: message = "The shared secret you provided does not match the shared secret on file for your account."
    case .AppleServerUnavailable: message = "The receipt server is not currently available."
    case .ExpiredSubscription: message = "This receipt is valid but the subscription has expired."
    case .SanboxReceiptEnvMismatch: message = "This receipt is from the test environment, but it was sent to the production environment for verification."
    case .ProductionReceiptEnvMismatch: message = "This receipt is from the production environment, but it was sent to the test environment for verification."
    }

    var userInfo = [NSLocalizedDescriptionKey: message]

    if let info = info {
      userInfo["Details"] = info
    }

    return NSError(domain: domain, code: rawValue, userInfo: userInfo)
  }

  static func parse(json: AnyObject) -> KeelhaulError {
    guard let json = json as? [String: AnyObject] else { return .MalformedResponseJSON }
    guard let code = json["status"] as? Int else { return .InsufficientResponseJSON }
    return KeelhaulError(rawValue: code) ?? .UnknownSDKError
  }
}
