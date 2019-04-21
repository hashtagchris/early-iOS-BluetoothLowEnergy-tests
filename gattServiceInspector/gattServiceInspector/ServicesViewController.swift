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
    @IBOutlet weak var valueTextView: UITextView!
    
    var parentView: UIViewController!
    var central: CBCentralManager!
    var selectedPeripheral: CBPeripheral!
    var services:[CBService]? = nil
    var characteristics:[CBCharacteristic]? = nil
    var selectedService:CBService? = nil
    var selectedCharacteristic:CBCharacteristic? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("")
        log("Services: viewDidLoad")

        if (services == nil) {
            log("Discovering services...")
            selectedPeripheral.discoverServices(nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        log("Services: viewDidAppear")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log("Services segueing to \(segue.destination)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array:[CBAttribute]? = tableView == servicesTable
            ? services
            : characteristics
        
//        if tableView == servicesTable {
//            array = services
//        }
//        else {
//            array = characteristics
//        }
        
        return array?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array:[CBAttribute]? = tableView == servicesTable
            ? services
            : characteristics

        let cellIdentifier = tableView == servicesTable
            ? "serviceCell"
            : "characteristicCell"
    
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = array![indexPath.row].uuid.uuidString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == servicesTable {
            selectedService = services![indexPath.row]
            selectedPeripheral.discoverCharacteristics(nil, for: selectedService!)
        }
        else {
            selectedCharacteristic = characteristics![indexPath.row]
            selectedPeripheral.readValue(for: selectedCharacteristic!)
        }
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
        if peripheral != selectedPeripheral {
            log("Ignoring services for other peripheral, \(peripheralDescription(peripheral))")
            return
        }
        
        if let er = error {
            log("Error discovering services: \(er)")
        }
        else {
            log("Discovered \(peripheral.services!.count) service(s)")
            
            services = peripheral.services
            servicesTable.reloadData()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if peripheral != selectedPeripheral {
            log("Ignoring characteristics for other peripheral, \(peripheralDescription(peripheral))")
            return
        }

        if service != selectedService {
            log("Ignoring characteristics for other service, \(service)")
            return
        }
        
        if let er = error {
            log("Error discovering characteristics: \(er)")
        }
        else {
            log("Discovered \(service.characteristics!.count) characteristic(s)")
            
            characteristics = service.characteristics
            characteristicsTable.reloadData()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if peripheral != selectedPeripheral {
            log("Ignoring value for other peripheral, \(peripheralDescription(peripheral))")
            return
        }
        
        if characteristic.service != selectedService {
            log("Ignoring value for other service, \(characteristic.service)")
            return
        }

        if characteristic != selectedCharacteristic {
            log("Ignoring value for other characteristic, \(characteristic)")
            return
        }
        
        valueTextView.text = dataToString(characteristic.value)
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
