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
    
    
    var socketController = SocketController()
    
    
    var ipAddress: String? {
        didSet {
            if ipAddress != nil {
                socketController.setupNetworkCommunication(ipAddress: ipAddress!)
            }
        }
    }
    
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
                
                self.socketController.sendMessage(message: "\(key.rawValue) - \(value.doubleValue)")
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
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if ipAddress == nil {
            let alert = UIAlertController(title: "IP Setup", message: "Please enter your computer's IP address", preferredStyle: .alert)
            
            alert.addTextField {
                (textField) in
                
                textField.text = "192.168.8.102"
                textField.keyboardType = UIKeyboardType.numbersAndPunctuation
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0]
                self.ipAddress = textField.text
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            socketController.setupNetworkCommunication(ipAddress: ipAddress!)
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        socketController.closeSockets()
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

