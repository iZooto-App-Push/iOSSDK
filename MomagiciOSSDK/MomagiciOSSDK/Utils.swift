//
//  Utils.swift
//  MomagiciOSSDK
//
//  Created by Amit on 13/06/21.
//

import Foundation
import UIKit
@objc
public class Utils : NSObject
{
    public static  let TOKEN = "save_token"
    
    public static func getDeviceName()->String
    {
        let deviceName = UIDevice.current.name
        return deviceName
    }
    
    public static func getSystemVersion()->String{
        let systemVersion = UIDevice.current.systemVersion
        return systemVersion
    }
    
    public static func saveAccessToken(access_token: String){
        let preferences = UserDefaults.standard
        preferences.set(access_token, forKey: TOKEN)
        Utils.didSave(preferences: preferences)
    }
    
    public static func getAccessToken() -> String{
        let preferences = UserDefaults.standard
        if preferences.string(forKey: TOKEN) != nil{
            let access_token = preferences.string(forKey: TOKEN)
            return access_token!
        } else {
            return ""
        }
    }
    
    public static func getUserDeviceToken() -> String? {
        return sharedUserDefault?.string(forKey: SharedUserDefault.Key.token) ?? ""
    }
    
    public static func getUserPID() -> Int? {
        return sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID) ?? 0
    }
        
    public static func initFireBaseInialise(isInitialise : Bool)
    {
        let preference = UserDefaults.standard
        preference.set(isInitialise, forKey: "INSTALL")
        didSave(preferences: preference)
    }
    
    // Checking the UserDefaults is saved or not
    public static func didSave(preferences: UserDefaults){
        let didSave = preferences.synchronize()
        if !didSave{
            // Couldn't Save
            print("Preferences could not be saved!")
        }
    }
    
    public static func eventValidate(eventName : String)->String
    {
        let replaced = eventName.replacingOccurrences(of: " ", with: "_")
        let validataEventname = createSubstring(string: replaced, length: 32)
        return validataEventname.lowercased()
    }
    
    public static func dataValidate(data: [String: Any]) -> [String: Any] {
        var updatedData = [String: Any]()
        
        for (key, value) in data {
            let keyName = createSubstring(string: key, length: 32).lowercased()
            
            if let intValue = value as? Int {
                updatedData[keyName] = intValue
            } else if let boolValue = value as? Bool {
                updatedData[keyName] = boolValue
            } else if let stringValue = value as? String {
                let newValue = createSubstring(string: stringValue, length: 64)
                updatedData[keyName] = newValue
            }
        }
        
        return updatedData
    }

    
    public static func createSubstring(string: String, length: Int) -> String {
        guard length > 0 else {
            // Return an empty string if length is non-positive
            return ""
        }
        
        // Use `prefix` to truncate the string efficiently
        let endIndex = string.index(string.startIndex, offsetBy: min(length, string.count))
        return String(string[string.startIndex..<endIndex])
    }
    
    public static func getBundleName() -> String {
        if let bundleID = Bundle.main.bundleIdentifier {
            return "group."+bundleID+".datb"
        } else {
            // Provide a fallback value or handle the case where bundleID is nil
            return "group.default.bundle.datb"
        }
    }
    
    // get Bundle ID
    static func getAppInfo()->String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
    }
    
    // get App Name
    static func getAppName()->String {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        return appName
    }
    
    // getOS Information
    static func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    // get App version
    static func getAppVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        // print(version)
        return "\(version)"
    }
    
    // current timestamp
    static func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    // get device id
    static func getUUID()->String
    {
        let device_id = UIDevice.current.identifierForVendor!.uuidString
        return device_id
    }
    
    //get add version
    static func  getVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    
    public static  func handleOnceException(exceptionName: String, className: String, methodName: String,  rid: String, cid: String)
        {
            
            
            let userDefaults = UserDefaults.standard
            guard let appid = (UserDefaults.standard.value(forKey: "appID") as? String) else {
                print("App ID not found to send exception.")
                return
            }
            if userDefaults.object(forKey: methodName) == nil{
                   userDefaults.set("isPresent", forKey: methodName)
                RestAPI.sendExceptionToServer(exceptionName: exceptionName, className: className, methodName: methodName,  rid: rid, cid: cid, appId: appid)
                   
               } else {
                   print("Key \(methodName) already exists. Data not stored.")
               }
        }
    
    public static func getUserId() -> String? {
            let userDefault = UserDefaults.standard
            return userDefault.string(forKey: AppConstant.REGISTERED_ID)
        }
    
}

public  func checkTopicNameValidation(topicName : Dictionary<String,String>)-> Bool
{
    let pattern = "[a-zA-Z0-9-_.~%]+"
    print(pattern)
    return true
}







