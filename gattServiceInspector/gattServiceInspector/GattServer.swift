//
//  GattServer.swift
//  gattServiceInspector
//
//  Created by Chris Sidi on 4/28/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import Foundation
import CoreBluetooth

// A GATT server for an iOS App that operates as a BLE Central. CoreBluetooth requires using a CBPeripheralManager
// to offer local GATT services, but we don't have to actually turn on advertising.
class GattServer: NSObject, CBPeripheralManagerDelegate {
    var peripheralManagerReference: CBPeripheralManager!
    let loggingEnabled = true

    override init() {
        super.init()
        log("GATT Server initializing.")

        peripheralManagerReference = CBPeripheralManager(delegate: self, queue: nil)
    }

    deinit {
        log("GATT Server de-initializing.")
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("new peripheral state: \(stateToString(peripheral.state))")
        if (peripheral.state == CBManagerState.poweredOn) {
            let service = CBMutableService(type: CBUUID(string: "FACE"), primary: true)

            service.characteristics = [
                CBMutableCharacteristic(
                    type: CBUUID(string: "0FFF"),
                    properties: CBCharacteristicProperties.read,
                    value: nil,
                    permissions: CBAttributePermissions.readable),
            ]

            log("Adding custom FACE service.")
            peripheral.add(service)

            // Not advertising - assuming connected peripherals will solicit this service.
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let er = error {
            log("Error publishing \(service) service to the local GATT database: \(er)")
            return;
        }

        log("Publised service \(service) to the local GATT database.")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    {
        log("Read request received from \(request.central.identifier)")

        let value = "Congratulations. You have just discovered the secret message, \(request.central.identifier)."
        log("response: \"\(value)\" (success)")

        request.value = value.data(using: String.Encoding.utf8)
        peripheral.respond(to: request, withResult: CBATTError.success)
    }

    func log(_ msg: String) {
        if (loggingEnabled) {
            print(msg)
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
