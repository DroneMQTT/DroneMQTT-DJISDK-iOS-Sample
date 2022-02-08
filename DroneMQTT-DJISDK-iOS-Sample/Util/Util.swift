//
//  Util.swift
//  DroneMQTT-DJISDK-iOS-Sample
//
//  Created by Akira Hirakawa on 31/1/22.
//

import Foundation

extension String {
    
    static func randomString(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var s = ""
        for _ in 0 ..< length {
            s.append(letters.randomElement()!)
        }
        return s
    }
}
