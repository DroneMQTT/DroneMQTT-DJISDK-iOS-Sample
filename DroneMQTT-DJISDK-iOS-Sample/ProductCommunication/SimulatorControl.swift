//
//  SimulatorControl.swift
//  DroneMQTT-DJISDK-iOS-Sample
//
//  Created by Akira Hirakawa on 2/12/21.
//

import UIKit
import DJISDK

public let FligntControllerSimulatorDidStart = "FligntControllerSimulatorDidStart"
public let FligntControllerSimulatorDidStop = "FligntControllerSimulatorDidStop"

class SimulatorControl: NSObject {
    fileprivate var _isSimulatorActive: Bool = false
    public var isSimulatorActive: Bool {
        get {
            return _isSimulatorActive
        }
        set {
            _isSimulatorActive = newValue
            postNotificationNamed(newValue ? FligntControllerSimulatorDidStart : FligntControllerSimulatorDidStop, dispatchOntoMainQueue: true)
        }
    }
    
    func startListeningToProductState() {
        if let isSimulatorActiveKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsSimulatorActive) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: isSimulatorActiveKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if let isSimulatorActive = newValue?.boolValue {
                    self.isSimulatorActive = isSimulatorActive
                }
            })
            
            DJISDKManager.keyManager()?.getValueFor(isSimulatorActiveKey, withCompletion: { (value: DJIKeyedValue?, error: Error?) in
                if let isSimulatorActive = value?.boolValue {
                    self.isSimulatorActive = isSimulatorActive
                }
            })
        }
    }
    
    func stopListeningOnProductState() {
        let isSimulatorActiveKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsSimulatorActive)!
        
        DJISDKManager.keyManager()?.stopListening(on: isSimulatorActiveKey,
                                          ofListener: self)
    }
    
    deinit {
        self.stopListeningOnProductState()
    }
    
    // Returns false if no aircraft present, true if simulator command sent
    func startSimulator(at locationCoordinates:CLLocationCoordinate2D) -> Bool {
        guard let aircraft = DJISDKManager.product() as? DJIAircraft else {
            return false
        }
        
        guard let simulator = aircraft.flightController?.simulator else {
            return false
        }
        
        simulator.start(withLocation: locationCoordinates,
                     updateFrequency: 20,
                 gpsSatellitesNumber: 12) { (error:Error?) in
            if let e = error {
                print("Start Simulator Error: \(e)")
            } else {
                print("Start Simulator Command Acked")
            }
        }
        
        return true
    }
    
    func stopSimulator() -> Bool {
        guard let stopSimulatorKey = DJIFlightControllerKey(param: DJIFlightControllerParamStopSimulator) else {
            return false
        }
        
        guard let keyManager = DJISDKManager.keyManager() else {
            return false
        }
        
        keyManager.performAction(for: stopSimulatorKey,
                                 withArguments: nil,
                                 andCompletion: { (didSucceed:Bool, value:DJIKeyedValue?, error:Error?) in
            if let e = error {
                print("Stop Simulator Error: \(e)")
            } else {
                print("Stop Simulator Command Acked")
            }
        })
        
        return true
    }
}

