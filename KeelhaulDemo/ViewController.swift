import UIKit
import Keelhaul

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let token = "<#API Key#>"
    let receiptURL = NSBundle.mainBundle().URLForResource("receipt", withExtension: nil)!
    let endpointURL = NSURL(string: "http://<#Server Root URL#>/api/v1/verifications?sandbox=1")!
    let keelhaul = Keelhaul.init(token: token, receiptURL: receiptURL, endpointURL: endpointURL)
    keelhaul.validateReceipt { isValid, receipt, error in
      print("isValid=\(isValid)")
      print("receipt=\(receipt)")
      print("error=\(error)")
    }
  }
}
