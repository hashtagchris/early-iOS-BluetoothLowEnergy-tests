//
//  ViewController.swift
//  myFirstCentral
//
//  Created by Chris Sidi on 4/14/19.
//  Copyright © 2019 Chris Sidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var c0feButton: UIButton!
    @IBOutlet weak var c0ffButton: UIButton!
    var central: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log("initializing...")
        central = CBCentralManager(delegate: self, queue: nil)
        log("central state: \(stateToString(central.state))")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("new central state: \(stateToString(central.state))")
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
