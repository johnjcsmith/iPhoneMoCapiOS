# README #

Blog post placeholder

### Retargeting Facial Motion to a Mesh Using iPhone X ###

* Quick summary

### Hasn't this been done? ###

* Houdini version using vertex data
* Why this is different

### How does it work? ###


#### iOS App  ####
The iOS app streams the Blend Shapes Apple provides in `ARFaceAnchor.blendShapes` to the Unity host through a UDP socket. Essentialy emitting a stream of messages in the format 'blend-shape-name:blend-shape-value'.

There are lots of performance improvments to be made here but it works for the purpouse of a demo.

#### Unity extension host  ####
Inside of the Unity host, we have an extension which opens up a UDP socket to listen for the iOS app's messages and applies the blend shape value to the corrisponding blend shape on the rig.


### Results ###

* Some demos
* Future work
    -  Optimization
