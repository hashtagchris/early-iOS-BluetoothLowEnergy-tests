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
        
        reevaluateScanning(central)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        log("Discovered \(peripheral.identifier) (\(peripheral.name ?? "[no name]"))) (rssi: \(RSSI))")

        if let services = peripheral.services {
            for service in services {
                log("  * Service: \(service.uuid)")
            }
        }
        else {
            log("  [No services advertised?]")
        }
        log("")
        
        //log("Connecting...")
        //central.connect(peripheral, options: nil)
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
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        log("Connected to \(peripheral.identifier) (\(peripheral.name ?? "[no name]"))")
        
        c0feButton.isEnabled = true
        c0ffButton.isEnabled = true
        
        reevaluateScanning(central)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        if let er = error {
            log("Disconnected from \(peripheral.identifier) (\(peripheral.name ?? "[no name]")). Error: \(er)")
        }
        else {
            log("Disconnected from \(peripheral.identifier) (\(peripheral.name ?? "[no name]")).")
        }
        
        reevaluateScanning(central)
    }
    
    func reevaluateScanning(_ central: CBCentralManager) {
        let services = [CBUUID(string: "CAFE")]
        
        // let scanServices:[CBUUID]? = services
        let scanServices:[CBUUID]? = nil
        
        if (central.state == CBManagerState.poweredOn) {
            let count = central.retrieveConnectedPeripherals(withServices: services).count
            if (count == 0) {
                if (!central.isScanning) {
                    log("connected to zero devices. starting scan.")
                    central.scanForPeripherals(withServices: scanServices, options: nil)
                }
            }
            else {
                if (central.isScanning) {
                    log("connected to \(count) device(s). stopping scan.")
                    central.stopScan()
                }
                else {
                    log("connected to \(count) device(s). scanning already stopped.")
                }
            }
        }
        else {
            log("skipping scanning state check - not powered on")
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
