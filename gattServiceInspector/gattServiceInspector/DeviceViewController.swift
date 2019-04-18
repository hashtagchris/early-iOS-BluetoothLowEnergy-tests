//
//  DeviceViewController.swift
//  gattServiceInspector
//
//  Created by Chris Sidi on 4/17/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var servicesTable: UITableView!
    @IBOutlet weak var characteristicsTable: UITableView!

    var parentView: UIViewController!
    var central: CBCentralManager!
    var peripheral: CBPeripheral!
    var services:[CBService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // TODO: Disconnect from any other peripheral
        central.connect(peripheral, options: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "serviceCell")
        
        // TODO: Add latest RSSI value? Maybe on the right hand in the Accessory view section?
        cell.textLabel?.text = services[indexPath.row].uuid.uuidString
        
        return cell
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
        }
    }
    
    func log(_ msg: String) {
        print(msg)
    }
    
    func peripheralDescription(_ peripheral: CBPeripheral) -> String {
        return "\(peripheral.identifier) (\(peripheral.name ?? "[no name]"))"
    }
}
