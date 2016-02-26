import UIKit
import Keelhaul

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let token = "5RcTeo2fsmkN6wFhdfiaLg"
    let receiptURL = NSBundle.mainBundle().URLForResource("receipt", withExtension: nil)!
    let endpointURL = NSURL(string: "http://localhost:3000/api/v1/verifications?sandbox=1")!
    let keelhaul = Keelhaul.init(token: token, receiptURL: receiptURL, endpointURL: endpointURL)
    keelhaul.validateReceipt { isValid, receipt, error in
      print("isValid=\(isValid)")
      print("receipt=\(receipt)")
      print("error=\(error)")
    }
  }
}
