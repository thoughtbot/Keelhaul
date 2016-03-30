import Foundation

public struct KeelhaulConfiguration {
  public let receiptURL: NSURL?
  private let endpointURL: NSURL
  private let sandbox: Bool

  public init(receiptURL: NSURL? = NSBundle.mainBundle().appStoreReceiptURL,
              endpointURL: NSURL = NSURL(string: "https://keelhaul.thoughtbot.com/api/v1/validate")!,
              sandbox: Bool = false) {
    self.receiptURL = receiptURL
    self.endpointURL = endpointURL
    self.sandbox = sandbox
  }

  public var fullEndpointURL: NSURL {
    let components = NSURLComponents(URL: endpointURL, resolvingAgainstBaseURL: false)
    components!.queryItems = [NSURLQueryItem(name: "sandbox", value: sandbox ? "1" : "0")]
    return components!.URL!
  }
}
