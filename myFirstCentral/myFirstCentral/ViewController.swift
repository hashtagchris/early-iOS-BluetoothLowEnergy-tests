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
    var targetPeripheral: CBPeripheral? = nil
    var connected = false
    
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

        if (targetPeripheral == nil) {
            // Keep a reference to the peripheral we're connecting to.
            // Otherwise we get API misuse warnings and the connection gets canceled.
            targetPeripheral = peripheral

            log("Connecting to \(peripheral.identifier) (\(peripheral.name ?? "[no name]")))")
            central.connect(peripheral, options: nil)
            log("")
        }
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

        if (peripheral == targetPeripheral) {
            targetPeripheral = nil
        }
        else {
            log("Error connecting to a different peripheral!")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        log("Connected to \(peripheral.identifier) (\(peripheral.name ?? "[no name]"))")
        
        if (peripheral != targetPeripheral) {
            log("Connected to a different peripheral!")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                log("  * Service: \(service.uuid)")
            }
        }
        else {
            log("  [Peripheral has no services?]")
        }
        
        connected = true
        
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
        
        if (peripheral == targetPeripheral) {
            targetPeripheral = nil
            connected = false
            
            c0feButton.isEnabled = false
            c0ffButton.isEnabled = false

            reevaluateScanning(central)
        }
        else {
            log("Disconnected from a different peripheral!")
        }
    }
    
    func reevaluateScanning(_ central: CBCentralManager) {
        // let scanServices = [CBUUID(string: "CAFE")]
        let scanServices:[CBUUID]? = nil
        
        if (central.state == CBManagerState.poweredOn) {
            if (targetPeripheral == nil || !connected) {
                if (!central.isScanning) {
                    if (scanServices != nil) {
                        log("Not connected yet. Starting scan for peripherals with CAFE service.");
                    }
                    else {
                        log("Not connected yet. Starting scan for any peripherals.")
                    }
                    central.scanForPeripherals(withServices: scanServices, options: nil)
                }
            }
            else {
                if (central.isScanning) {
                    log("Connected to a peripheral. Stopping scan.")
                    central.stopScan()
                }
                else {
                    log("Connected to a peripheral. scanning already stopped.")
                }
            }
        }
        else {
            log("Skipping scanning state check - not powered on.")
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
