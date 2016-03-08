import Foundation
import CommonCrypto

extension NSData {
  var digest: NSData {
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
    var hash = [UInt8](count: digestLength, repeatedValue: 0)
    CC_SHA256(bytes, UInt32(length), &hash)
    return NSData(bytes: hash, length: digestLength)
  }

  var hexString: String {
    var bytes = [UInt8](count: length, repeatedValue: 0)
    getBytes(&bytes, length: length)

    return bytes.reduce("") { (hexString, byte) in
      return hexString + String(format:"%02x", UInt8(byte))
    }
  }
}