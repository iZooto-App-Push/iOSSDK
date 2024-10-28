//
//  SharedUserDefault.swift
//  MomagiciOSSDK
//
//  Created by Amit on 13/06/21.
//

import Foundation
struct SharedUserDefault {
    static let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
    
    static let suitName = Utils.getBundleName(bundleName: bundleName)
    
    struct Key {
        static let token = "saveToken"
        static let registerID = "momagic_id"
        static let subscriberID = "subscriber_id"
    }
}
