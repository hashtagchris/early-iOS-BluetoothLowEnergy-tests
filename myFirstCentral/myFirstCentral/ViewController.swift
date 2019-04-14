//
//  ViewController.swift
//  myFirstCentral
//
//  Created by Chris Sidi on 4/14/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var c0feButton: UIButton!
    @IBOutlet weak var c0ffButton: UIButton!
    var central: CBCentralManager!
    var targetPeripheral: CBPeripheral? = nil
    
    // Connect only to a device that's extremely close.
    let Min_RSSI_for_connecting = -35
    
    // let scanServices:[CBUUID]? = [CBUUID(string: "CAFE")]
    let scanServices:[CBUUID]? = nil
    
    // To see several other GATT services, try out nil.
    let discoverServices:[CBUUID]? = [CBUUID(string: "CAFE")]
    // let discoverServices:[CBUUID]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log("Initializing...")
        central = CBCentralManager(delegate: self, queue: nil)
        log("Central state: \(stateToString(central.state))")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("New central state: \(stateToString(central.state))")
        
        reevaluateScanning(central)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        log("Discovered \(peripheralDescription(peripheral)) (rssi: \(RSSI))")

        if let services = peripheral.services {
            for service in services {
                log("  * GATT service: \(service.uuid)")
            }
        }
        else {
            log("No GATT services identified")
        }

        if (targetPeripheral == nil) {
            if (RSSI.intValue >= Min_RSSI_for_connecting) {
                // Keep a reference to the peripheral we're connecting to.
                // Otherwise we get API misuse warnings and the connection gets canceled.
                targetPeripheral = peripheral

                log("Connecting...")
                central.connect(peripheral, options: nil)

                reevaluateScanning(central)
            }
            else {
                log("Ignoring peripheral. Device is too far away, and RSSI value is too low: \(RSSI)")
            }
        }
        else {
            log("Ignoring peripheral. Already in the process of connecting.")
        }
        log("")
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        if let er = error {
            log("Failed to connect to \(peripheralDescription(peripheral)): \(er)")
        }
        else {
            log("Failed to connect to \(peripheralDescription(peripheral)). Error unknown.")
        }

        if (peripheral != targetPeripheral) {
            log("Error connecting to a different peripheral!")
            return
        }
        
        targetPeripheral = nil
        reevaluateScanning(central)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        log("Connected to \(peripheralDescription(peripheral))")
        
        if (peripheral != targetPeripheral) {
            log("Connected to a different peripheral!")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                log("  * GATT service: \(service.uuid)")
            }
        }
        else {
            log("No GATT services identified.")
        }
        
        c0feButton.isEnabled = true
        c0ffButton.isEnabled = true
        
        peripheral.delegate = self
        peripheral.discoverServices(discoverServices)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        if let er = error {
            log("Disconnected from \(peripheralDescription(peripheral)). Error: \(er)")
        }
        else {
            log("Disconnected from \(peripheralDescription(peripheral)).")
        }
        
        if (peripheral != targetPeripheral) {
            log("Disconnected from a different peripheral!")
            return
        }
        
        targetPeripheral = nil
        
        c0feButton.isEnabled = false
        c0ffButton.isEnabled = false

        reevaluateScanning(central)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let er = error {
            log("Error discovering services: \(er)")
        }
        else {
            log("Discovered \(peripheral.services!.count) service(s)")
            
            for service in peripheral.services! {
                log("  * Service: \(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let er = error {
            log("Error discovering characteristics: \(er)")
        }
        else {
            log("Discovered \(service.characteristics!.count) characteristic(s)")
            
            for characteristic in service.characteristics! {
                log("  * Characteristic: \(characteristic.uuid)")
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let er = error {
            log("Error reading characteristic value: \(er)")
        }
        else {
            log("Read characteristic value successfully.")
            log("  * Characteristic: \(characteristic.uuid), Value: \(dataToString(characteristic.value))")
        }
    }
    
    func reevaluateScanning(_ central: CBCentralManager) {
        if (central.state == CBManagerState.poweredOn) {
            if (targetPeripheral == nil) {
                if (!central.isScanning) {
                    if (scanServices != nil) {
                        log("Not connecting yet. Starting scan for peripherals with CAFE service.");
                    }
                    else {
                        log("Not connecting yet. Starting scan for any peripherals.")
                    }
                    central.scanForPeripherals(withServices: scanServices, options: nil)
                }
            }
            else {
                if (central.isScanning) {
                    log("Stopping scan.")
                    central.stopScan()
                    log("")
                }
                else {
                    log("Scan already stopped.")
                }
            }
        }
        else {
            log("Skipping scanning state check - not powered on.")
        }
        log("")
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
    
    func dataToString(_ value: Data?) -> String {
        if (value != nil) {
            if let string = String(data: value!, encoding: .utf8) {
                return "'\(string)'"
            } else {
                return "<<\(value!)>>"
            }
        } else {
            return "[nil]"
        }
    }
    
    func peripheralDescription(_ peripheral: CBPeripheral) -> String {
        return "\(peripheral.identifier) (\(peripheral.name ?? "[no name]"))"
    }
}
