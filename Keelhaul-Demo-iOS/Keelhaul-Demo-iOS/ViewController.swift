import UIKit
import Keelhaul
import StoreKit

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let keelhaul = Keelhaul(token: "token")

    keelhaul.validateReceipt { (isValid, receiptOpt, errorOpt) in
      print(isValid, receiptOpt, errorOpt)
    }
  }
}
