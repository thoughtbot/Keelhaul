import XCTest
@testable import Keelhaul

class KeelhaulTests: XCTestCase {
  let validReceiptURL = NSBundle(forClass: KeelhaulTests.self).URLForResource("validReceipt", withExtension: "txt")!
  let invalidReceiptURL = NSURL(string: "InvalidReceipt")!
  let timeoutDuration = 0.5

  func testValidReceipt() {
    let expectation = expectationWithDescription("ValidateReceiptTest")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/success")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
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

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testSandboxReceiptEnvMismatch() {
    let expectation = expectationWithDescription("testSandboxReceiptEnvMismatch")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/error/21007")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 21007)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testInvalidDeveloperAPIKey() {
    let expectation = expectationWithDescription("testInvalidDeveloperAPIKey")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/unauthorized")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20007)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testMalformedRequestJSON() {
    let expectation = expectationWithDescription("testMalformedRequestJSON")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/error/21000")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 21000)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testMalformedReceiptData() {
    let expectation = expectationWithDescription("testMalformedReceiptData")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/error/21002")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 21002)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testUnauthenticSignature() {
    let expectation = expectationWithDescription("testUnauthenticSignature")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/error/21003")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 21003)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testAppleServerUnavailable() {
    let expectation = expectationWithDescription("testAppleServerUnavailable")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/error/21005")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 21005)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testMalformedResponseJSON() {
    let expectation = expectationWithDescription("testMalformedResponseJSON")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/malformed-json")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20000)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testInsufficientResponseJSON() {
    let expectation = expectationWithDescription("testInsufficientResponseJSON")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/insufficient-json")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20001)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testMissingReceipt() {
    let expectation = expectationWithDescription("testMissingReceipt")
    let config = KeelhaulConfiguration(receiptURL: invalidReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20002)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testInvalidHTTPResponse() {
    let expectation = expectationWithDescription("testInvalidHTTPResponse")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1254/invalid-http-response")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20004)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testDeviceMismatch() {
    let expectation = expectationWithDescription("testDeviceMismatch")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/error/20009")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20009)
      
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func testUnknownSDKError() {
    let expectation = expectationWithDescription("testUnknownSDKError")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/unknown-error")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20020)
      
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func test404() {
    let expectation = expectationWithDescription("test404")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/404")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20006)

      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }

  func test500() {
    let expectation = expectationWithDescription("test500")
    let config = KeelhaulConfiguration(receiptURL: validReceiptURL, endpointURL: NSURL(string: "http://localhost:1234/500")!)
    let keelhaul = Keelhaul(token: "secret", configuration: config)

    keelhaul.validateReceipt { receipt, error in
      XCTAssertNil(receipt)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, 20006)
      
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(timeoutDuration, handler: nil)
  }
}
