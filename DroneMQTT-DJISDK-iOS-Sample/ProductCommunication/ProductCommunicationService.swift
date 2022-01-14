//
//  ProductCommunicationService.swift
//  DroneMQTT-DJISDK-iOS-Sample
//
//  Created by Akira Hirakawa on 29/11/21.
//

import UIKit
import DJISDK

let ProductCommunicationServiceStateDidChange = "ProductCommunicationServiceStateDidChange"

func postNotificationNamed(_ rawStringName:String,
                           dispatchOntoMainQueue:Bool = false,
                           notificationCenter:NotificationCenter = NotificationCenter.default) {
    let post = {
        notificationCenter.post(Notification(name: Notification.Name(rawValue: rawStringName)))
    }
    
    if dispatchOntoMainQueue {
        DispatchQueue.main.async {
            post()
        }
    } else {
        post()
    }
}

class ProductCommunicationService: NSObject {

    static let shared = ProductCommunicationService()

    let simulatorControl = SimulatorControl()
    
    open var connectedProduct: DJIAircraft!
    
    var registered = false
    var connected = false
    var message = ""

    func registerWithProduct() {
     
        guard
            let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject>,
            let appKey = dict["DJISDKAppKey"] as? String,
            appKey != "PASTE_YOUR_DJI_APP_KEY_HERE"
        else {
            print("\n<<<ERROR: Please add DJI App Key in Info.plist after registering as developer>>>\n")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            NSLog("Registering Product with registration ID: \(appKey)")
            DJISDKManager.registerApp(with: self)
        })
    }
    
    //MARK: - Start Connecting to Product
    open func connectToProduct() {

        self.logger("Connecting to product...")
        let startedResult = DJISDKManager.startConnectionToProduct()
        
        if startedResult {
            self.logger("Connecting to product started successfully!")
        } else {
            self.logger("Connecting to product failed to start!")
        }
    }
    
    public func disconnectProduct() {
        DJISDKManager.stopConnectionToProduct()
        
        self.connected = false
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ProductCommunicationManagerStateDidChange")))
    }
    
    // Returns false if no aircraft present, true if simulator command sent
    func stopSimulator() -> Bool {
        return self.simulatorControl.stopSimulator()
    }
    
    // Returns false if no aircraft present, true if simulator command sent
    func startSimulator(at locationCoordinates:CLLocationCoordinate2D) -> Bool {
        return self.simulatorControl.startSimulator(at: locationCoordinates)
    }
    
    func logger(_ message: String) {
        self.message = message
        NSLog(self.message)
    }
}

extension ProductCommunicationService: DJISDKManagerDelegate {

    func appRegisteredWithError(_ error: Error?) {
        if error == nil {
            self.registered = true
            postNotificationNamed(ProductCommunicationServiceStateDidChange, dispatchOntoMainQueue: true)

            self.simulatorControl.startListeningToProductState()

            self.connectToProduct()
        } else {
            let msg = "Error Registrating App: \(String(describing: error))"
            self.logger(msg)
        }
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        print("Downloading Database Progress: \(progress.completedUnitCount) / \(progress.totalUnitCount)")
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if product != nil && product is DJIAircraft {
            self.logger("Connection to new product succeeded!")
            self.connected = true
            self.connectedProduct = product as? DJIAircraft
            self.simulatorControl.startListeningToProductState()
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: ProductCommunicationServiceStateDidChange)))

            self.logger(product!.description)
            
            
        } else {
            self.logger("The product is nil")
        }
    }
    
    func productDisconnected() {
        self.connected = false
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: ProductCommunicationServiceStateDidChange)))
        self.logger("Disconnected from product!");
    }
}
