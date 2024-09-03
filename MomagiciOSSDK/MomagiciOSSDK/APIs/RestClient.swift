//
//  RestClient.swift
//  MomagiciOSSDK
//
//  Created by Amit on 13/06/21.
//

import Foundation
import UIKit
import AdSupport
import AppTrackingTransparency

protocol ResponseHandler  : AnyObject{
    func onSuccess()
    func onFailure()
}
// Define custom error types
enum DataConversionError: Error {
    case encodingFailed
}

enum DataError: Error {
    case noData
}
@objc public class RestAPI : NSObject
{
   
         static var   BASEURL = "https://aevents.izooto.com/app"
         static var   ENCRPTIONURL="https://cdn.izooto.com/app/app_"
         static var  IMPRESSION_URL="https://impr.izooto.com/imp";
         public static var   LOG = "MoMagic :"
         static var  EVENT_URL = "https://et.izooto.com/evt";
         static var  PROPERTIES_URL="https://prp.izooto.com/prp";
         static var  CLICK_URL="https://clk.izooto.com/clk";
         static  var LASTNOTIFICATIONCLICKURL="https://lci.izooto.com/lci";
         static  var LASTNOTIFICATIONVIEWURL="https://lim.izooto.com/lim";
         static let  LASTVISITURL="https://lvi.izooto.com/lvi";
         static var  EXCEPTION_URL="https://aerr.izooto.com/aerr";
         static var  SUBSCRIBER_URL="https://pp.izooto.com/idsyn";
         static let MEDIATION_IMPRESSION_URL = "https://med.dtblt.com/medi";
         static let MEDIATION_CLICK_URL = "https://med.dtblt.com/medc"
    //fallback url
         static var fallBackLandingUrl = ""
         static var fallBackTitle = ""
         static let SDKVERSION = "3.0.0"
    //Fallback
        static let FALLBACK_URL = "https://flbk.izooto.com/default.json"
     // MOMAGIC URL
        static var MOMAGIC_SUBSCRIPTION_URL="https://irctc.truenotify.in/momagicflow/appenp";
        static var MOMAGIC_USER_PROPERTY="https://irctc.truenotify.in/momagicflow/appup";
        static var MOMAGIC_CLICK="https://irctc.truenotify.in/momagicflow/appclk";
        static var MOMAGIC_IMPRESSION = "https://irctc.truenotify.in/momagicflow/appimpr"
        static var tag_name = "RestAPI"
        private static var clickStoreData: [[String:Any]] = []
        private static var mediationClickStoreData: [[String:Any]] = []
    
    
    
    //All notification Data
       static let ALL_NOTIFICATION_DATA = "https://nh.izooto.com/nh/"
       static var index = 0
       static var stopCalling = false
       static var lessData = 0
       

    // register the token on our panel
    @objc static func registerToken(token : String, pid : String)
    {
        if(token != "" && pid != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems =
            [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: "8"),
                URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: "3"),
                URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(currentTimeInMilliSeconds())"),
                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: "5"),
                URLQueryItem(name:AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: identifierForAdvertising()!),
                URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(getVersion())"),
                URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(getDeviceName())"),
                URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(getAppVersion())")
            ]
            var request = URLRequest(url: URL(string: RestAPI.BASEURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {

                    print(AppConstant.DEVICE_TOKEN,token)
                    UserDefaults.isRegistered(isRegister: true)
                    print(AppConstant.SUCESSFULLY)
                    let date = Date()
                    let format = DateFormatter()
                    format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                    let formattedDate = format.string(from: date)
                    if(formattedDate != (sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_LAST_VISIT)))
                    {
                        RestAPI.lastVisit(pid: pid, token:token)
                        sharedUserDefault?.set(formattedDate, forKey: AppConstant.iZ_KEY_LAST_VISIT)
                        let dicData = sharedUserDefault?.dictionary(forKey:AppConstant.iZ_USERPROPERTIES_KEY)
                        if(dicData != nil)
                        {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                DATB.addUserProperties(data: dicData!)
                            }
                        }
                    }
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "registerToken",  rid: "", cid: "")
                sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
            
        }
        
    }
    
    // register the token on our panel
    @objc static func registerTokenWithMomagic(token : String, pid : String)
    {
        if(token != "" && pid != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems =
            [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: "8"),
                URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: "3"),
                URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(currentTimeInMilliSeconds())"),
                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: "5"),
                URLQueryItem(name:AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: identifierForAdvertising()!),
                URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(getVersion())"),
                URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(getDeviceName())"),
                URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(getAppVersion())")
            ]
            var request = URLRequest(url: URL(string: RestAPI.MOMAGIC_SUBSCRIPTION_URL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {
                }
            }.resume()
        }
        else
        {
       
              Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR,className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
            
        }
        
    }
    
    
    // send the token with adID
    @objc static func registerToken(token : String, pid : String ,adid : NSString)
    {
        if(token != "" && pid != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems =
            [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: "8"),
                URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: "3"),
                URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(currentTimeInMilliSeconds())"),
                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: "5"),
                URLQueryItem(name:AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: identifierForAdvertising()!),
                URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(getVersion())"),
                URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(getDeviceName())"),
                URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(getAppVersion())")
            ]
            
            
            if let url = URL(string: RestAPI.BASEURL) {
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                URLSession.shared.dataTask(with: request){(data,response,error) in
                    do {
                        sharedUserDefault?.set(true,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                        sharedUserDefault?.set("", forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID_)
                    }
                }.resume()
            }
            else
            {
                sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                
                Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
            }
        } else
        {
            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")

        }
            
    }

    
    public static func getRequest(uuid: String, completionBlock: @escaping (String) -> Void) -> Void
        {
            if uuid != "" {
                if let requestURL = URL(string: "\(ENCRPTIONURL)\(uuid).dat"){
                    var request = URLRequest(url: requestURL)
                    request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
                    let config = URLSessionConfiguration.default
                    if #available(iOS 11.0, *) {
                        config.waitsForConnectivity = true
                    } else {
                        // Fallback on earlier versions
                    }
                    URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                        
                        if(error != nil) {
                            Utils.handleOnceException(exceptionName: error?.localizedDescription ?? "no found", className: tag_name, methodName: "getRequest", rid: "", cid: "")
                            print(AppConstant.IZ_TAG,AppConstant.APP_ID_ERROR)
                            
                        }else
                        {
                            if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200{
                                    
                                    do {
                                        if let data = data {
                                            guard let outputStr = String(data: data, encoding: .utf8) else {
                                                throw DataConversionError.encodingFailed
                                            }
                                            completionBlock(outputStr)
                                        } else {
                                            throw DataError.noData
                                        }
                                    } catch DataConversionError.encodingFailed {
                                        print("Failed to encode data to a string.")
                                        // Handle encoding error here
                                        completionBlock("Encoding error occurred.")
                                    } catch DataError.noData {
                                        print("No data received.")
                                        // Handle no data error here
                                        completionBlock("No data error occurred.")
                                    } catch {
                                        print("An unexpected error occurred: \(error.localizedDescription)")
                                        // Handle any other unexpected errors here
                                        completionBlock("Unexpected error occurred.")
                                    }
                                }
                                else
                                {
                                    Utils.handleOnceException(exceptionName: "response error generated\(uuid)", className: tag_name, methodName: "getRequest", rid: "", cid: "")
                                }
                            }
                        }
                    }.resume()
                }
            }else{
                Utils.handleOnceException(exceptionName: "Momagic  app id is blank or null", className: tag_name, methodName: "getRequest", rid: "", cid: "")
            }
        }

    @objc static func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    @objc static func getDeviceName()->String
    {
        let name = UIDevice.current.model
        return name
        
    }
    @objc static func getUUID()->String
    {
        if let device_id = UIDevice.current.identifierForVendor?.uuidString {
            return device_id
        } else {
            return "no device id"
        }

        
    }
    
    @objc static func  getVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    @objc static func getAppInfo() -> String {
        if let dictionary = Bundle.main.infoDictionary,
           let version = dictionary["CFBundleShortVersionString"] as? String,
           let build = dictionary["CFBundleVersion"] as? String {
            return version + "(" + build + ")"
        } else {
            return "Version information not available"
        }
    }
    @objc static func getAppName() -> String {
        if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return appName
        } else {
            return "App Name not available"
        }
    }
    @objc static func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    @objc static func getAppVersion() -> String {
        if let dictionary = Bundle.main.infoDictionary,
           let version = dictionary["CFBundleShortVersionString"] as? String {
            return "\(version)"
        } else {
            return "Version not available"
        }
    }
    
    
    // send event to server
      static func callEvents(eventName : String, data : NSString,pid : String,token : String)
      {
        if( eventName != "" && data != "" && pid != ""){
          let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
          var requestBodyComponents = URLComponents()
          requestBodyComponents.queryItems = [
                            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                            URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                            URLQueryItem(name: "act", value: "\(eventName)"),
                            URLQueryItem(name: "et", value: "evt"),
                            URLQueryItem(name: "val", value: "\(data)")
                            ]
          var request = URLRequest(url: URL(string: RestAPI.EVENT_URL)!)
          request.httpMethod = AppConstant.iZ_POST_REQUEST
          request.allHTTPHeaderFields = requestHeaders
          request.httpBody = requestBodyComponents.query?.data(using: .utf8)
          URLSession.shared.dataTask(with: request){(data,response,error) in
             
            do {
              sharedUserDefault?.set("", forKey:AppConstant.KEY_EVENT)
              sharedUserDefault?.set("", forKey: AppConstant.KEY_EVENT_NAME)
            }
          }.resume()
        }
        else{
            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
                        sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
        }
      }
    
    
    // send user properties to server
      static func callUserProperties( data : NSString,pid : String,token : String)
      {
        if( data != "" && pid != ""){
          let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
          var requestBodyComponents = URLComponents()
          requestBodyComponents.queryItems = [
                            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                            URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                            URLQueryItem(name: "act", value: "add"),
                            URLQueryItem(name: "et", value: "userp"),
                            URLQueryItem(name: "val", value: "\(data)")
                            ]
          var request = URLRequest(url: URL(string: RestAPI.PROPERTIES_URL)!)
          request.httpMethod = AppConstant.iZ_POST_REQUEST
          request.allHTTPHeaderFields = requestHeaders
          request.httpBody = requestBodyComponents.query?.data(using: .utf8)
          URLSession.shared.dataTask(with: request){(data,response,error) in
             
            do {
              sharedUserDefault?.set("", forKey:"UserPropertiesData")
              print(AppConstant.ADD_PROPERTIES)
            }
          }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
        }
      }
    
    
    
    // track the notification impression
        static func callImpression(notificationData : Payload,pid : String,token : String)
        {
            if notificationData.ankey != nil{
                if(notificationData.global?.rid != nil && pid != "" && token != "")
                {
                    let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                    var requestBodyComponents = URLComponents()
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                        URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                        URLQueryItem(name: "op", value: "view"),
                        URLQueryItem(name: "ver", value: SDKVERSION)
                    ]
                    
                    guard let url = URL(string: RestAPI.IMPRESSION_URL) else {
                        // Handle the case where the URL is nil
                        print("Error: Invalid URL")
                        return
                    }
                    var request = URLRequest(url: url)
                    request.httpMethod = AppConstant.iZ_POST_REQUEST
                    request.allHTTPHeaderFields = requestHeaders
                    request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                    let config = URLSessionConfiguration.default
                    if #available(iOS 11.0, *) {
                        config.waitsForConnectivity = true
                    } else {
                        // Fallback on earlier versions
                    }
                    URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                        
                        do {
                            if let error = error {
                                throw error
                            }
                            // Check the HTTP response status code
                            if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200 {
                                }else{
                                    
                                    Utils.handleOnceException(exceptionName:  "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")" , className: tag_name, methodName: "callImpression",  rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                                }
                            }
                        } catch {
                            Utils.handleOnceException(exceptionName:  "\(error.localizedDescription)" , className: tag_name, methodName: "callImpression", rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                        }
                    }.resume()
                }
                else
                {
                    Utils.handleOnceException(exceptionName:  "rid or cid value is  blank" , className: tag_name, methodName: "callImpression",  rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                }
            }else{
                if(notificationData.rid != nil && pid != "" && token != "")
                {
                    let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                    var requestBodyComponents = URLComponents()
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                        URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                        URLQueryItem(name: "op", value: "view"),
                        URLQueryItem(name: "ver", value: SDKVERSION)
                    ]
                    
                    guard let url = URL(string: RestAPI.IMPRESSION_URL) else {
                        // Handle the case where the URL is nil
                        print("Error: Invalid URL")
                        return
                    }
                    var request = URLRequest(url: url)
                    request.httpMethod = AppConstant.iZ_POST_REQUEST
                    request.allHTTPHeaderFields = requestHeaders
                    request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                    let config = URLSessionConfiguration.default
                    if #available(iOS 11.0, *) {
                        config.waitsForConnectivity = true
                    } else {
                        // Fallback on earlier versions
                    }
                    URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                        
                        do {
                            if let error = error {
                                throw error
                            }
                            // Check the HTTP response status code
                            if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200 {
                                    
                                }else{
                                    Utils.handleOnceException(exceptionName:  error?.localizedDescription ?? "Error code " , className: tag_name, methodName: "callImpression",rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                                    
                                }
                            }
                        } catch let error {
                            Utils.handleOnceException(exceptionName:  error.localizedDescription, className: tag_name, methodName: "callImpression",  rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                        }
                    }.resume()
                }
                else
                {
                    Utils.handleOnceException(exceptionName:  "rid or cid value is blank" , className: tag_name, methodName: "callImpression",  rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                }
            }
        }
    @objc static func callMoMagicImpression(notificationData : Payload,pid : String,token : String)
    
    {
        if notificationData.ankey != nil{
            if(notificationData.global?.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id!))"),
                    URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid!))"),
                    URLQueryItem(name: "op", value: "view"),
                    URLQueryItem(name: "ver", value: SDKVERSION)
                ]
                var request = URLRequest(url: URL(string: "\(RestAPI.MOMAGIC_IMPRESSION)")!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                URLSession.shared.dataTask(with: request){(data,response,error) in

                    do {
                        // print("imp","success")
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
            }
        }else{
            if(notificationData.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                    URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                    URLQueryItem(name: "op", value: "view"),
                    URLQueryItem(name: "ver", value: SDKVERSION)
                ]
                var request = URLRequest(url: URL(string: "\(RestAPI.IMPRESSION_URL)")!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                URLSession.shared.dataTask(with: request){(data,response,error) in

                    do {
                        // print("imp","success")
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
                            sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
            }
        }
        
    }
    
    // track the notification click
        static func clickTrack(notificationData : Payload,type : String, pid : String,token : String, userInfo:[AnyHashable : Any], globalLn: String, title: String)
        {
            var clickLn = ""
            if globalLn == ""{
                clickLn = notificationData.url ?? ""
            }else{
                clickLn = globalLn
            }

            if let encodedURLString = clickLn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                clickLn = encodedURLString
            }
            
                
            if notificationData.ankey != nil{
                if(notificationData.global?.rid != nil && pid != "" && token != "")
                {
                    let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                    var requestBodyComponents = URLComponents()
                    
                    if type != "0"{
                        requestBodyComponents.queryItems = [
                            URLQueryItem(name: "btn", value: "\(type)"),
                            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                            URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                            URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                            URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                            URLQueryItem(name: "op", value: "click"),
                            URLQueryItem(name: "ver", value: SDKVERSION),
                            URLQueryItem(name: "ln", value: "\(clickLn)"),
                            URLQueryItem(name: "ap", value: ""),
                            URLQueryItem(name:"ti",value: "\(title)")
                            
                        ]
                    }else{
                        requestBodyComponents.queryItems = [
                            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                            URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                            URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                            URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                            URLQueryItem(name: "ti", value: "\(title)"),
                            URLQueryItem(name: "op", value: "click"),
                            URLQueryItem(name: "ver", value: SDKVERSION),
                            URLQueryItem(name: "ln", value: "\(clickLn)"),
                            URLQueryItem(name: "ap", value: ""),
                        ]
                    }
                   
                    guard let url = URL(string: RestAPI.CLICK_URL) else {
                        // Handle the case where the URL is nil
                        print("Error: Invalid URL")
                        return
                    }
                    var request = URLRequest(url: url)
                    request.httpMethod = AppConstant.iZ_POST_REQUEST
                    request.allHTTPHeaderFields = requestHeaders
                    request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                    URLSession.shared.dataTask(with: request){(data,response,error) in
                        do {
                            if let error = error {
                                throw error
                            }
                            // Check the HTTP response status code
                            if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200 {
                                    RestAPI.clickTrackWithMoMagic(notificationData: notificationData, type: type, pid: pid, token: token)
                                           
                                }else{
                                    Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")" , className: tag_name, methodName: "clickTrack", rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                                }
                            }
                        } catch let error{
                        
                            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
                                    sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                        }
                    }.resume()
                }
                else
                {
                    Utils.handleOnceException(exceptionName: "rid or cid value is blank" , className: tag_name, methodName: "clickTrack",  rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                }
            }else{
                if(notificationData.rid != nil && pid != "" && token != "")
                {
                    let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                    var requestBodyComponents = URLComponents()
                    
                    
                    if type != "0"{
                        requestBodyComponents.queryItems = [
                            URLQueryItem(name: "btn", value: "\(type)"),
                            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                            URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                            URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                            URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                            URLQueryItem(name: "op", value: "click"),
                            URLQueryItem(name: "ver", value: SDKVERSION),
                            URLQueryItem(name: "ln", value: "\(clickLn)"),
                            URLQueryItem(name: "ti", value: "\(title)"),
                        ]
                    }else{
                        requestBodyComponents.queryItems = [
                            URLQueryItem(name: "ti", value: "\(title)"),
                            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                            URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                            URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                            URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                            URLQueryItem(name: "op", value: "click"),
                            URLQueryItem(name: "ver", value: SDKVERSION),
                            URLQueryItem(name: "ln", value: "\(clickLn)"),
                            URLQueryItem(name: "ap", value: "\(String(describing: notificationData.ap ?? ""))"),

                        ]
                    }
                   
                    guard let url = URL(string: RestAPI.CLICK_URL) else {
                        // Handle the case where the URL is nil
                        print("Error: Invalid URL")
                        return
                    }
                    var request = URLRequest(url: url)
                    request.httpMethod = AppConstant.iZ_POST_REQUEST
                    request.allHTTPHeaderFields = requestHeaders
                    request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                    URLSession.shared.dataTask(with: request){(data,response,error) in
                        
                        do {
                            if let error = error {
                                throw error
                            }
                            // Check the HTTP response status code
                            if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200 {
                                }else{
                                    Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "clickTrack", rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                                }
                            }
                        } catch let error{
                    
                            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
                                        sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                            
                        }
                    }.resume()
                }
                else
                {
                    Utils.handleOnceException(exceptionName: "rid or cid value is blank", className: tag_name, methodName: "clickTrack", rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                    
                }
            }
        }
    
    //set subscriptionID
    static func setSubscriberID(subscriberID : String, pid : String,token : String)
    {
        if(subscriberID != "" && pid != "" && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "operation", value: "add_property"),
                URLQueryItem(name: "name", value: "subscriber_id"),
                URLQueryItem(name: "value", value: subscriberID),

                URLQueryItem(name: "ver", value: SDKVERSION),
                URLQueryItem(name: "btype", value: "8"),
                URLQueryItem(name: "pt", value: "1")
            ]
            var request = URLRequest(url: URL(string: RestAPI.SUBSCRIBER_URL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {
                    sharedUserDefault?.set(subscriberID, forKey: SharedUserDefault.Key.subscriberID)
                    setSubscriberIDWithMoMagic(subscriberID : subscriberID, pid : pid,token : token)
                }
            }.resume()
        }
        else
        {
            sharedUserDefault?.set(subscriberID, forKey: SharedUserDefault.Key.subscriberID)
            Utils.handleOnceException(exceptionName: "subscriberID should not be blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "setSubscriberID",  rid: "", cid: "")
        }
    }
    
    //MoMagic set subscriptionID
    static func setSubscriberIDWithMoMagic(subscriberID : String, pid : String,token : String){
        if(subscriberID != "" && pid != "" && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "operation", value: "add_property"),
                URLQueryItem(name: "name", value: "subscriber_id"),
                URLQueryItem(name: "value", value: subscriberID),
                URLQueryItem(name: "ver", value: SDKVERSION),
                URLQueryItem(name: "btype", value: "8"),
                URLQueryItem(name: "pt", value: "1")
            ]
            var request = URLRequest(url: URL(string: RestAPI.MOMAGIC_USER_PROPERTY)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {
                     // print("Added Subscriber ID")
                }
            }.resume()
        }
        else
        {
           
            Utils.handleOnceException(exceptionName: "subscriberID should not be blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "setSubscriberID",  rid: "", cid: "")
        }
    }
    
    
    //MoMagic click track
    static func clickTrackWithMoMagic(notificationData : Payload,type : String, pid : String,token : String)
    {
        if notificationData.ankey != nil{
            if(notificationData.global?.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id!))"),
                    URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid!))"),
                    URLQueryItem(name: "op", value: "click"),
                    URLQueryItem(name: "ver", value: SDKVERSION),
                    URLQueryItem(name: "btn", value: "\(type)")
                ]
                var request = URLRequest(url: URL(string: RestAPI.MOMAGIC_CLICK)!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                URLSession.shared.dataTask(with: request){(data,response,error) in
                    do {
                        
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
            }
        }else{
            if(notificationData.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                    URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                    URLQueryItem(name: "op", value: "click"),
                    URLQueryItem(name: "ver", value: SDKVERSION),
                    URLQueryItem(name: "btn", value: "\(type)")
                ]
                var request = URLRequest(url: URL(string: RestAPI.MOMAGIC_CLICK)!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                URLSession.shared.dataTask(with: request){(data,response,error) in
                    do {
                    }
                }.resume()
            }
            else
            {
                
                Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
                            sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                
                
            }
        }
    }
    
    
    
    @objc public static func performRequest(with urlString : String)
    {
        if let url = URL(string: urlString)
        {
            let session = URLSession(configuration: .default)
            let task  = session.dataTask(with: url)
            {(data,response,error)in
                if error != nil
                {
                    print(AppConstant.FAILURE)
                    return
                }
                if data != nil{
                    print(AppConstant.SUCESS)
                }
                
            }
            task.resume()
        }
    }
    
    @objc public static func identifierForAdvertising() -> String? {
        if #available(iOS 14, *) {
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return "0000-0000-0000-0000"
            }
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        else {
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return "0000-0000-0000-0000"
            }
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
    }
    
    
   
    // last visit data send to server
        @objc static func lastVisit(pid : String,token : String)
        {
            if(token != "" && pid != "")
            {
                let data = ["last_website_visit":"true","lang":"en"] as [String:String]
                if let theJSONData = try?  JSONSerialization.data(withJSONObject: data,options: .fragmentsAllowed),
                   let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue) {
                    let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                    var requestBodyComponents = URLComponents()
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "act", value: "add"),
                        URLQueryItem(name: "isid", value: "1"),
                        URLQueryItem(name: "et", value: "userp"),
                        URLQueryItem(name: "val", value: "\(validationData)")
                    ]
                    
                    guard let url = URL(string: RestAPI.LASTVISITURL) else {
                        // Handle the case where the URL is nil
                        print("Error: Invalid URL")
                        return
                    }
                    var request = URLRequest(url: url)
                    request.httpMethod = AppConstant.iZ_POST_REQUEST
                    request.allHTTPHeaderFields = requestHeaders
                    request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                    let config = URLSessionConfiguration.default
                    if #available(iOS 11.0, *) {
                        config.waitsForConnectivity = true
                    } else {
                        // Fallback on earlier versions
                    }
                    URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                        
                        do {
                            if let error = error {
                                throw error
                            }
                            // Check the HTTP response status code
                            if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200 {
                                    print("last visit")
                                    
                                }else{
                                    Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "lastVisit" , rid: "",cid :"")
                                }
                            }
                        } catch {
                            Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: tag_name, methodName: "lastVisit" , rid: "",cid :"")
                        }
                    }.resume()
                }
                else
                {
                    Utils.handleOnceException(exceptionName: "json is not correct", className: tag_name, methodName: "lastVisit" , rid: "",cid :"")
                }
            }
            else
            {
                Utils.handleOnceException(exceptionName: "pid is not found", className: tag_name, methodName: "lastVisit" , rid: "",cid :"")
            }
        }





    // last impression send to server
    @objc  static func lastImpression(notificationData : Payload,pid : String,token : String)
    {
        if(notificationData != nil && pid != "" && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                URLQueryItem(name: "op", value: "view")
            ]
            var request = URLRequest(url: URL(string: RestAPI.LASTNOTIFICATIONVIEWURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                   // print("l","i")
                }
            }.resume()
        }
        else
        {
            
            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
        }
        
    }
    
    // last click data send to server
    @objc  static func lastClick(notificationData : Payload,pid : String,token : String)
    {
        if(pid != "" && token != "" && notificationData != nil)
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                URLQueryItem(name: "op", value: "view")
            ]
            var request = URLRequest(url: URL(string: RestAPI.LASTNOTIFICATIONCLICKURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                   // print("l","c")
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
        }
    }
    

    // send exception to the server
        @objc static func sendExceptionToServer(exceptionName: String, className: String, methodName: String,rid: String, cid: String, appId: String) {
             let pid = Utils.getUserId() ?? ""
             let token = Utils.getUserDeviceToken() ?? ""
            let requestHeaders: [String: String] = [AppConstant.iZ_CONTENT_TYPE: AppConstant.iZ_CONTENT_TYPE_VALUE]
            
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: "pid", value: pid),
                URLQueryItem(name: "appId", value: appId),// need to add moamgic app id
                URLQueryItem(name: "exceptionName", value: exceptionName),
                URLQueryItem(name: "methodName", value: methodName),
                URLQueryItem(name: "className", value: className),
                URLQueryItem(name: "bKey", value: token),
                URLQueryItem(name: "av", value: SDKVERSION),
                URLQueryItem(name: "rid", value: rid),
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "osVersion", value: Utils.getVersion()),
                URLQueryItem(name: "deviceName", value: Utils.getDeviceName()),
                URLQueryItem(name: "appVersion", value: Utils.getAppVersion())
            ]
            guard let url = URL(string: RestAPI.EXCEPTION_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            
            URLSession(configuration: config).dataTask(with: request) { data, response, error in
                do {
                    if let error = error {
                        throw error
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                        } else {
                            throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: nil)
                        }
                    }
                } catch {
                    print("Failed to send exception to server: \(error)")
                }
            }.resume()
        }


    //Ad-Mediation Impression
       @objc  static func callAdMediationImpressionApi(finalDict: NSDictionary){
           
           if (finalDict.count != 0) {
               let jsonData = try? JSONSerialization.data(withJSONObject: finalDict as? [String: Any])
               // create post request
               let url = URL(string: "\(MEDIATION_IMPRESSION_URL)")!
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               
               // insert json data to the request
               request.httpBody = jsonData
               request.addValue("application/json", forHTTPHeaderField: "\(AppConstant.iZ_CONTENT_TYPE)")
               request.addValue("application/json", forHTTPHeaderField: "Accept")
               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   guard let data = data, error == nil else {
                       print(error?.localizedDescription ?? "No data")
                       return
                   }
                   let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                   if let responseJSON = responseJSON as? [String: Any] {
                   }
               }
               task.resume()
           }else{
               Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
           }
       }
       
       
       //Ad-Mediation ClickAPI
       @objc  static func callAdMediationClickApi(finalDict: NSDictionary){
           
           if (finalDict.count != 0) {
               let jsonData = try? JSONSerialization.data(withJSONObject: finalDict)
               
               // create post request
               let url = URL(string: "\(MEDIATION_CLICK_URL)")!
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               
               // insert json data to the request
               request.httpBody = jsonData
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
               request.addValue("application/json", forHTTPHeaderField: "Accept")
               
               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   guard let data = data, error == nil else {
                       print(error?.localizedDescription ?? "No data")
                       return
                   }
                   let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                   if let responseJSON = responseJSON as? [String: Any] {
                   }
               }
               task.resume()
               
           }else{
               Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-mediation Click API",  rid: "", cid: "")
                           sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
           }
       }
       
       
       static func callRV_RC_Request( urlString : String)
       {
           let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
           let session = URLSession.shared
           request.httpMethod = "GET"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")

           let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                 if error != nil {
                     debugPrint("Error: \(AppConstant.FAILURE)")
                 } else {
                     debugPrint("Response: \(AppConstant.SUCESS)")
                 }
            })

            task.resume()
       }
       
    // last impression send to server
        @objc static func lastImpression(notificationData : Payload,pid : String,token : String,url : String)
        {
            if(notificationData.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                    URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                    URLQueryItem(name: "op", value: "view")
                ]
                guard let url = URL(string: url) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                let config = URLSessionConfiguration.default
                if #available(iOS 11.0, *) {
                    config.waitsForConnectivity = true
                } else {
                    // Fallback on earlier versions
                }
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                
                            }else{
                                Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                            }
                        }
                    } catch {
                        Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName: "rid value is blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
            }
        }
    
    
    
    

    // last click data send to server
        @objc static func lastClick(notificationData : Payload,pid : String,token : String,url : String, userInfo: [AnyHashable: Any])
        {
            if(pid != "" && token != "" && notificationData.rid != nil)
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                    URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                    URLQueryItem(name: "op", value: "view")
                ]
                
                guard let url = URL(string: url) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                let config = URLSessionConfiguration.default
                if #available(iOS 11.0, *) {
                    config.waitsForConnectivity = true
                } else {
                    // Fallback on earlier versions
                }
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                            }else{
                                Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                            }
                        }
                        
                    } catch {
                        Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName: "rid value is blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
            }
        }
    static func fallbackClickTrack(title : String, landingUrl : String,rid :String, cid : String)
       {
           
           let pid = Utils.getUserId() ?? ""
           let token = Utils.getUserDeviceToken() ?? ""
          
               if(rid != "" && cid != "")
               {
                   let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                   var requestBodyComponents = URLComponents()
                   requestBodyComponents.queryItems = [
                           URLQueryItem(name: "ti", value: title),
                           URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                           URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                           URLQueryItem(name: "cid", value: cid),
                           URLQueryItem(name: "rid", value: rid),
                           URLQueryItem(name: "op", value: "click"),
                           URLQueryItem(name: "ver", value: SDKVERSION),
                           URLQueryItem(name: "ln", value: landingUrl),
                           
                       ]
                   
                   guard let url = URL(string: RestAPI.CLICK_URL) else {
                       // Handle the case where the URL is nil
                       print("Error: Invalid URL")
                       return
                   }
                   var request = URLRequest(url: url)
                   request.httpMethod = AppConstant.iZ_POST_REQUEST
                   request.allHTTPHeaderFields = requestHeaders
                   request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                   URLSession.shared.dataTask(with: request){(data,response,error) in
                       
                       do {
                           if let error = error {
                               throw error
                           }
                           // Check the HTTP response status code
                           if let httpResponse = response as? HTTPURLResponse {
                               if httpResponse.statusCode == 200 {
                               }else{
                                   Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "clickTrack", rid: rid ?? "no rid value here", cid: cid ?? "no cid value here")
                               }
                           }
                       } catch let error{
                           Utils.handleOnceException(exceptionName: "\(error.localizedDescription ?? "")", className: tag_name, methodName: "clickTrack", rid: rid ?? "no rid value here", cid: cid ?? "no cid value here")
                           
                       }
                   }.resume()
               }
               else
               {
                   Utils.handleOnceException(exceptionName: "rid or cid value is blank", className: tag_name, methodName: "clickTrack", rid: rid ?? "no rid value here", cid: cid ?? "no cid value here")
                   
               }
           
       }
    // All Notification Data
       @objc static func fetchDataFromAPI(isPagination: Bool,iZPID: String,completion: @escaping (String?, Error?) -> Void) {
           
           if isPagination == false{
               index = 0
           }
           if index > 4{
               completion("No more data",nil)
               return
           }
           var arrayOfDictionaries : [[String: Any]] = []
           let sID = iZPID.sha1()
           let url = URL(string: RestAPI.ALL_NOTIFICATION_DATA+"\(sID)/\(index).json")
           guard let requestUrl = url else { fatalError() }
           var request = URLRequest(url: requestUrl)
           request.httpMethod = "GET"
           
           let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
               if let error = error {
                   debugPrint("\(error)")
                   completion("No more data", nil)
                   return
               }
               // Convert HTTP Response Data to a String
               if let data = data {
                   do {
                       let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                       if let jsonArray = jsonResponse as? NSArray {
                           for data in jsonArray {
                               if let dictDa = data as? NSDictionary {
                                   let allData = dictDa.value(forKey: AppConstant.iZ_P_KEY) as? NSDictionary
                                   let title = allData?.value(forKey: AppConstant.iZ_T_KEY) ?? ""
                                   let message = allData?.value(forKey: AppConstant.iZ_M_KEY) ?? ""
                                   let image = allData?.value(forKey: AppConstant.iZ_BI_KEY) ?? ""
                                   let time = allData?.value(forKey: AppConstant.iZ_CT_KEY) ?? ""
                                   let ln = allData?.value(forKey: AppConstant.iZ_LNKEY) ?? ""
                                   let dictionary1: [String: Any] = ["title": title, "message": message, "banner_image": image, "time_stamp": time,"landing_url": ln]
                                   arrayOfDictionaries.append(dictionary1)
                               }
                           }
                       }
                       
                       if arrayOfDictionaries.count != 15{
                           if lessData == 1{
                               stopCalling = true
                           }
                           lessData = 1
                           index = index
                       }else{
                           lessData = 0
                           stopCalling = false
                           index = index + 1
                       }
                       
                       if stopCalling == false{
                           let jsonData = try JSONSerialization.data(withJSONObject: arrayOfDictionaries, options: .prettyPrinted)
                           if let jsonString = String(data: jsonData, encoding: .utf8) {
                               completion(jsonString, nil)
                               return
                           }
                       }else{
                           completion("No more data", nil)
                           return
                       }
                   }
                   catch _
                   {
                       completion("No more data", nil)
                       return
                       
                   }
               }
           }
           task.resume()
       }
  
  
}

