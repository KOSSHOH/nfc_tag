//
//  ViewController.swift
//  nfc_real_tag
//
//  Created by Shahboz Turonov on 14/12/21.
//

import UIKit
import CoreNFC

class ViewController: UIViewController {
    
    var nfcTagReaderSession: NFCTagReaderSession?

    override func viewDidLoad() {
        super.viewDidLoad()
//                        let session = NFCNDEFReaderSession(
//                            delegate: self,
//                            queue: nil,
//                            invalidateAfterFirstRead: true
//                        )
//                        session.alertMessage = "Hold your device near a tag to scan it."
//                        session.begin()
        
        
        
                nfcTagReaderSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self)
                nfcTagReaderSession?.alertMessage = "Hold your device near a tag to scan it."
                nfcTagReaderSession?.begin()
    
    
    }
}


extension ViewController: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Tag reader did become active")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("\(error)")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("\(tags)")
        for tag in tags {
            let rfidTag = tag as! NFCISO15693Tag
            print("- Is available: \(rfidTag.isAvailable)")
            print("- Type: \(rfidTag.type)")
            print("- IC Manufacturer Code: \(rfidTag.icManufacturerCode)")
            print("- IC ,: \(rfidTag.icSerialNumber)")
            print("- Identifier: \(rfidTag.identifier)")
        }
    }
}

extension ViewController: NFCNDEFReaderSessionDelegate {
    ///nfc reader ndc session
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(44)
    }
    
    ///nfc reader ndc session
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
           
            if  let firstElement = messages.first{
                
                var mainMessage : [String: Any] = [:]
                mainMessage["length"] = firstElement.length
                var payloads : [[String: Any]] = []
                
                for payload in firstElement.records{
                    
                    var _payload : [String: Any] = [:]
                    _payload["type"] = String.init(data: payload.type, encoding: .utf8) ?? ""
                    _payload["identifier"] = String.init(data: payload.identifier, encoding: .utf8) ?? ""
                    _payload["payload"] = String.init(data: payload.payload, encoding: .utf8) ?? ""
                    _payload["typeNameFormat"] = payload.typeNameFormat.rawValue
                    
                    payloads.append(_payload)
                    
                }
                
                mainMessage["payloads"] = payloads
                print(mainMessage)
            }
    }
}


