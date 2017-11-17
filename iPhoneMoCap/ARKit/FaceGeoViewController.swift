/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit
import SnapKit

class FaceGeoViewController: UIViewController, ARSessionDelegate {
    
    
    var socketController: SocketController? = nil
    
    
    // MARK: Outlets

    var sceneView = ARSCNView()
    
    
    var blurView = UIVisualEffectView()


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
            $0.forEach {
                key, value in
                
                self.socketController?.sendMessage(message: "\(key.rawValue) - \(Int(value.doubleValue * 100))")
            }
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
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetTracking()
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
  
}

