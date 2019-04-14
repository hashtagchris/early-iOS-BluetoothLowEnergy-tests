//
//  ViewController.swift
//  myFirstCentral
//
//  Created by Chris Sidi on 4/14/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var c0feButton: UIButton!
    @IBOutlet weak var c0ffButton: UIButton!
    var central: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log("initializing...")
        central = CBCentralManager(delegate: self, queue: nil)
        log("central state: \(stateToString(central.state))")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("new central state: \(stateToString(central.state))")
        
        if (central.state == CBManagerState.poweredOn) {
            log("starting scan...")
            central.scanForPeripherals(withServices: [CBUUID(string: "CAFE")], options: nil)
            log("scanning")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        log("Discovered \(peripheral.identifier) (\(peripheral.name ?? "[no name]"))) (rssi: \(RSSI))")
        
        log("Connecting...")
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        log("Connected to \(peripheral.identifier) (\(peripheral.name ?? "[no name]"))")

        log("Stopping scan since we successfully connected to a peripheral.")
        central.stopScan()
        
        c0feButton.isEnabled = true
        c0ffButton.isEnabled = true
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        if let er = error {
            log("Failed to connect to \(peripheral.identifier) (\(peripheral.name ?? "[no name]")): \(er)")
        }
        else {
            log("Failed to connect to \(peripheral.identifier) (\(peripheral.name ?? "[no name]")). Error unknown.")
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
