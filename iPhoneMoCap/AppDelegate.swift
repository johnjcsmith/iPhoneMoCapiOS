import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    UIApplication.shared.statusBarStyle = .default
    
    window = UIWindow(frame: UIScreen.main.bounds)
    
    window?.rootViewController = FaceGeoViewController()
    window?.makeKeyAndVisible()
   
    return true
  }
  
}

