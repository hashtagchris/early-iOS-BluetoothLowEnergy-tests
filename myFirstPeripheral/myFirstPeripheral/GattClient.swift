//
//  GattClient.swift
//  myFirstPeripheral
//
//  Created by Chris Sidi on 4/28/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import Foundation
import CoreBluetooth

// A GATT client for an iOS App that operates as a BLE Peripheral. CoreBluetooth requires using a CBCentralManager
// to use remote GATT services, but we don't have to actually scan for the remote device.
class GattClient: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var remoteUUID: UUID!
    var remoteDevice: CBPeripheral? = nil
    var centralManager: CBCentralManager!
    let loggingEnabled = true

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    convenience init(uuid: UUID) {
        self.init()
        remoteUUID = uuid
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("new centralManager state: \(stateToString(central.state))")

        if (central.state == .poweredOn) {
            // Don't scan, just connect to the device already connected to us.
            log("Attempting to find remote device \(remoteUUID!)...")
            let connectedPeripherals = centralManager.retrievePeripherals(withIdentifiers: [remoteUUID])
            log("Devices found: \(connectedPeripherals.count)")

            if (connectedPeripherals.count == 1) {
                remoteDevice = connectedPeripherals[0]
                log("Connecting...")
                centralManager.connect(remoteDevice!, options: nil)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let er = error {
            log("Failed to connect to remote device: \(er)")
            return
        }

        log("Failed to connect to remote device.")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("Searching for FACE service...")
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "FACE")])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let er = error {
            log("Error discovering services: \(er)")
            return
        }

        log("Discovered \(peripheral.services!.count) service(s).")

        for service in peripheral.services! {
            log("  * Service: \(service.uuid)")
            peripheral.discoverCharacteristics([CBUUID(string: "0FFF")], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let er = error {
            log("Error discovering characteristics: \(er)")
            return
        }

        log("Discovered \(service.characteristics!.count) characteristic(s).")

        for characteristic in service.characteristics! {
            log("  * Characteristic: \(characteristic.uuid)")

            if (characteristic.uuid == CBUUID(string: "0FFF")) {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let er = error {
            log("Error reading characteristic value: \(er)")
            return
        }

        log("Read characteristic value successfully.")
        log("  * Characteristic: \(characteristic.uuid), Value: \(dataToString(characteristic.value, quoteString: true))")
    }

    func log(_ msg: String) {
        if (loggingEnabled) {
            print(msg)
        }
    }

    func dataToString(_ value: Data?, quoteString: Bool) -> String {
        if let val = value {
            log("Data value is \(val.count) byte(s).")
            if val.count == 0 {
                return "[empty]"
            }

            let string = String(data: value!, encoding: .utf8)

            if string != nil && string != "" {
                log("String length: \(string!.count)")
                return quoteString ? "\"\(string!)\"" : string!
            }

            // TODO: Format the bytes as a hexadecimal string.
            return "<<\(val)>>"
        }
        else {
            return "[nil]"
        }
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
