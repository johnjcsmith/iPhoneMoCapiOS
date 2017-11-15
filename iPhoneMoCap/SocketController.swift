import UIKit

protocol ViewDelegate: class {
  func receivedMessage(message: [String])
}

class SocketController: NSObject, StreamDelegate {
  weak var delegate: ViewDelegate?
  
  var inputStream: InputStream?
  var outputStream: OutputStream?
  
  
  let maxReadLength = 1024
  
func setupNetworkCommunication(ipAddress: String) {
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                       ipAddress as CFString,
                                       8080,
                                       &readStream,
                                       &writeStream)
    
    
//    inputStream = readStream!.takeRetainedValue()
    outputStream = writeStream!.takeRetainedValue()
    
//    inputStream?.delegate = self
    outputStream?.delegate = self
    
//    inputStream?.schedule(in: .main, forMode: .commonModes)
    outputStream?.schedule(in: .main, forMode: .commonModes)
    
//    inputStream?.open()
    outputStream?.open()
  }

  

  func sendMessage(message: String) {
    
    let data = message.data(using: .ascii)!
    
    var sizeData = Data()
    
    // Pack length prefix into 4 Bytes
    sizeData.insert(UInt8(data.count), at: 0)
    sizeData.insert(UInt8(data.count >> 8), at: 1)
    sizeData.insert(UInt8(data.count >> 16), at: 2)
    sizeData.insert(UInt8(data.count >> 24), at: 3)
    
    if (outputStream?.hasSpaceAvailable ?? false) {
        _ = sizeData.withUnsafeBytes{
        
            
            outputStream?.write($0, maxLength: sizeData.count)

        }
        
        _ = data.withUnsafeBytes {
            outputStream?.write($0, maxLength: data.count)
        }
    } else {
        print ("Stream is full!")
    }
  }
  
  func closeSockets() {
    outputStream?.close()
  }
}

