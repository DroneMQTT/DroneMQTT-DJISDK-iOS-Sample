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
    let username = "[mqtt username]"
    let password = "[mqtt password]"
    let port: Int32 = 1883
    let topic = "dronemqtt/state"
    let timerInterval = 0.1
    let telemetry = MqttTelemetry()
    var telemetryManager: TelemetryManager?
    var timer: Timer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.telemetryManager = TelemetryManager(host:host, port:port, username: username, password: password)
        
        if let fc = DJISDKUtil.fetchAircraft()?.flightController {
            fc.delegate = self
        }
        
        if let gimbal = DJISDKUtil.fetchGimbal() {
            gimbal.delegate = self
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: self.timerInterval, repeats: true, block: self.sendMQTT)
    }

    func sendMQTT(timer: Timer) {
        self.telemetryManager?.send(topic: self.topic, telemetry: self.telemetry)
    }
    
    @IBAction func close () {
        if self.telemetryManager != nil {
            self.telemetryManager?.close()
        }

        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        self.dismiss(animated: true)
    }
}

extension DefaultLayoutViewController: DJIFlightControllerDelegate {
 
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        self.telemetry.fcState = state
    }
}

extension DefaultLayoutViewController: DJIGimbalDelegate {
    
    func gimbal(_ gimbal: DJIGimbal, didUpdate state: DJIGimbalState) {
        self.telemetry.gimbalState = state
    }
}
