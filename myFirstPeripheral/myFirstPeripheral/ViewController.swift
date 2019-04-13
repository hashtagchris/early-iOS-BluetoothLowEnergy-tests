//
//  ViewController.swift
//  myFirstPeripheral
//
//  Created by Chris Sidi on 4/13/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let cofeValue = "Cafe\u{301} du 🌍".data(using: String.Encoding.utf8)
        
        let service = CBMutableService(type: CBUUID(string: "CAFE"), primary: true)
        
        service.characteristics = [
            CBMutableCharacteristic(
                type: CBUUID(string: "C0FE"),
                properties: CBCharacteristicProperties.read,
                value: cofeValue,
                permissions: CBAttributePermissions.readable)
        ]
        
        let manager = CBPeripheralManager()
        
        log("CB manager state: \(manager.state)")
        if (manager.state == CBManagerState.poweredOn) {
            log("adding service")
            manager.add(service)
            
            log("starting advertising")
            manager.startAdvertising(nil)
        }
        else {
            log("not powered on. not doing much of anything.")
        }
    }
    
    func log(_ msg: String) {
        print(msg)
    }
}
