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
    
    private var connectedTag: NFCTag?

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
        print("NFCTagReaderSession error:", "\(error)")
        if connectedTag == nil {
            session.restartPolling()
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("\(tags)")
        for tag in tags {
            switch tag {
            case .feliCa(let feliCaTag):
                print("type", "FeliCa")
                print("identifier", feliCaTag.currentIDm.map { String(format: "%.2hhx", $0) }.joined())
            case .iso15693(let iso15693Tag):
                print("type", "ISO15693")
                print("identifier", iso15693Tag.identifier.map { String(format: "%.2hhx", $0) }.joined())
            case .iso7816(let iso7816Tag):
                print("type", "ISO14443-4")
                print("identifier", iso7816Tag.identifier.map { String(format: "%.2hhx", $0) }.joined())
            case .miFare(let miFareTag):
                print("type", "MiFare")
                print("identifier", miFareTag.identifier.map { String(format: "%.2hhx", $0) }.joined())
            @unknown default:
                continue
            }
            
            print("Connecting to", tag)
            
            nfcTagReaderSession?.connect(to: tag) { [weak self] error in
                if let error = error {
                    print("Error while connecting to \(tag):", error.localizedDescription)
                    return
                }
                
                self?.connectedTag = tag
                
                print("Connected to", tag)
                
                self?.nfcTagReaderSession?.invalidate()
            }
            return
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


