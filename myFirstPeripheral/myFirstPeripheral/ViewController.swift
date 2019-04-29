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
    var peripheral: CBPeripheralManager!
    var requestCount: Int = 0

    var gattClient: GattClient = GattClient()

    override func viewDidLoad() {
        super.viewDidLoad()

        log("initializing...")
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
        log("peripheral state: \(stateToString(peripheral.state))")
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
                    permissions: CBAttributePermissions.readable),
                CBMutableCharacteristic(
                    type: CBUUID(string: "C0FF"),
                    properties: CBCharacteristicProperties.read,
                    value: nil,
                    permissions: CBAttributePermissions.readable),
            ]

            log("adding custom CAFE service")
            peripheral.add(service)

            log("starting advertisement")
            peripheral.startAdvertising([CBAdvertisementDataLocalNameKey: "myFirstPeripheral"])
            log("advertising")
        }
        else {
            log("still not powered on.")
        }
    }

    // Does this get called? Can we use it to detect connections?
    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
        if let er = error {
            log("Error opening L2CAP channel: \(er)")
            return
        }

        if let channel = channel {
            log("L2CAP channel opened by \(channel.peer.identifier)")
        }
        else {
            log("didOpen called but without a channel or error.")
        }
    }

    // This only gets called for the C0FF characteristic. The C0FE characteristic has a cached value.
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    {
        log("Read request received from \(request.central.identifier)")

        requestCount += 1
        let value = "Read request #\(requestCount)"
        log("response: \"\(value)\" (success)")

        request.value = value.data(using: String.Encoding.utf8)

        peripheral.respond(to: request, withResult: CBATTError.success)
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
