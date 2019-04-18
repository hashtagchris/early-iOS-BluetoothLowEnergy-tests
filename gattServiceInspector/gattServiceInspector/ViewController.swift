//
//  ViewController.swift
//  gattServiceInspector
//
//  Created by Chris Sidi on 4/15/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var discoveredTable: UITableView!
    @IBOutlet weak var servicesTable: UITableView!
    
    var central: CBCentralManager!
    var discoveredPeripherals:[CBPeripheral] = []
    var services:[CBService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log("Initializing...")
        central = CBCentralManager(delegate: self, queue: nil)
        log("Central state: \(stateToString(central.state))")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == discoveredTable) {
            return discoveredPeripherals.count
        }
        else {
            return services.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == discoveredTable) {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "discoverCell")
            
            // TODO: Add latest RSSI value? Maybe on the right hand in the Accessory view section?
            cell.textLabel?.text = discoveredPeripherals[indexPath.row].name
            cell.detailTextLabel?.text =  discoveredPeripherals[indexPath.row].identifier.uuidString
            
            return cell
        }
        else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "serviceCell")
            
            // TODO: Add latest RSSI value? Maybe on the right hand in the Accessory view section?
            cell.textLabel?.text = services[indexPath.row].uuid.uuidString
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = discoveredPeripherals[indexPath.row]
        
        // TODO: Disconnect from any other peripheral
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        log("Connected to \(peripheralDescription(peripheral))")
        
        services = []
        
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
            servicesTable.reloadData()
            
//            for service in peripheral.services! {
//                log("  * Service: \(service.uuid)")
//                peripheral.discoverCharacteristics(nil, for: service)
//            }
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("New central state: \(stateToString(central.state))")

        if (central.state == .poweredOn) {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        if (!discoveredPeripherals.contains(peripheral)) {
            discoveredPeripherals.append(peripheral)
            discoveredTable.reloadData()
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
    
    func peripheralDescription(_ peripheral: CBPeripheral) -> String {
        return "\(peripheral.identifier) (\(peripheral.name ?? "[no name]"))"
    }
}
