/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit
import SnapKit
import NotificationBannerSwift

class FaceGeoViewController: UIViewController, ARSessionDelegate, SocketControllerViewDelegate {
    var socketController: SocketController? = nil
    var loadingBanner: NotificationBanner? = nil
    var sceneView = ARSCNView()
    
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))


    var session: ARSession {
        return sceneView.session
    }
    
    let blendShapeTracker = BlendShapeTracker()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = blendShapeTracker
        
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        self.view.addSubview(sceneView)
        self.view.addSubview(blurView)
        
        blendShapeTracker.didGetBlendShapes = {
            
            // Reduce all of the blend shapes into a message delimited by a |
            let message = $0.reduce("", {
                result, input in
                result.appending("\(input.key.rawValue) - \(Int(input.value.doubleValue * 100))|")
            })
            
            self.socketController?.sendMessage(message: message)
        }
        
        
        sceneView.snp.makeConstraints {
            make in

            make.edges.equalTo(self.view)
        }
        
        blurView.snp.makeConstraints {
            make in
            
            make.edges.equalTo(self.view)
        }
        
        socketController = SocketController()
        socketController?.delegate = self
        
    }
    
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetTracking()
        socketController?.openSockets()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        socketController?.closeSockets()
        session.pause()
    }
    


    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.flatMap({ $0 }).joined(separator: "\n")
        
        print(errorMessage)
    }

    func sessionWasInterrupted(_ session: ARSession) {
        blurView.isHidden = false

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        blurView.isHidden = true
        
        DispatchQueue.main.async {
            self.resetTracking()
        }
    }


    func resetTracking() {
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    func updatedState(state: SocketControllerState) {
        switch (state) {
        case .readyToReceive:
            loadingBanner?.dismiss()
            
            NotificationBanner(title: "Paired with Host!", subtitle: "Facial data now streaming.", style: .success).show()
            
            UIView.animate(withDuration: 1, animations: {
                [weak self] in
                
                self?.blurView.alpha = 0
            })
            
            break
            
        case .waitingForHost:
            loadingBanner = NotificationBanner(title: "Listening for Auto Discovery ....", subtitle: "Please open the iPhoneMoCap host", style: .info)
            
            loadingBanner?.autoDismiss = false
            loadingBanner?.show()
            break
        
        
        case .error(let message):
            NotificationBanner(title: "Uh Oh!", subtitle: message, style: .danger).show()
            break
        }
    }
    
  
}

