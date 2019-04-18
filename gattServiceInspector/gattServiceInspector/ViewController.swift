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
    
    var central: CBCentralManager!
    var discoveredPeripherals:[CBPeripheral] = []
    var selectedPeripheral:CBPeripheral? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log("Initializing...")
        central = CBCentralManager(delegate: self, queue: nil)
        log("Central state: \(stateToString(central.state))")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "discoverCell")
        
        // TODO: Add latest RSSI value? Maybe on the right hand in the Accessory view section?
        cell.textLabel?.text = discoveredPeripherals[indexPath.row].name
        cell.detailTextLabel?.text =  discoveredPeripherals[indexPath.row].identifier.uuidString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPeripheral = discoveredPeripherals[indexPath.row]
        
        central.stopScan()

        performSegue(withIdentifier: "device", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let deviceController = segue.destination as! DeviceViewController
      
        central.delegate = deviceController
        deviceController.central = central
        deviceController.peripheral = selectedPeripheral
        deviceController.parentView = self
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
}
