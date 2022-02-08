//
//  DJISDKUtil.swift
//  DroneMQTT-DJISDK-iOS-Sample
//
//  Created by Akira Hirakawa on 31/1/22.
//

import DJISDK
//import DJIWidget

class DJISDKUtil {

    static func fetchGimbal() -> DJIGimbal? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        
        if product is DJIAircraft {
            return product.gimbal
        }
        return nil
    }
            
    static func fetchAircraft() -> DJIAircraft? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        
        if product is DJIAircraft {
            return (product as! DJIAircraft)
        }
        
        return nil
    }
}
