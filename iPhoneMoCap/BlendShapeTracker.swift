import SceneKit
import ARKit

class BlendShapeTracker: NSObject, ARSCNViewDelegate {
    
    var didGetBlendShapes: (([ARFaceAnchor.BlendShapeLocation: NSNumber]) -> ())?
    
    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        didGetBlendShapes?(faceAnchor.blendShapes)

    }
}
