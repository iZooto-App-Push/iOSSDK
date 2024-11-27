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
         static let SDKVERSION = "3.0.2"
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
    @objc static func registerToken(bundleName: String,token : String, pid : String)
       {
           if(token != "" && pid != "")
           {
               let defaults = UserDefaults.standard
               defaults.setValue(pid, forKey: AppConstant.REGISTERED_ID)
               defaults.setValue(token, forKey: "token")
               let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
               var requestBodyComponents = URLComponents()
               let queryParameters: [(String, String?)] = [
                   (AppConstant.iZ_KEY_PID, "\(pid)"),
                   (AppConstant.iZ_KEY_BTYPE, "8"),
                   (AppConstant.iZ_KEY_DTYPE, "3"),
                   (AppConstant.iZ_KEY_TIME_ZONE, "\(Utils.currentTimeInMilliSeconds())"),
                   (AppConstant.iZ_KEY_SDK_VERSION, "\(Utils.getAppVersion())"),
                   (AppConstant.iZ_KEY_OS, "5"),
                   (AppConstant.iZ_KEY_DEVICE_TOKEN, token),
                   (AppConstant.iZ_KEY_APP_SDK_VERSION, SDKVERSION),
                   (AppConstant.iZ_KEY_ADID, identifierForAdvertising()),
                   (AppConstant.iZ_DEVICE_OS_VERSION, "\(Utils.getVersion())"),
                   (AppConstant.iZ_DEVICE_NAME, "\(Utils.getDeviceName())"),
                   (AppConstant.iZ_KEY_CHECK_VERSION, "\(Utils.getAppVersion())")
                  
               ]

               requestBodyComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.0, value: $0.1) }
               
               guard let url = URL(string: RestAPI.BASEURL) else {
                   // Handle the case where the URL is nil
                   print("Error: Invalid URL")
                   return
               }
               var request = URLRequest(url: url)
               request.httpMethod = AppConstant.iZ_POST_REQUEST
               request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")
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
                               print(AppConstant.DEVICE_TOKEN,token)
                               UserDefaults.isRegistered(isRegister: true)
                               print(AppConstant.SUCESSFULLY)
                               
                               let currentUnixTimestamp: TimeInterval = TimeInterval(Int(Date().timeIntervalSince1970 * 1000))
                               if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){//used in addMacros
                                   userDefaults.setValue(currentUnixTimestamp, forKey: "unixTS")
                               }
                               let date = Date()
                               let format = DateFormatter()
                               format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                               let formattedDate = format.string(from: date)
                               if(formattedDate != (sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_LAST_VISIT)))
                               {
                                   RestAPI.lastVisit(bundleName: bundleName, pid: pid, token:token)
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
                       }
                   } catch {
                       Utils.handleOnceException(bundleName : bundleName ,exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: nil, cid: nil, userInfo: nil)
                   }
               }.resume()
           }
           else
           {
               print("pid or token is empty or invalid")
           }
       }
    // register the token on our panel
    @objc static func registerTokenWithMomagic(bundleName: String,token : String, pid : String)
    {
        if(token != "" && pid != "")
        {
            let defaults = UserDefaults.standard
            defaults.setValue(pid, forKey: AppConstant.REGISTERED_ID)
            defaults.setValue(token, forKey: "token")
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            let queryParameters: [(String, String?)] = [
                (AppConstant.iZ_KEY_PID, "\(pid)"),
                (AppConstant.iZ_KEY_BTYPE, "8"),
                (AppConstant.iZ_KEY_DTYPE, "3"),
                (AppConstant.iZ_KEY_TIME_ZONE, "\(Utils.currentTimeInMilliSeconds())"),
                (AppConstant.iZ_KEY_SDK_VERSION, "\(Utils.getAppVersion())"),
                (AppConstant.iZ_KEY_OS, "5"),
                (AppConstant.iZ_KEY_DEVICE_TOKEN, token),
                (AppConstant.iZ_KEY_APP_SDK_VERSION, SDKVERSION),
                (AppConstant.iZ_KEY_ADID, identifierForAdvertising()),
                (AppConstant.iZ_DEVICE_OS_VERSION, "\(Utils.getVersion())"),
                (AppConstant.iZ_DEVICE_NAME, "\(Utils.getDeviceName())"),
                (AppConstant.iZ_KEY_CHECK_VERSION, "\(Utils.getAppVersion())")
               
            ]

            requestBodyComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.0, value: $0.1) }
            
            guard let url = URL(string: RestAPI.MOMAGIC_SUBSCRIPTION_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")
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
                            
                        }
                    }
                } catch {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: nil, cid: nil, userInfo: nil)
                }
            }.resume()
        }
       
        
    }
    
    
    // send the token with adID
    @objc static func registerToken(bundleName: String,token : String, pid : String ,adid : NSString)
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
                request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")
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
              
            }
        }
            
    }

    
    public static func getRequest(bundleName : String, uuid: String, completionBlock: @escaping (String) -> Void) -> Void
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
                              Utils.handleOnceException(bundleName:bundleName , exceptionName: error?.localizedDescription ?? "no found", className: tag_name, methodName: "getRequest", rid: "", cid: "", userInfo: nil)
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
                                      Utils.handleOnceException(bundleName: bundleName, exceptionName: "response error generated\(uuid)", className: tag_name, methodName: "getRequest", rid: "", cid: "", userInfo: nil)
                                  }
                              }
                          }
                      }.resume()
                  }
              }else{
                  Utils.handleOnceException(bundleName: bundleName, exceptionName: "Momagic  app id is blank or null", className: tag_name, methodName: "getRequest", rid: "", cid: "", userInfo: nil)
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
          request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")
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
           
            sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
        }
      }
    
    
    // send user properties to server
    static func callUserProperties(bundleName : String, data : NSString,pid : String,token : String)
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
          request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")

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
            Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "", userInfo: nil)
        }
      }
    
    
    
    // track the notification impression
    static func callImpression(notificationData : Payload,pid : String,token : String,bundleName : String, isSilentPush: Bool, userInfo: [AnyHashable : Any]?)
       {
           var cid: String? = nil
           var rid: String? = nil
           if notificationData.ankey != nil{
               cid = notificationData.global?.id ?? nil
               rid = notificationData.global?.rid ?? nil
           }else{
               cid = notificationData.id ?? nil
               rid = notificationData.rid ?? nil
           }
           if(rid != nil && pid != "" && token != ""){
               let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
               var requestBodyComponents = URLComponents()
               requestBodyComponents.queryItems = [
                   URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                   URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                   URLQueryItem(name: "cid", value: cid),
                   URLQueryItem(name: "rid", value: rid),
                   URLQueryItem(name: "op", value: "view"),
                   URLQueryItem(name: "ver", value: SDKVERSION)
               ]
               if isSilentPush {
                   requestBodyComponents.queryItems?.append(URLQueryItem(name: "sn", value: "1"))
               }
               
               guard let url = URL(string: RestAPI.IMPRESSION_URL) else {
                   // Handle the case where the URL is nil
                   print("Error: Invalid URL")
                   return
               }
               var request = URLRequest(url: url)
               request.httpMethod = AppConstant.iZ_POST_REQUEST
               request.allHTTPHeaderFields = requestHeaders
               request.setValue(bundleName, forHTTPHeaderField: "referrer")
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
                           }
                       }
                   } catch let error {
                       Utils.handleOnceException(bundleName: bundleName, exceptionName:  error.localizedDescription, className: tag_name, methodName: "callImpression",  rid: rid, cid: cid, userInfo: userInfo)
                   }
               }.resume()
           }
           else{
               print("Kindly check pid or token is empty")
           }
       }
    
    // momagic impression  api
    @objc static func callMoMagicImpression(notificationData : Payload,pid : String,token : String,bundleName : String, isSilentPush: Bool, userInfo: [AnyHashable : Any]?)
    
    {
        var cid: String? = nil
        var rid: String? = nil
        if notificationData.ankey != nil{
            cid = notificationData.global?.id ?? nil
            rid = notificationData.global?.rid ?? nil
        }else{
            cid = notificationData.id ?? nil
            rid = notificationData.rid ?? nil
        }
        if(rid != nil && pid != "" && token != ""){
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "rid", value: rid),
                URLQueryItem(name: "op", value: "view"),
                URLQueryItem(name: "ver", value: SDKVERSION)
            ]
          
            
            guard let url = URL(string: RestAPI.MOMAGIC_IMPRESSION) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.setValue(bundleName, forHTTPHeaderField: "referrer")
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
                            print("MoMagic impression Successfully ")
                        }
                    }
                } catch let error {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName:  error.localizedDescription, className: tag_name, methodName: "callImpression",  rid: rid, cid: cid, userInfo: userInfo)
                }
            }.resume()
        }
       
        
    }
    
    // track the notification click
    static func clickTrack(bundleName : String,notificationData : Payload,type : String, pid : String,token : String, userInfo:[AnyHashable : Any], globalLn: String, title: String)
        {
            var clickLn = ""
                    let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~#[]@!$'()*+,;")  //-> /:?&
                    if globalLn == ""{
                        clickLn = notificationData.url ?? ""
                        clickLn = clickLn.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
                    }else{
                        clickLn = globalLn.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
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
                    request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")

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

                                    RestAPI.clickTrackWithMoMagic(bundleName: bundleName, notificationData: notificationData, type: type, pid: pid, token: token, userInfo: userInfo, globalLn: globalLn, title: title)
                                           
                                }
                            }
                        } catch let error{
                        
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "", userInfo: userInfo)
                                    sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                        }
                    }.resume()
                }
                else
                {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid or cid value is blank" , className: tag_name, methodName: "clickTrack",  rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here", userInfo: userInfo)
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
                            URLQueryItem(name: "ap", value: "\(String(describing: notificationData.ap ?? ""))"),
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
                    request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")

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
                                    RestAPI.clickTrackWithMoMagic(bundleName: bundleName, notificationData: notificationData, type: type, pid: pid, token: token, userInfo: userInfo, globalLn: globalLn, title: title)
                                   
                                }
                            }
                        } catch let error{
                    
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "", userInfo: userInfo)
                                        sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                            
                        }
                    }.resume()
                }
                else
                {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid or cid value is blank", className: tag_name, methodName: "clickTrack", rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here", userInfo: userInfo)
                    
                }
            }
        }
    
    //set subscriptionID
    static func setSubscriberID(bundleName : String ,subscriberID : String, pid : String,token : String)
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
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")

            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {
                    sharedUserDefault?.set(subscriberID, forKey: SharedUserDefault.Key.subscriberID)
                    setSubscriberIDWithMoMagic(bundleName : bundleName ,subscriberID : subscriberID, pid : pid,token : token)
                }
            }.resume()
        }
        else
        {
            sharedUserDefault?.set(subscriberID, forKey: SharedUserDefault.Key.subscriberID)
            print("Subscriber id is empty or blank")
        }
    }
    
    //MoMagic set subscriptionID
    static func setSubscriberIDWithMoMagic(bundleName : String,subscriberID : String, pid : String,token : String){
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
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")

            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {
                     // print("Added Subscriber ID")
                }
            }.resume()
        }
       
    }
    
    
    //MoMagic click track
    static func clickTrackWithMoMagic(bundleName : String,notificationData : Payload,type : String, pid : String,token : String, userInfo:[AnyHashable : Any], globalLn: String, title: String)
    {
        var clickLn = ""
                let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~#[]@!$'()*+,;")  //-> /:?&
                if globalLn == ""{
                    clickLn = notificationData.url ?? ""
                    clickLn = clickLn.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
                }else{
                    clickLn = globalLn.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
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
               
                guard let url = URL(string: RestAPI.MOMAGIC_CLICK) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")

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
                                print("Click  Successfully ")

                              
                                       
                            }
                        }
                    } catch let error{
                    
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "", userInfo: userInfo)
                                sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                    }
                }.resume()
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
               
                guard let url = URL(string: RestAPI.MOMAGIC_CLICK) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")

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
                               
                            }
                        }
                    } catch let error{
                
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "", userInfo: userInfo)
                                    sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                        
                    }
                }.resume()
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
    @objc static func lastVisit(bundleName : String,pid : String,token : String)
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
                    request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")

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
                                    
                                }
                            }
                        } catch {
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: tag_name, methodName: "lastVisit" , rid: "",cid :"", userInfo: nil)
                        }
                    }.resume()
                }
               
            }
            else
            {
                print("pid or token is not available")
            }
        }

    // send exception to the server
    @objc static func sendExceptionToServer(bundleName : String ,exceptionName: String, className: String, methodName: String, rid: String?, cid: String?, appId: String, userInfo: [AnyHashable: Any]?) {
           // Retrieve app and device details
           let appDetails = AppManager.shared.appDetails
           let deviceDetails = AppManager.shared.deviceInfo
           let pid = Utils.getUserId(bundleName: bundleName) ?? ""
           let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
           let currentDate = Date()
           let currentTimeStamp = Int(currentDate.timeIntervalSince1970)
           
           // Create the JSON payload
           let exceptionDetails: [String: Any?] = [
               "name": exceptionName,
               "className": className,
               "method": methodName,
               "createdTime": "\(currentTimeStamp)",
               "cid": cid,
               "rid": rid,
               "notification": userInfo
           ]

           let filteredExceptionDetails = exceptionDetails.compactMapValues { $0 }

           let requestBody: [String: Any] = [
               "deviceDetails": [
                   "os": deviceDetails.os,
                   "name": deviceDetails.name,
                   "build": deviceDetails.build,
                   "version": deviceDetails.version,
                   "deviceID": deviceDetails.deviceID
               ],
               "appDetails": [
                   "name": appDetails.name,
                   "version": appDetails.version,
                   "bundleID": appDetails.bundleId,
               ],
               "sdkDetails": [
                   "pid": pid,
                   "version": SDKVERSION,
                   "appId": appId,
                   "bKey": token,
                   "pv": ""
               ],
               "exceptionDetails": filteredExceptionDetails
           ]

           
           // Convert the dictionary to JSON data
           guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
               print("Error: Could not serialize JSON request body")
               return
           }
           
           // Prepare the URL and request headers
           guard let url = URL(string: RestAPI.EXCEPTION_URL) else {
               print("Error: Invalid URL")
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = AppConstant.iZ_POST_REQUEST
           request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.httpBody = jsonData
           // Create the URL session configuration
           let config = URLSessionConfiguration.default
           config.waitsForConnectivity = true
           
           // Send the request
           URLSession(configuration: config).dataTask(with: request) { data, response, error in
               do {
                   if let error = error {
                       throw error
                   }
                   
                   if let httpResponse = response as? HTTPURLResponse {
                       if httpResponse.statusCode == 200 {
                           print("Exception sent successfully to server")
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
    @objc static func callAdMediationImpressionApi(finalDict: NSDictionary, bundleName: String, userInfo: [AnyHashable : Any]?){
           
           let defaults = UserDefaults.standard
           
           if (finalDict.count != 0) {
               let rid = finalDict.value(forKey: "rid") as? String
               let jsonData = try? JSONSerialization.data(withJSONObject: finalDict as? [String: Any])
               
               guard let url = URL(string: RestAPI.MEDIATION_IMPRESSION_URL) else {
                   // Handle the case where the URL is nil
                   print("Error: Invalid URL")
                   return
               }
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.setValue(bundleName, forHTTPHeaderField: "referrer")
               request.httpBody = jsonData
               request.addValue("application/json", forHTTPHeaderField: "\(AppConstant.iZ_CONTENT_TYPE)")
               request.addValue("application/json", forHTTPHeaderField: "Accept")
               let config = URLSessionConfiguration.default
               if #available(iOS 11.0, *) {
                   config.waitsForConnectivity = true
               } else {
                   // Fallback on earlier versions
               }
               URLSession(configuration: config).dataTask(with: request) {data,response,error in
                   
                   do {
                       if let error = error {
                           throw error
                       }
                       // Check the HTTP response status code
                       if let httpResponse = response as? HTTPURLResponse {
                           if httpResponse.statusCode == 200 {
                               
                           }
                       }
                   } catch {
                       Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "CallAdMediationImpressionApi", rid: rid, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
                   }
               }.resume()
           }else{
               Utils.handleOnceException(bundleName: bundleName, exceptionName: "key's are blank in request parameter,\(finalDict) ", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Impression API",  rid: finalDict.value(forKey: "rid") as? String, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
           }
       }
    
    //
    static func fetcherAdMediationClickApi(bundleName : String,url: String, title: String, rid: String, callForMedc: Bool, userInfo: [AnyHashable : Any]?) {

           var pid = ""
           var token = ""
        
        if let userDefault = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
            pid = userDefault.value(forKey: AppConstant.REGISTERED_ID) as? String ?? ""
               token = userDefault.value(forKey: AppConstant.IZ_GRPS_TKN) as? String ?? ""
           }
           
           let served: [String: Any] = ["a": 0, "b": 0, "ln": url, "t": -1, "ti": title]
           let bids: [String] = []
           let currentUTS = Int(Date().timeIntervalSince1970 * 1000)
           
           // Create the final request dictionary
           let requestDictionary: [String: Any] = ["bKey": token, "av": SDKVERSION, "served": served, "bids": bids, "pid": pid, "rid": rid, "ta": "\(currentUTS)"]
           
           // Serialize the final dictionary to JSON data
           guard let jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: []),
                 let jsonString = String(data: jsonData, encoding: .utf8) else {
               Utils.handleOnceException(bundleName: bundleName, exceptionName: "error in converting dictionary to JSON", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "fetcherAdMediationClickApi", rid: rid, cid: nil, userInfo: userInfo)
               return
           }
   //        print(jsonString)
           var baseUrl = ""
           if callForMedc {
               baseUrl = RestAPI.MEDIATION_CLICK_URL
           }else{
               baseUrl = RestAPI.MEDIATION_IMPRESSION_URL
           }
           guard let url = URL(string: baseUrl) else {
               // Handle the case where the URL is nil
               print("Error: Invalid URL")
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
           request.httpBody = jsonData
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")
           URLSession.shared.dataTask(with: request){(data,response,error) in
               do {
                   if let error = error {
                       Utils.handleOnceException(bundleName: bundleName, exceptionName: "Network error: \(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "fetcherAdMediationClickApi", rid: rid, cid: nil, userInfo: userInfo)
                   }
                   // Check the HTTP response status code
                   if let httpResponse = response as? HTTPURLResponse {
                       if httpResponse.statusCode == 200 {
                       }
                   }
               } catch {
                   Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "fetcherAdMediationClickApi", rid: rid, cid: nil, userInfo: userInfo)
               }
           }.resume()
       }
       
       //Ad-Mediation ClickAPI
    //Ad-Mediation ClickAPI
    @objc static func callAdMediationClickApi(bundleName : String,finalDict: NSDictionary, userInfo: [AnyHashable : Any]?){
           
           let defaults = UserDefaults.standard
           if (finalDict.count != 0) {
               let rid = finalDict.value(forKey: "rid") as? String
               let jsonData = try? JSONSerialization.data(withJSONObject: finalDict)
               
               guard let url = URL(string: RestAPI.MEDIATION_CLICK_URL) else {
                   // Handle the case where the URL is nil
                   print("Error: Invalid URL")
                   return
               }
               
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.httpBody = jsonData
               request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
               request.addValue("application/json", forHTTPHeaderField: "Accept")
               URLSession.shared.dataTask(with: request){(data,response,error) in
                   do {
                       if let error = error {
                           throw error
                       }
                       // Check the HTTP response status code
                       if let httpResponse = response as? HTTPURLResponse {
                           if httpResponse.statusCode == 200 {
                           }else{
                               Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 1", rid: rid, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
                           }
                       }
                   } catch {
                       
                       if let data = finalDict as? [String : Any] {
                           self.mediationClickStoreData.append(data)
                       }
                       UserDefaults.standard.set(self.mediationClickStoreData, forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
                       
                       Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 2", rid: rid, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
                   }
               }.resume()
           }else{
               Utils.handleOnceException(bundleName: bundleName, exceptionName: "key's are blank in request parameter, \(finalDict)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 3",  rid: finalDict.value(forKey: "rid") as? String, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
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
    @objc static func lastImpression(notificationData : Payload,pid : String,token : String,url : String,bundleName : String, userInfo: [AnyHashable : Any]? )
       {
           if(notificationData.rid != nil && pid != "" && token != "")
           {
               let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
               var requestBodyComponents = URLComponents()
               requestBodyComponents.queryItems = [
                   URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                   URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                   URLQueryItem(name: "cid", value: notificationData.id),
                   URLQueryItem(name: "rid", value: notificationData.rid),
                   URLQueryItem(name: "op", value: "view")
               ]
               guard let url = URL(string: url) else {
                   // Handle the case where the URL is nil
                   print("Error: Invalid URL")
                   return
               }
               var request = URLRequest(url: url)
               request.httpMethod = AppConstant.iZ_POST_REQUEST
               request.setValue(bundleName, forHTTPHeaderField: "Referer")
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
                               
                           }
                       }
                   } catch {
                       Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: notificationData.rid, cid : notificationData.id, userInfo: userInfo)
                   }
               }.resume()
           }
           else
           {
               Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid value is blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: notificationData.rid, cid : notificationData.id, userInfo: userInfo)
           }
       }
    
    
    

    // last click data send to server
        @objc static func lastClick(bundleName: String,notificationData : Payload,pid : String,token : String,url : String, userInfo: [AnyHashable: Any])
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
                            }
                        }
                        
                    } catch {
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here", userInfo: userInfo)
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid value is blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here", userInfo: userInfo)
            }
        }
    static func fallbackClickTrack(bundleName: String,title : String, landingUrl : String,rid :String, cid : String, userInfo: [AnyHashable : Any]?)
      {
          
          let pid = Utils.getUserId(bundleName: bundleName) ?? ""
          let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
         
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
                              }
                          }
                      } catch let error{
                          Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription ?? "")", className: tag_name, methodName: "clickTrack", rid: rid, cid: cid, userInfo: userInfo)
                          
                      }
                  }.resume()
              }
              else
              {
                  Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid or cid value is blank", className: tag_name, methodName: "clickTrack", rid: rid, cid: cid, userInfo: userInfo)
                  
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

