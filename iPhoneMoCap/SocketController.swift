import UIKit
import CocoaAsyncSocket

protocol ViewDelegate: class {
    func receivedMessage(message: [String])
}



class SocketController: NSObject, StreamDelegate, GCDAsyncUdpSocketDelegate {
    weak var delegate: ViewDelegate?
    
    var socket:GCDAsyncUdpSocket?
    var ipAddress = ""
    
    init(_ ipAddress: String) {
        super.init()
        
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        self.ipAddress = ipAddress
        
    }
    
    func sendMessage(message: String) {
        
        let data = message.data(using: .ascii)!
        
        socket?.send(data, toHost: ipAddress, port: 8080, withTimeout: 0.1, tag: 0)

    }
    
    func closeSockets() {
        socket?.close()
    }
}

