import Foundation

private let domain = "com.thoughtbot.Keelhaul"

public enum KeelhaulError: Int {
  case AuthenticationFailure = 9001
  case BadJSON = 9002
  case FailureResponse = 9003
  case InsufficientJSON = 9004
  case InvalidRequest = 9005
  case MismatchingDevice = 9006
  case MismatchingEnvironment = 9007
  case MissingReceipt = 9008
  case MissingReceiptData = 9009
  case ResponseIsNotHTTP = 9000

  func toNSError(info: String? = nil) -> NSError {
    let message: String

    switch self {
    case .InvalidRequest:
      message = "Invalid receipt data or missing device identifier. Request a receipt from Apple and try again."
    case .MissingReceipt:
      message = "No receipt was found. Request a receipt from Apple and try again."
    case .ResponseIsNotHTTP:
      message = "Response is not HTTP. Verify the endpoint and try again."
    case .FailureResponse:
      message = "Response failure. An unknown server-side error has occured."
    case .BadJSON:
      message = "Bad JSON."
    case .InsufficientJSON:
      message = "Insufficient JSON."
    case .MismatchingEnvironment:
      message = "The wrong environment flag was set when sending the request."
    case .MissingReceiptData:
      message = "Missing receipt data."
    case .AuthenticationFailure:
      message = "Authentication failure. Verify the API key and try again."
    case .MismatchingDevice:
      message = "Mismatching device. This receipt has been already validated with a different device."
    }

    var userInfo = [NSLocalizedDescriptionKey: message]

    if let info = info {
      userInfo["Details"] = info
    }

    return NSError(domain: domain, code: rawValue, userInfo: userInfo)
  }
}
