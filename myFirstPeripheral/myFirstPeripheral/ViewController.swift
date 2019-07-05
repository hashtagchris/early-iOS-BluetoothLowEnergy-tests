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
    var nameProvided: String? = nil
    var cffeCharacteristic: CBMutableCharacteristic!
    var timer: Timer? = nil
    var updateCount = 0

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

            cffeCharacteristic = CBMutableCharacteristic(
                type: CBUUID(string: "CFFE"),
                properties: [CBCharacteristicProperties.read, CBCharacteristicProperties.notify],
                value: nil,
                permissions: CBAttributePermissions.readable)

            let service = CBMutableService(type: CBUUID(string: "CAFE"), primary: true)

            service.characteristics = [
                cffeCharacteristic,

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
                CBMutableCharacteristic(
                    type: CBUUID(string: "F00D"),
                    properties: .write,
                    value: nil,
                    permissions: .writeable),
                CBMutableCharacteristic(
                    type: CBUUID(string: "F00E"),
                    properties: .writeWithoutResponse,
                    value: nil,
                    permissions: .writeable),
                CBMutableCharacteristic(
                    type: CBUUID(string: "F00F"),
                    properties: .write,
                    value: nil,
                    permissions: .writeEncryptionRequired),
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

    // This delegate only gets called for the C0FF and CFFE characteristics. The C0FE characteristic has a cached value.
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    {
        log("Read request received from \(request.central.identifier)")

        let value: String;
        if (request.characteristic == cffeCharacteristic) {
            value = "Subscribe to receive the current time every 5 seconds."
        }
        else {
            requestCount += 1
            value = nameProvided != nil
                ? "Read request #\(requestCount), \(nameProvided!)"
                : "Read request #\(requestCount)"
        }

        log("response: \"\(value)\" (success)")

        request.value = value.data(using: String.Encoding.utf8)

        peripheral.respond(to: request, withResult: CBATTError.success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        log("\(requests.count) write request(s) received.")

        for request in requests {
            log("Write request received from \(request.central.identifier)")

            if let value = request.value {
                if let string = String(data: value, encoding: .utf8) {
                    if string.count > 0 {
                        log("Write payload: \"\(string)\"")
                        nameProvided = string
                    }
                }
            }

            peripheral.respond(to: request, withResult: CBATTError.success)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        // https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/PerformingCommonPeripheralRoleTasks/PerformingCommonPeripheralRoleTasks.html#//apple_ref/doc/uid/TP40013257-CH4-SW1

        log("Central subscribing to \(characteristic.uuid) characteristic")

        if (characteristic == cffeCharacteristic && timer == nil) {
            log("Setting up timer to update the CFFE characteristic every 5 seconds.")
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: updateProperties)
        }
    }

    func updateProperties(timer: Timer) {
        updateCount += 1

        let time = NSDate()
        let newValue = "[\(updateCount)] Hello, the time is now \(time)."
        log("Updating CFFE characteristic value...")
        peripheral.updateValue(newValue.data(using: String.Encoding.utf8)!, for: cffeCharacteristic, onSubscribedCentrals: nil)
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
