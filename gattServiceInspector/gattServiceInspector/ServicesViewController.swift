//
//  ServicesViewController.swift
//  gattServiceInspector
//
//  Created by Chris Sidi on 4/17/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServicesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var servicesTable: UITableView!
    @IBOutlet weak var characteristicsTable: UITableView!

    var parentView: UIViewController!
    var central: CBCentralManager!
    var peripheral: CBPeripheral!
    var services:[CBService]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("")
        log("Services: viewDidLoad")

        if (services == nil) {
            log("Discovering services...")
            peripheral.discoverServices(nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        log("Services: viewDidAppear")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log("Services segueing to \(segue.destination)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let srv = services {
            return srv.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "serviceCell")
        
        // TODO: Add latest RSSI value? Maybe on the right hand in the Accessory view section?
        cell.textLabel?.text = services![indexPath.row].uuid.uuidString
        
        return cell
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        log("Connected to \(peripheralDescription(peripheral))")
//
//        services = []
//
//        peripheral.delegate = self
//        peripheral.discoverServices(nil)
//    }
    
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
