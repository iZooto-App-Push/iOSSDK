//
//  SharedUserDefault.swift
//  MomagiciOSSDK
//
//  Created by Amit on 13/06/21.
//

import Foundation
@available(iOS 11.0, *)
struct SharedUserDefault {
    static let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
    
    static let suitName = Utils.getGroupName(bundleName: bundleName)
    
    struct Key {
        static let token = "saveToken"
        static let registerID = "momagic_id"
        static let subscriberID = "subscriber_id"
    }
}
