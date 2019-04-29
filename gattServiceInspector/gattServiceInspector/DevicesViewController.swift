//
//  DevicesViewController.swift
//  gattServiceInspector
//
//  Created by Chris Sidi on 4/15/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var discoveredTable: UITableView!
    
    var central: CBCentralManager!
    var discoveredPeripherals:[CBPeripheral] = []
    var selectedPeripheral:CBPeripheral? = nil
    var initialized = false

    // Offer a GATT Service of our own, without advertising it to unconnected devices.
    var gattServer = GattServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("")
        log("Devices: viewDidLoad")
        
        log("Initializing...")
        central = CBCentralManager(delegate: self, queue: nil)
        log("Central state: \(stateToString(central.state))")
        checkIfPowerOn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        log("Devices: viewDidAppear")
        checkIfPowerOn()
    }
    
    @IBAction func onScanButtonPressed(_ sender: Any) {
        if (central.isScanning) {
            stopScanning()
        }
        else {
            startScanning()
        }
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
        stopScanning()

        performSegue(withIdentifier: "deviceInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log("Devices segueing to \(segue.destination)")
        
        let deviceInfoController = segue.destination as! DeviceInfoViewController
        central.delegate = deviceInfoController
        deviceInfoController.central = central
        deviceInfoController.selectedPeripheral = selectedPeripheral
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("New central state: \(stateToString(central.state))")
        checkIfPowerOn()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        if (!discoveredPeripherals.contains(peripheral)) {
            log("Discovered \(peripheralDescription(peripheral))")
            discoveredPeripherals.append(peripheral)
            discoveredTable.reloadData()
        }
    }
    
    func checkIfPowerOn() {
        if (!initialized && central.state == .poweredOn) {
            startScanning()
            initialized = true
        }
        
        scanButton.isEnabled = central.state == .poweredOn
    }
    
    func startScanning() {
        if (!central.isScanning) {
            log("Starting scan.")
            central.scanForPeripherals(withServices: nil, options: nil)
            scanButton.setTitle("Stop Scan", for: .normal)
        }
    }
    
    func stopScanning() {
        if (central.isScanning) {
            log("Stopping scan.")
            central.stopScan()
            scanButton.setTitle("Resume Scan", for: .normal)
        }
    }
    
    func log(_ msg: String) {
        print(msg)
//        logView.text.append(msg)
//        logView.text.append("\n")
    }
    
    func peripheralDescription(_ peripheral: CBPeripheral) -> String {
        return "\(peripheral.identifier) (\(peripheral.name ?? "[no name]"))"
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
