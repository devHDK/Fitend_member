import UIKit
import Flutter

class NotificationHandler: NSObject {
  static let shared = NotificationHandler()

  public func applicationWillEnterForeground() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { 
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
  }
}
