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
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var inspectButton: UIButton!

    var central: CBCentralManager!
    var peripheral: CBPeripheral!
    var services:[CBService]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("")
        log("DeviceInfo: viewDidLoad")
        
        inspectButton.isEnabled = false
        
        log("connecting...")
        statusLabel.text = "Connecting..."
        // TODO: Disconnect from any other peripheral
        central.connect(peripheral, options: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        log("DeviceInfo: viewDidAppear")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log("DeviceInfo segueing to \(segue.destination)")
        
        let servicesController = segue.destination as! ServicesViewController
        central.delegate = servicesController
        peripheral.delegate = servicesController
        
        servicesController.central = central
        servicesController.peripheral = peripheral
        servicesController.services = services
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log("failed to connect")

        if let er = error {
            statusLabel.text = "Failed to connect: \(er)"
        }
        else {
            statusLabel.text = "Failed to connect"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("connected")
        statusLabel.text = "Connected"
        inspectButton.isEnabled = true
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let er = error {
            log("Error discovering services: \(er)")
        }
        else {
            log("Discovered \(peripheral.services!.count) service(s)")
            
            services = peripheral.services!
        }
    }
    
    func log(_ msg: String) {
        print(msg)
    }
}
