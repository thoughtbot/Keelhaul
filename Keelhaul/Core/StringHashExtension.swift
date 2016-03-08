import Foundation

extension String {
  var SHA256: String {
    let stringData = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    return stringData!.digest.hexString
  }
}
