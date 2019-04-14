//
//  ViewController.swift
//  myFirstPeripheral
//
//  Created by Chris Sidi on 4/13/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    @IBOutlet weak var logView: UITextView!
    var peripheral: CBPeripheralManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log("initializing...")
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
        log("peripheral state: \(stateToString(peripheral!.state))")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("new peripheral state: \(stateToString(peripheral.state))")
        if (peripheral.state == CBManagerState.poweredOn) {
            log("powered on.")
            
            let service = CBMutableService(type: CBUUID(string: "CAFE"), primary: true)
            
            service.characteristics = [
                CBMutableCharacteristic(
                    type: CBUUID(string: "C0FE"),
                    properties: CBCharacteristicProperties.read,
                    value: "*** Hello, would you like some coffee?".data(using: String.Encoding.utf8),
                    permissions: CBAttributePermissions.readable)
            ]

            log("adding custom C0FE service")
            peripheral.add(service)
            
            log("starting advertisement")
            peripheral.startAdvertising(nil)
            log("advertising")
        }
        else {
            log("still not powered on.")
        }
    }

    func log(_ msg: String) {
        print(msg)
        
        logView.text.append(msg)
        logView.text.append("\n")
    }
    
    func stateToString(_ state: CBManagerState) -> String {
        switch (state) {
            case .unknown:
                return "unknown"
            case .resetting:
                return "resetting"
            case .unsupported:
                return "unsupported"
            case .unauthorized:
                return "unauthorized"
            case .poweredOff:
                return "poweredOff"
            case .poweredOn:
                return "poweredOn"
            @unknown default:
                return "unknown unknowns"
        }
    }
}
