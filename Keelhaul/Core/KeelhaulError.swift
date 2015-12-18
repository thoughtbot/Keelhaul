public enum KeelhaulError: Int {
  case NoReceiptURL = 9000
  case ResponseIsNotHTTP = 9001
  case FailureResponse = 9002
  case BadJSON = 9003
  case InsufficientJSON = 9004
  case MissingReceipt = 9005
}
