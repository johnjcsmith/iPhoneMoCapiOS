import UIKit
import CocoaAsyncSocket

protocol ViewDelegate: class {
    func receivedMessage(message: [String])
}



class SocketController: NSObject, StreamDelegate, GCDAsyncUdpSocketDelegate {
    weak var delegate: ViewDelegate?
    var broadCastListnerSocket: GCDAsyncUdpSocket?
    var outputSocket: GCDAsyncUdpSocket?
    
    var hostAddress: String?
    
    override init() {
        super.init()
        
        outputSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        broadCastListnerSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        setupBroadCastListner()
    }
    
    func setupBroadCastListner(){
        
        do {
            try broadCastListnerSocket?.bind(toPort: 49452)
            try broadCastListnerSocket?.beginReceiving()


        } catch {
            print(error)
        }
        
    }
    
    func sendMessage(message: String) {
        
        guard hostAddress != nil else {return}
        
        let data = message.data(using: .ascii)!
        outputSocket?.send(data, toHost: hostAddress!, port: 49452, withTimeout: 0.1, tag: 0)

    }
    
    func closeSockets() {
        outputSocket?.close()
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let message  = String(data: data, encoding: String.Encoding.ascii)
        if (message?.contains("iPhoneMoCapBroadCast") ?? false) {
            
            var host: NSString?
            var port1: UInt16 = 0
            GCDAsyncUdpSocket.getHost(&host, port: &port1, fromAddress: address)
            
            if let host = host {
                hostReceived(host: String(host))
            }
        }
    }
    
    func hostReceived(host: String) {
        // Stop listening to broadcasts
        broadCastListnerSocket?.close()
        
        hostAddress = host
    }
}

