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
        
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
        
        log("BLE manager state: \(peripheral!.state.rawValue)")
        if (peripheral!.state == CBManagerState.poweredOn) {
            log("powered on already")
        }
        else {
            log("not powered on yet.")
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("new BLE manager state: \(peripheral.state.rawValue)")
        if (peripheral.state == CBManagerState.poweredOn) {
            log("powered on.")
            
            let cofeValue = "Cafe\u{301} du 🌍".data(using: String.Encoding.utf8)
            
            let service = CBMutableService(type: CBUUID(string: "CAFE"), primary: true)
            
            service.characteristics = [
                CBMutableCharacteristic(
                    type: CBUUID(string: "C0FE"),
                    properties: CBCharacteristicProperties.read,
                    value: cofeValue,
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
}
