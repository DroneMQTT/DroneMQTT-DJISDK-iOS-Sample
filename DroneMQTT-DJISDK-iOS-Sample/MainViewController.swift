//
//  ViewController.swift
//  DroneMQTT-DJISDK-iOS-Sample
//
//  Created by Akira Hirakawa on 29/11/21.
//

import UIKit
import DJISDK

class MainViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(productCommunicationDidChange), name: Notification.Name(rawValue: ProductCommunicationServiceStateDidChange), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var version = DJISDKManager.sdkVersion()
        if version == "" {
            version = "N/A"
        } else {
            self.versionLabel.text = "DJI SDK Version: \(version)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ProductCommunicationService.shared.connectToProduct()
    }

    @objc func productCommunicationDidChange() {
        let service = ProductCommunicationService.shared
        
        if service.registered {
            self.statusLabel.text = "Status: Product registered.."
        }
        
        if service.connected {
            self.statusLabel.text = "Status: Product connected.."
            self.modelLabel.text = service.connectedProduct.model
            self.openButton.isEnabled = true
        }
    }
}
