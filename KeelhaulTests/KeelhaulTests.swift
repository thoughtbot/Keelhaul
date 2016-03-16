import XCTest
@testable import Keelhaul

class KeelhaulTests: XCTestCase {
  let validReceiptURL = NSBundle(forClass: KeelhaulTests.self).URLForResource("validReceipt", withExtension: "txt")!

  func testValidReceipt() {
    let expectation = expectationWithDescription("ValidateReceiptTest")
    let keelhaul = Keelhaul(token: "secret",
      receiptURL: validReceiptURL,
      endpointURL: NSURL(string: "http://localhost:1234")!)

    keelhaul.validateReceipt { success, receipt, error in
      XCTAssertTrue(success)
      XCTAssertNotNil(receipt)
      XCTAssertNil(error)

      if let receipt = receipt {
        XCTAssertEqual(receipt.ID, 123)
        XCTAssertEqual(receipt.bundleID, "com.thoughtbot.Keelhaul")
        XCTAssertEqual(receipt.purchaseDate, dateWith(year: 2015, month: 3, day: 3, hour: 9, minute: 31, second: 04))
        XCTAssertEqual(receipt.creationDate, dateWith(year: 2015, month: 10, day: 21, hour: 14, minute: 22, second: 48))
        XCTAssertEqual(receipt.requestDate, dateWith(year: 2015, month: 12, day: 5, hour: 15, minute: 54, second: 24))
      }

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(1.0, handler: nil)
  }

  func testMismatchingEnvironment() {
    let expectation = expectationWithDescription("MismatchingEnvTest")
    let keelhaul = Keelhaul(token: "secret",
      receiptURL: validReceiptURL,
      endpointURL: NSURL(string: "http://localhost:1234/mismatching-env")!)

    keelhaul.validateReceipt { success, receipt, error in
      XCTAssertFalse(success)
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 9007)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(1.0, handler: nil)
  }

  func testAuthFailure() {
    let expectation = expectationWithDescription("AuthFailureTest")
    let keelhaul = Keelhaul(token: "secret",
      receiptURL: validReceiptURL,
      endpointURL: NSURL(string: "http://localhost:1234/auth-failure")!)

    keelhaul.validateReceipt { success, receipt, error in
      XCTAssertFalse(success)
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 9001)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(1.0, handler: nil)
  }

  func testMismatchingDevice() {
    let expectation = expectationWithDescription("MismatchingDeviceTest")
    let keelhaul = Keelhaul(token: "secret",
      receiptURL: validReceiptURL,
      endpointURL: NSURL(string: "http://localhost:1234/mismatching-device")!)

    keelhaul.validateReceipt { success, receipt, error in
      XCTAssertFalse(success)
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 9006)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(1.0, handler: nil)
  }
}
