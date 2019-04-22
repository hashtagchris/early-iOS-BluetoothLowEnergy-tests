//
//  DeviceInfoViewController.swift
//  gattServiceInspector
//
//  Created by Chris Sidi on 4/18/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceInfoViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var inspectButton: UIButton!
    @IBOutlet weak var manufacturerName: UITextField!
    @IBOutlet weak var modelNumber: UITextField!
    @IBOutlet weak var serialNumber: UITextField!
    @IBOutlet weak var hardwareRevision: UITextField!
    @IBOutlet weak var firmwareRevision: UITextField!
    @IBOutlet weak var softwareRevision: UITextField!
    @IBOutlet weak var systemId: UITextField!
    
    var central: CBCentralManager!
    var selectedPeripheral: CBPeripheral!
    var services:[CBService]? = nil
    var DeviceInfoUUID = CBUUID(string: "180A")
    var discoveredAllServices = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("")
        log("DeviceInfo: viewDidLoad")
        
        deviceNameLabel.text = selectedPeripheral.name ?? selectedPeripheral.identifier.uuidString
        
        log("connecting...")
        statusLabel.text = "Connecting..."
        inspectButton.isEnabled = false
        central.connect(selectedPeripheral, options: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        log("DeviceInfo: viewDidAppear")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log("DeviceInfo segueing to \(segue.destination)")
        
        let servicesController = segue.destination as! ServicesViewController
        central.delegate = servicesController
        selectedPeripheral.delegate = servicesController
        
        servicesController.central = central
        servicesController.selectedPeripheral = selectedPeripheral
        servicesController.services = services
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if peripheral != selectedPeripheral {
            log("Ignoring failure to connect to another peripheral, \(peripheralDescription(peripheral)).")
            return
        }

        if let er = error {
            log("Failed to connect: \(er)")
            statusLabel.text = "Failed to connect: \(er)"
        }
        else {
            log("Failed to connect.")
            statusLabel.text = "Failed to connect"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral != selectedPeripheral {
            log("Ignoring services for other peripheral, \(peripheralDescription(peripheral)).")
            return
        }

        log("connected")
        statusLabel.text = "Connected"
        inspectButton.isEnabled = true
        
        discoveredAllServices = false
        peripheral.delegate = self
        peripheral.discoverServices([DeviceInfoUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral != selectedPeripheral {
            log("Ignoring services for other peripheral, \(peripheralDescription(peripheral)).")
            return
        }

        if let er = error {
            log("Error discovering services: \(er)")
        }
        else {
            log("Discovered \(peripheral.services!.count) service(s)")
            
            services = peripheral.services!
            
            for service in peripheral.services! {
                if (service.uuid == DeviceInfoUUID) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            
            if (!discoveredAllServices) {
                // Discover the rest of the services
                peripheral.discoverServices(nil)
                discoveredAllServices = true
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if peripheral != selectedPeripheral {
            log("Ignoring characteristics for other peripheral, \(peripheralDescription(peripheral)).")
            return
        }

        if let er = error {
            log("Error discovering characteristics: \(er)")
        }
        else if (service.uuid == DeviceInfoUUID) {
            for characteristic in service.characteristics! {
                if characteristic.value == nil {
                    log("Reading the value for \(characteristic.uuid)")
                    peripheral.readValue(for: characteristic)
                }
                else {
                    updateLabel(characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if peripheral != selectedPeripheral {
            log("Ignoring updated values for other peripheral, \(peripheralDescription(peripheral)).")
            return
        }

        if let er = error {
            log("Error reading value: \(er)")
        }
        else {
            updateLabel(characteristic)
        }
    }
    
    func updateLabel(_ characteristic: CBCharacteristic) {
        if let val = characteristic.value {
            log("DeviceInfo characteristic: \(characteristic.uuid)")
            
            if (characteristic.uuid == CBUUID(string: "2A29")) {
                manufacturerName.text = dataToString(val)
            }
            else if (characteristic.uuid == CBUUID(string: "2A24")) {
                modelNumber.text = dataToString(val)
            }
            else if (characteristic.uuid == CBUUID(string: "2A29")) {
                manufacturerName.text = dataToString(val)
            }
            else if (characteristic.uuid == CBUUID(string: "2A25")) {
                serialNumber.text = dataToString(val)
            }
            else if (characteristic.uuid == CBUUID(string: "2A26")) {
                firmwareRevision.text = dataToString(val)
            }
            else if (characteristic.uuid == CBUUID(string: "2A28")) {
                softwareRevision.text = dataToString(val)
            }
            else if (characteristic.uuid == CBUUID(string: "2A23")) {
                // TODO: Read two byte arrays
                systemId.text = dataToString(val)
            }
        }
    }
    
    func log(_ msg: String) {
        print(msg)
    }
    
    func peripheralDescription(_ peripheral: CBPeripheral) -> String {
        return "\(peripheral.identifier) (\(peripheral.name ?? "[no name]"))"
    }
    
    func dataToString(_ value: Data?) -> String {
        if (value != nil) {
            if let string = String(data: value!, encoding: .utf8) {
                return string
            } else {
                return "<<\(value!)>>"
            }
        } else {
            return "[nil]"
        }
    }
}
