import Foundation

private let domain = "com.thoughtbot.Keelhaul"

public enum KeelhaulError: Int {
  case InvalidRequest = 9000
  case ResponseIsNotHTTP = 9001
  case FailureResponse = 9002
  case BadJSON = 9003
  case InsufficientJSON = 9004
  case MissingReceipt = 9005

  func toNSError(info: String? = nil) -> NSError {
    let message: String

    switch self {
    case .InvalidRequest:
      message = "Invalid receipt data or missing device identifier."
    case .MissingReceipt:
      message = "No receipt was found."
    case .ResponseIsNotHTTP:
      message = "Response is not HTTP."
    case .FailureResponse:
      message = "Response failure."
    case .BadJSON:
      message = "Bad JSON."
    case .InsufficientJSON:
      message = "Insufficient JSON."
    }

    var userInfo = [NSLocalizedDescriptionKey: message]

    if let info = info {
      userInfo["Details"] = info
    }

    return NSError(domain: domain, code: rawValue, userInfo: userInfo)
  }
}
