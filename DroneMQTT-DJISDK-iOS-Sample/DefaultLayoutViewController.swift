//
//  DefaultLayoutViewController.swift
//  DroneMQTT-DJISDK-iOS-Sample
//
//  Created by Akira Hirakawa on 30/11/21.
//

import UIKit
import DJIUXSDK
import Moscapsule

// A simple example using MQTT on DJISDK. Please do not use this program for actual flight.
class DefaultLayoutViewController: DUXDefaultLayoutViewController {

    let host = "[assigned-domain].dronemqtt.com"
    let port: Int32 = 1883
    let username = "[mqtt username]"
    let password = "[mqtt password]"
    let topic = "dronemqtt/test"
    let aircraftName = "djidrone"
    var mqttClient: MQTTClient?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    @IBAction func close () {
        if self.mqttClient != nil {
            self.mqttClient?.disconnect(nil)
        }

        self.dismiss(animated: true) {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MQTT config
        let clientId = self.randomString(of: 10)
        let mqttConfig = MQTTConfig(clientId: clientId, host: self.host, port: self.port, keepAlive: 60)
        mqttConfig.mqttAuthOpts = MQTTAuthOpts(username: self.username, password: self.password)
        mqttConfig.onConnectCallback = { returnCode in
            NSLog("Return Code is \(returnCode.description)")
        }
        self.mqttClient = MQTT.newConnection(mqttConfig)

        let service = ProductCommunicationService.shared

        if let fc = service.connectedProduct.flightController {
            fc.delegate = self
        }
    }
    
    func randomString(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var s = ""
        for _ in 0 ..< length {
            s.append(letters.randomElement()!)
        }
        return s
    }
}

extension DefaultLayoutViewController: DJIFlightControllerDelegate {
 
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        if let location = state.aircraftLocation {
            let alt = location.altitude
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude

            let payload = String(format: "%@,%f,%f,%f", self.aircraftName, alt, lat, lon)
            self.mqttClient?.publish(string: payload, topic: self.topic, qos: 1, retain: false, requestCompletion: nil)
        }
    }
}
