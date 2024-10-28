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

    public static func getUserDeviceToken(bundleName : String) -> String? {
        if let userDefault = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
                return userDefault.string(forKey: AppConstant.IZ_GRPS_TKN)
            }else{
                return "token not found"
            }
        }
        
        public static func getUserId(bundleName : String) -> String? {
            if let userDefault = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
                return userDefault.string(forKey: AppConstant.REGISTERED_ID)
            }else{
                return "pid not found"
            }
            
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
    

    public static func getBundleName(bundleName : String)->String
        {
          return "group."+bundleName+".datb"
           
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
   
    
    static func handleOnceException(bundleName : String,exceptionName: String, className: String, methodName: String,  rid: String?, cid: String?, userInfo: [AnyHashable: Any]?)
       {
           let userDefaults = UserDefaults.standard
           var appid = ""
           if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
               appid = userDefaults.value(forKey: "appID") as? String ?? ""
           }
           if userDefaults.object(forKey: methodName) == nil{
                  userDefaults.set("isPresent", forKey: methodName)
               RestAPI.sendExceptionToServer(bundleName: bundleName,exceptionName: exceptionName, className: className, methodName: methodName,  rid: rid, cid: cid, appId: appid, userInfo: userInfo ?? nil)
                  
              } else {
                  print("Key \(methodName) already exists. Data not stored.")
              }
       }
    static func addMacros(url: String) -> String {
         let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
           var finalUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
           if finalUrl != "" && !finalUrl.isEmpty{
               var registerTime: TimeInterval = 0
               let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
               let pid = Utils.getUserId(bundleName: bundleName) ?? ""
               if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
                   registerTime = userDefaults.value(forKey: "unixTS") as? TimeInterval ?? 0
               }
               let time = Utils.unixTimeDifference(unixTimestamp: registerTime )
               
               if finalUrl.contains("{~UUID~}") {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~UUID~}", with: token)
               }
               if finalUrl.contains("{~ADID~}") {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~ADID~}", with: RestAPI.identifierForAdvertising() ?? "")
               }
               if finalUrl.contains("{~PID~}") {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~PID~}", with: pid)
               }
               if finalUrl.contains("{~DEVICEID~}") {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~DEVICEID~}", with: token)
               }
               if finalUrl.contains("{~DEVICETOKEN~}")
               {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~DEVICETOKEN~}", with: token)
               }
               if finalUrl.contains("{~SUBAGED~}")
               {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~SUBAGED~}", with: String(time.days))
               }
               if finalUrl.contains("{~SUBAGEM~}")
               {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~SUBAGEM~}", with: String(time.months))
               }
               if finalUrl.contains("{~SUBAGEY~}")
               {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~SUBAGEY~}", with: String(time.years))
               }
               if finalUrl.contains("{~SUBUTS~}")
               {
                   finalUrl = finalUrl.replacingOccurrences(of: "{~SUBUTS~}", with: String(Int64(registerTime)))
               }
               
           }
           return finalUrl
       }
       
      
       static func unixTimeDifference(unixTimestamp: TimeInterval) -> (years: Int, months: Int, days: Int) {
           
           let registeredTimestampMillis: TimeInterval = unixTimestamp// Add your registered timestamp in milliseconds here
           let currentTimestampMillis: TimeInterval = TimeInterval(Int(Date().timeIntervalSince1970 * 1000))
           
   //        let registeredTimestampMillis: TimeInterval = 1754718397000
   //        let currentTimestampMillis: TimeInterval = 1838368000000
           
           let currentDate = Date(timeIntervalSince1970: currentTimestampMillis / 1000)
           let registeredDate = Date(timeIntervalSince1970: registeredTimestampMillis / 1000)
           
           var calendar = Calendar.current
           calendar.timeZone = .current
           let components = calendar.dateComponents([.year, .month, .day], from: registeredDate, to: currentDate)
           
           let years = components.year ?? 0
           let months = components.month ?? 0
           let days = components.day ?? 0
           let totalDays = calendar.dateComponents([.day], from: registeredDate, to: currentDate).day!
           let totalMonths = months + years * 12
           
           return (years: years, months: totalMonths, days: totalDays)
       }
    
}

public  func checkTopicNameValidation(topicName : Dictionary<String,String>)-> Bool
{
    let pattern = "[a-zA-Z0-9-_.~%]+"
    print(pattern)
    return true
}







