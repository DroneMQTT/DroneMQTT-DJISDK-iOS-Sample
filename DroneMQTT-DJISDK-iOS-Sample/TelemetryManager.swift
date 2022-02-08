//
//  TelemetryManager.swift
//  DroneMQTT-DJISDK-iOS-Sample
//
//  Created by Akira Hirakawa on 31/1/22.
//

import Foundation
import DJIUXSDK
import Moscapsule

class MqttTelemetry {
    var fcState: DJIFlightControllerState?
    var gimbalState: DJIGimbalState?
}


class TelemetryManager {
    
    let mqttClient: MQTTClient
    
    init(host: String, port: Int32, username: String, password: String) {
        
        let clientId = String.randomString(of: 10)
        
        let mqttConfig = MQTTConfig(clientId: clientId, host: host, port: port, keepAlive: 60)
        mqttConfig.mqttAuthOpts = MQTTAuthOpts(username: username, password: password)
        mqttConfig.onConnectCallback = { returnCode in
            NSLog("Return Code is \(returnCode.description)")
        }
        
        self.mqttClient = MQTT.newConnection(mqttConfig)
    }
    
    func close() {
        if(self.mqttClient.isConnected) {
            self.mqttClient.disconnect(nil)
        }
    }
    
    func send(topic: String, telemetry: MqttTelemetry) {
        
        if let fcState = telemetry.fcState, let gimbalState = telemetry.gimbalState {
            if let location = fcState.aircraftLocation {
    
                var position = Dictionary<String, Any>()
                position["alt"] = location.altitude
                position["lat"] = location.coordinate.latitude
                position["lon"] = location.coordinate.longitude

                var attitude = Dictionary<String, Any>()
                attitude["yaw"] = fcState.attitude.yaw
                attitude["pitch"] = fcState.attitude.pitch
                attitude["roll"] = fcState.attitude.roll

                var gimbal = Dictionary<String, Any>()
                gimbal["pitch"] = gimbalState.attitudeInDegrees.pitch
 
                var data = Dictionary<String, Any>()
                data["position"] = position
                data["attitude"] = attitude
                data["gimbal"] = gimbal
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    self.mqttClient.publish(jsonData, topic: topic, qos: 1, retain: false, requestCompletion: nil)
                } catch (let e) {
                    print(e)
                }

                // for string message
//                let alt = location.altitude
//                let lat = location.coordinate.latitude
//                let lon = location.coordinate.longitude
//                let yaw = fcState.attitude.yaw
//                let pitch = fcState.attitude.pitch
//                let roll = fcState.attitude.roll
//                let gimbal = gimbalState.attitudeInDegrees
//                let payload = String(format: "%f,%f,%f,%f,%f,%f,%f", alt, lat, lon, yaw, pitch, roll, gimbal.pitch)
//                self.mqttClient.publish(string: payload, topic: topic, qos: 1, retain: false, requestCompletion: nil)
            }
        }
    }
}
