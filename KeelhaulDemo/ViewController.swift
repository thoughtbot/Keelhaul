import UIKit
import Keelhaul

class ViewController: UIViewController {
  @IBOutlet var receiptLabel: UILabel!
  @IBOutlet var errorLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    let token = "AlV4w1FqkAORqPDaS5OUbg"
    let receiptURL = NSBundle.mainBundle().URLForResource("receipt", withExtension: nil)!
    let endpointURL = NSURL(string: "http://localhost:3000/api/v1/validate")!
    let config = KeelhaulConfiguration(receiptURL: receiptURL, endpointURL: endpointURL, sandbox: true)
    let keelhaul = Keelhaul.init(token: token, configuration: config)

    keelhaul.validateReceipt { receipt, error in
      onMain {
        self.receiptLabel.text = (receipt != nil ? "\u{2705} Valid" : "\u{26D4} Invalid") + " Receipt"

        if let error = error {
          self.errorLabel.text = "Error \(error.code): \(error.userInfo[NSLocalizedDescriptionKey]!)"
          if let details = error.userInfo["Details"] {
            print(details)
          }
        }
      }

      if let receipt = receipt {
        print(receipt)
      }
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    errorLabel.text = ""
    receiptLabel.text = "Validating..."
  }
}

func onMain(block: dispatch_block_t) {
  if NSThread.isMainThread() {
    block()
  } else {
    dispatch_async(dispatch_get_main_queue(), block)
  }
}
