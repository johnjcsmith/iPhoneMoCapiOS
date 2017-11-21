# README #
### Retargeting Facial Motion to a Mesh Using iPhone X ###

iPhoneMoCap is a example project demonstrating how facial motion data provided by the iPhone X can be used to target a Mesh in Unity or any other 3D redered. The project consists of this iOS application and an accompanying Unity plugin which can be found [here](https://bitbucket.org/johnjcsmith/iphonemocap-unity).

### Hasn't this been done? ###

* Houdini version using vertex data
* Why this is different

### How does it work? ###

#### iOS App  ####
The iOS app streams the Blend Shapes Apple provides in `ARFaceAnchor.blendShapes` to the Unity host through a UDP socket. Essentialy emitting a stream of messages, each with 50 bend shapes in the format `blend-shape-name:blend-shape-value`.

There are lots of performance improvments to be made here but it works for the purpouse of our demo.

#### Unity extension ####
Inside of the Unity host, we have an extension which opens up a UDP socket to listen for the iOS app's messages and applies the blend shape values to the corrisponding blend shape on the rig.

The unity extension targets a `SkinnedMeshRenderer` with the name `blendShapeTarget` which 


### How to run the project ###
1. Clone and open the Unity project from [here](https://bitbucket.org/johnjcsmith/iphonemocap-unity).
2. Run the Unity project's scene
3. In the menu bar select `iPhoneMoCap` -> `MeshPreview`
4. Enable Mesh preview
5. Make sure your iPhone X is connected to the same Wifi network and build / run this application. (Dont forget to pod install)
6. This application should discover the unity host and begin streaming the motion data.

### Results ###

* Some demos
* Future work
    -  Optimization
