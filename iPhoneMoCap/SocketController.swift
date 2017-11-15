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
    
    
    inputStream = readStream!.takeRetainedValue()
    outputStream = writeStream!.takeRetainedValue()
    
    inputStream?.delegate = self
    outputStream?.delegate = self
    
    inputStream?.schedule(in: .main, forMode: .commonModes)
    outputStream?.schedule(in: .main, forMode: .commonModes)
    
    inputStream?.open()
    outputStream?.open()
    
    sendMessage(message: "iam: iOS Device")
  }

  

  func sendMessage(message: String) {
    
    let data = message.data(using: .ascii)!
    
    var sizeData = Data()
    sizeData.insert(UInt8(data.count), at: 0)
    sizeData.insert(UInt8(data.count >> 8), at: 1)
    sizeData.insert(UInt8(data.count >> 16), at: 2)
    sizeData.insert(UInt8(data.count >> 24), at: 3)
    
    _ = sizeData.withUnsafeBytes{
        outputStream?.write($0, maxLength: sizeData.count)

    }
    
    _ = data.withUnsafeBytes {
        outputStream?.write($0, maxLength: data.count)
    }
  }
  
  func closeSockets() {
    inputStream?.close()
    outputStream?.close()
  }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("hasBytesAvailable")
        case Stream.Event.endEncountered:
            print("endEncountered")
            closeSockets()
        case Stream.Event.errorOccurred:
            print("errorOccurred")
        case Stream.Event.hasSpaceAvailable:
            print("hasSpaceAvailable")
        default:
            print("some other event...")
            break
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        guard inputStream != nil else {
            return
        }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream!.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = inputStream?.streamError {
                    break
                }
            }
        
            
            guard let stringArray = String(bytesNoCopy: buffer,
            length: numberOfBytesRead,
            encoding: .ascii,
            freeWhenDone: true)?.components(separatedBy: ":") else {
                return
            }

            delegate?.receivedMessage(message: stringArray)

        }
    }
    

}

