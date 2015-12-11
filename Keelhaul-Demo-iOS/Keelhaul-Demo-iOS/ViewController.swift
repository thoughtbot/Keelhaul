import UIKit
import Keelhaul
import StoreKit

class ViewController: UIViewController {
  let keelhaul = Keelhaul(token: "token")

  override func viewDidLoad() {
    super.viewDidLoad()
    keelhaul.validateReceipt { (isValid, receiptOpt, errorOpt) in
      print(isValid, errorOpt!)
      if isValid {
        let alertViewController = UIAlertController(title: "Existing Receipt, Bro",
          message: "This receipt meets Jony Ive's personal approval.",
          preferredStyle: .Alert)
        alertViewController.addAction(UIAlertAction(title: "Great", style: .Default) { action  in
          alertViewController.dismissViewControllerAnimated(true, completion: nil)
          })
        self.presentViewController(alertViewController, animated: true, completion: nil)
      } else {
        print("Not valid")
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
      }
    }
  }
}

extension ViewController: SKRequestDelegate {
  func requestDidFinish(request: SKRequest) {
    keelhaul.validateReceipt { (isValid, receiptOpt, errorOpt) in
      if isValid {
        let alertViewController = UIAlertController(title: "Valid Receipt, Bro",
          message: "This receipt meets Jony Ive's personal approval.",
          preferredStyle: .Alert)
        alertViewController.addAction(UIAlertAction(title: "Great", style: .Default) { action  in
          alertViewController.dismissViewControllerAnimated(true, completion: nil)
          })
        self.presentViewController(alertViewController, animated: true, completion: nil)
      } else {
        let alertViewController = UIAlertController(title: "Invalid Receipt, Bro",
          message: "This receipt doesn't seem to be valid according to Tim Cook.",
          preferredStyle: .Alert)
        self.presentViewController(alertViewController, animated: true, completion: nil)
      }
    }
  }
  func request(request: SKRequest, didFailWithError error: NSError) {
    print("failure! \(error.localizedDescription)")
  }
}