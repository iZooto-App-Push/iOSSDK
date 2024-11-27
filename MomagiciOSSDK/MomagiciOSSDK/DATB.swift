//
//  MomagiciOSSDK.swift
//  MomagiciOSSDK
//
//  Created by Amit on 13/06/21.
//
import Foundation
import UserNotifications
import UIKit
import Darwin
import AdSupport
import AVFoundation
import WebKit
import CommonCrypto

let sharedUserDefault = UserDefaults(suiteName: SharedUserDefault.suitName)
@objc public  class DATB : NSObject {
    private static var pid = String()

    static var  appDelegate = UIApplication.shared.delegate!
    private static var myIdLnArray: [[String:Any]] = []
    private static var myRCArray: [[String:Any]] = []
    private static var tokenData : String!
    private let application : UIApplication
    @available(iOS 11.0, *)
   // private static var firstAction : UNNotificationAction!
    @available(iOS 11.0, *)
   // private static var secondAction : UNNotificationAction!
    @available(iOS 11.0, *)
   // private static var category : UNNotificationCategory!
    private static var type = "0"
    private static let checkData = 1 as Int
    static var  appId : String!
    static var  launchOptions : NSDictionary!
    // private static var badgeCount = 0
    private static var isAnalytics = false as Bool
    private static var isNativeWebview = false as Bool
    private static var isWebView = false as Bool
   // private static var landingURL : String!
    private static var badgeNumber = 0 as NSInteger
    private static var badgeCount = 0 as NSInteger
    private static var storyBoardData = UIStoryboard.self
    private static var identifireNameData = String.self
    private static var controllerData = UIViewController.self
    @objc   public static var landingURLDelegate : LandingURLDelegate?
    private static var keySettingDetails = Dictionary<String,Any>()
    @objc  public static var notificationReceivedDelegate : NotificationReceiveDelegate?
    @objc  public static var notificationOpenDelegate : NotificationOpenDelegate?
    @objc private static var finalData = [String: Any]()
    @objc private static let tempData = NSMutableDictionary()
    @objc private static var succ = "false"
    @objc private static var alertData = [String: Any]()
    @objc private static var gData = [String: Any]()
    @objc private static var anData: [[String: Any]] = []
    @objc private static var cpcFinalValue = ""
    @objc private static var cpcValue = ""
    @objc private static var cprValue = ""
    @objc private static var finalCPCValue = "0.00000"
    @objc private static var count = 0
    @objc private static var fuCount = 0
    @objc private static var finalDataValue = NSMutableDictionary()
    @objc private static var servedData = NSMutableDictionary()
    @objc private static var bidsData = [NSMutableDictionary()]
    //to store category details
    private static var categoryArray: [[String:Any]] = []
    //@objc static var groupName = Utils.getBundleName()
    @objc public init(application : UIApplication)
    {
        self.application = application
    }
    
   
    // initialise the device and register the token
    @objc public static func initialisation(momagic_app_id : String, application : UIApplication,initSetting : Dictionary<String,Any>)
    {
        
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

        if(momagic_app_id == nil)
        {

            print("DATB : momagic_app_id is nil kindly check the configuration")
            return
        }
        
    
        UserDefaults.standard.setValue(momagic_app_id, forKey: "appID")
        keySettingDetails = initSetting
        RestAPI.getRequest(bundleName: bundleName,uuid: momagic_app_id) { (output) in
            
            var finalOutPut = output.trimmingCharacters(in: .whitespaces)
            finalOutPut = finalOutPut.replacingOccurrences(of: "\n", with: "")
            guard let jsonString = finalOutPut.fromBase64() else {//if wrong json format
                Utils.handleOnceException(bundleName: bundleName, exceptionName: ".dat base64 == \(output)", className: "DATB", methodName: "initialisation", rid: "0", cid: "0", userInfo: nil)
                return
            }
            do {
                if let finalJsonData = jsonString.data(using: .utf8) {
                    let responseData: DatParsing = try JSONDecoder().decode(DatParsing.self, from: finalJsonData)
                    if responseData.pid != "" && !responseData.pid.isEmpty {
                        if let savePid = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
                            savePid.setValue(responseData.pid, forKey: AppConstant.REGISTERED_ID)
                                               
                        }
                        
                    }else{
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: ".dat response error \(jsonString)", className: "DATB", methodName: "initialisation", rid: "0", cid: "0", userInfo: nil)
                        return
                    }
                } else {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: ".dat response error \(jsonString)", className: "DATB", methodName: "initialisation", rid: "0", cid: "0", userInfo: nil)
                }
            } catch let error {
                Utils.handleOnceException(bundleName: bundleName, exceptionName: ".dat parsing error \(error)", className: "DATB", methodName: "initialisation", rid: nil, cid: nil, userInfo: nil)
            }
            
        }
        if(!keySettingDetails.isEmpty)
        {
            if let webViewSetting = keySettingDetails[AppConstant.iZ_KEY_WEBVIEW] {
                sharedUserDefault?.set(webViewSetting, forKey: AppConstant.ISWEBVIEW)
            } else {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_WEBVIEW_ERROR)
                Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_WEBVIEW_ERROR, className: "DATB", methodName: "initialisation",  rid: "0", cid: "0", userInfo: nil)
            }
            if let isProvisional = keySettingDetails[AppConstant.iZ_KEY_PROVISIONAL] as? Bool{
                if isProvisional {
                    registerForPushNotificationsProvisional()
                }
            }
            else
            {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND)
                Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND, className: "DATB", methodName: "initialisation",  rid: "0", cid: "0", userInfo: nil)
            }
            if let autoPromptEnabled = keySettingDetails[AppConstant.iZ_KEY_AUTO_PROMPT] as? Bool{
                if autoPromptEnabled {
                    registerForPushNotifications()
                }
            }
            else {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_AUTO_PROMPT_NOT_FOUND)
                Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_AUTO_PROMPT_NOT_FOUND, className: AppConstant.IZ_TAG, methodName: AppConstant.iZ_KEY_INITIALISE,  rid: "0", cid: "0", userInfo: nil)
            }
            if #available(iOS 11.0, *) {
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
            }
        }
        else{
            registerForPushNotifications() // check for prompt
            if #available(iOS 11.0, *) {
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
            }
        }
        if let userPropertiesData = sharedUserDefault?.dictionary(forKey:AppConstant.iZ_USERPROPERTIES_KEY)
        {
            addUserProperties(data: userPropertiesData)
        }
        if let eventData = sharedUserDefault?.dictionary(forKey:AppConstant.KEY_EVENT),
           let eventName = sharedUserDefault?.string(forKey: AppConstant.KEY_EVENT_NAME){
            addEvent(eventName: eventName, data: eventData)
        }
        
    }
    
    @objc  public  static  func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
            }
        }
        if #available(iOS 10.0, *) {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                debugPrint(AppConstant.PERMISSION_GRANTED ,"\(granted)")
                guard granted else { return }
                getNotificationSettings()
                
            }
            
        }
        
    }
    
    
    
    // provision setting
    @objc  private static func  registerForPushNotificationsProvisional()
    {
        
        if #available(iOS 12.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge,.provisional]) {
                (granted, error) in
                debugPrint(AppConstant.PERMISSION_GRANTED ,"\(granted)")
                guard granted else { return }
                getNotificationSettingsProvisional()
            }
        }
    }
    
    //  Handle notification prompt setting
    @objc   private static func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                
                guard settings.authorizationStatus == .authorized else { return }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }
        }
    }
    // Handle provisional setting
    @objc  private static func getNotificationSettingsProvisional() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if #available(iOS 12.0, *) {
                    guard settings.authorizationStatus == .provisional else { return }
                }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }
        }
    }
    
   
    /* Getting APNS Token from this methods */
    @objc public static func getToken(deviceToken : Data)
    {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        _ = UserDefaults.standard
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
        let formattedDate = format.string(from: date)
        let userDefaults1 = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName))
        let storedToken = userDefaults1?.value(forKey: AppConstant.IZ_GRPS_TKN) as? String
        
        if UserDefaults.getRegistered() && (token == storedToken)
        {
            let pid = Utils.getUserId(bundleName: bundleName) ?? ""
            guard let token = Utils.getUserDeviceToken(bundleName: bundleName)
            else
            {return}
            debugPrint(AppConstant.DEVICE_TOKEN,token)
            if(formattedDate != (sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_LAST_VISIT)))
            {
                RestAPI.lastVisit(bundleName: bundleName, pid: pid, token:token)
                sharedUserDefault?.set(formattedDate, forKey: AppConstant.iZ_KEY_LAST_VISIT)
            }
            if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)) {
                userDefaults.set(token, forKey: AppConstant.IZ_GRPS_TKN)
                userDefaults.set(pid, forKey: AppConstant.REGISTERED_ID)
                userDefaults.synchronize()
            }
            if(RestAPI.SDKVERSION != sharedUserDefault?.string(forKey: AppConstant.iZ_SDK_VERSION)) || (RestAPI.getAppVersion() != sharedUserDefault?.string(forKey: AppConstant.iZ_APP_VERSION))
            {
                sharedUserDefault?.set(RestAPI.SDKVERSION, forKey: AppConstant.iZ_SDK_VERSION)
                sharedUserDefault?.set(RestAPI.getAppVersion(), forKey: AppConstant.iZ_APP_VERSION)
                RestAPI.registerToken(bundleName: bundleName, token: token, pid: pid)
                RestAPI.registerTokenWithMomagic(bundleName: bundleName, token: token, pid: pid)
                
            }
        }
        else
        {
            let pid = Utils.getUserId(bundleName: bundleName) ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                if(pid != "" && token != "")
                {

                    RestAPI.registerToken(bundleName: bundleName, token: token, pid: pid)
                    RestAPI.registerTokenWithMomagic(bundleName: bundleName, token: token, pid: pid)
                    
                    
                    if RestAPI.getAppVersion() != ""{
                        sharedUserDefault?.set(RestAPI.getAppVersion(), forKey: AppConstant.iZ_APP_VERSION)
                    }
                    sharedUserDefault?.set(RestAPI.SDKVERSION, forKey: AppConstant.iZ_SDK_VERSION)
                    sharedUserDefault?.set(token, forKey: SharedUserDefault.Key.token)
                    if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)) {
                        userDefaults.set(token, forKey: AppConstant.IZ_GRPS_TKN)
                        userDefaults.set(pid, forKey: AppConstant.REGISTERED_ID)
                        userDefaults.synchronize()
                    }
                    
                }
               
                
            }
        }
    }
    
    // handle the badge count
    @objc public static func setBadgeCount(badgeNumber : NSInteger)
        {
            let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

            if(badgeNumber == -1)
            {

                sharedUserDefault?.setValue(badgeNumber, forKey: "BADGECOUNT")
            }
            if(badgeNumber == 1)
            {
                if let sharedUserDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)) {
                    sharedUserDefaults.set(true, forKey: "badgeViaFunction")
                    sharedUserDefaults.setValue(badgeNumber, forKey: "BADGECOUNT")
                    sharedUserDefaults.synchronize()
                }
             
            }
            else
            {
                if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)) {
                    userDefaults.set(0, forKey: "Badge")
                    userDefaults.set(true, forKey: "badgeViaFunction")
                    userDefaults.synchronize()
                }
            }
        }
    
    
   // add fallback
   
   
    //To call Mediation-impression
       @objc private static func ad_mediationImpressionCall(notiRid: String, adTitle: String, adLn: String, bundleName: String, userInfo: [AnyHashable : Any]?){
           let groupName = "group."+bundleName+".datb"
           if let userDefaults = UserDefaults(suiteName: groupName){
               if let ids = userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as? [[String : Any]]{
                   let tempIdArray = ids
                   for data in ids {
                       if let dataDict = data as? NSDictionary {
                           if let rid = dataDict.value(forKey: "rid") as? String, rid == notiRid {
                               if let finalData = dataDict.mutableCopy() as? NSDictionary {
                                   if let served = finalData.value(forKey: "served") as? NSDictionary,
                                      let finalServed = served.mutableCopy() as? NSDictionary {
                                       finalServed.setValue(adTitle, forKey: "ti")
                                       finalServed.setValue(adLn, forKey: "ln")
                                       finalData.setValue(finalServed, forKey: "served")
                                       RestAPI.callAdMediationImpressionApi(finalDict: finalData, bundleName: bundleName, userInfo:userInfo )
                                       userDefaults.setValue(tempIdArray, forKey: AppConstant.iZ_BIDS_SERVED_ARRAY)
                                       userDefaults.synchronize()
                                   }
                               }
                           }
                       }
                   }
               }
           }
       }
    //for rid & bids call mediation click
       @objc private static func ad_mediationClickCall(notiRid: String, adTitle: String, adLn: String, userInfo: [AnyHashable : Any]?){
           let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

           
           if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
               if let ids = userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as? [[String : Any]]{
                   var tempIdArray = ids
                   for (index,data) in ids.enumerated() {
                       if let dataDict = data as? NSDictionary {
                           if let rid = dataDict.value(forKey: "rid") as? String, rid == notiRid {
                               if let finalData = dataDict.mutableCopy() as? NSDictionary {
                                   if let served = finalData.value(forKey: "served") as? NSDictionary,
                                      let finalServed = served.mutableCopy() as? NSDictionary {
                                       finalServed.setValue(adTitle, forKey: "ti")
                                       finalServed.setValue(adLn, forKey: "ln")
                                       finalData.setValue(finalServed, forKey: "served")
                                       RestAPI.callAdMediationClickApi(bundleName: bundleName, finalDict: finalData, userInfo: userInfo)
                                       if index <= tempIdArray.count - 1 {
                                           tempIdArray.remove(at: index)
                                       }
                                       userDefaults.setValue(tempIdArray, forKey: AppConstant.iZ_BIDS_SERVED_ARRAY)
                                       userDefaults.synchronize()
   //                                    break
                                   }
                               }
                           }
                       }
                   }
               }
           }
       }
       
    ///////////////////////////////////////////////
    ///
    /* Handling the payload data */
      @objc private static func payLoadDataChange(payload: [String:Any],bundleName: String, userInfo: [AnyHashable : Any]?,completion: @escaping ([String:Any]) -> Void) {
          
          if let jsonDictionary = payload as? [String:Any] {
              if let aps = jsonDictionary["aps"] as? NSDictionary{
                  if let category = aps.value(forKey: "category"){
                      tempData.setValue(category, forKey: "category")
                  }
                  if let alert = aps.value(forKey: AppConstant.iZ_ALERTKEY) {
                      if let data = alert as? [String : Any] {
                          alertData = data
                      }
                      tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                      tempData.setValue(1, forKey: "mutable-content")
                      tempData.setValue(0, forKey: "content_available")
                  }
                  if let g = aps.value(forKey: AppConstant.iZ_G_KEY), let gt = aps.value(forKey: AppConstant.iZ_G_KEY) as? NSDictionary {
                      if let gdata = gt as? [String : Any] {
                          gData = gdata
                      }
                      tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                      let groupName = "group."+bundleName+".datb"
                      if let userDefaults = UserDefaults(suiteName: groupName) {
                          if let pid = userDefaults.string(forKey: AppConstant.REGISTERED_ID){
                              finalDataValue.setValue(pid, forKey: "pid")
                          }else{
                              finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_IDKEY)) as? String, forKey: "pid")
                          }
                      }
                      finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_RKEY)) as? String, forKey: "rid")
                      finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_TPKEY)) as? String, forKey: "type")
                      finalDataValue.setValue("0", forKey: "result")
                      finalDataValue.setValue(RestAPI.SDKVERSION, forKey: "av")
                      
                      //tp = 4
                      if (gt.value(forKey: AppConstant.iZ_TPKEY)) as? String == "4" {
                          if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                              let startDate = Date()
                              bidsData.removeAll()
                              
                              if let dict = anKey[0] as? [String : Any] {
                                  DispatchQueue.main.async {
                                      let fuValue = dict["fu"] as? String ?? ""
                                      cpcValue = dict["cpc"] as? String ?? ""
                                      cprValue = dict["ctr"] as? String ?? ""
                                      let cpmValue = dict["cpm"] as? String ?? ""
                                      if cpcValue != ""{
                                          cpcFinalValue = cpcValue
                                      }else{
                                          cpcFinalValue = cpmValue
                                      }
                                      let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                                      let session: URLSession = {
                                          let configuration = URLSessionConfiguration.default
                                          configuration.timeoutIntervalForRequest = 2
                                          return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                                      }()
                                      if let url = URL(string: izUrlString ?? "") {
                                          session.dataTask(with: url) { data, response, error in
                                              if(error != nil)
                                              {
                                                  let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                  servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00] as NSMutableDictionary
                                                  bidsData.append(servedData)
                                                  if let firstElement = anKey[0] as? [String: Any] {
                                                      anData = [firstElement]
                                                  }
                                                  tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                  finalData["aps"] = tempData
                                                  //Bids & Served
                                                  finalDataValue.setValue(t, forKey: "ta")
                                                  finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                  finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                  
                                                  storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                  print(finalData)
                                                  
                                                  completion(finalData)
                                              }
                                              if let data = data {
                                                  do {
                                                      let json = try JSONSerialization.jsonObject(with: data)
                                                      //To Check FallBack
                                                      if let jsonDictionary = json as? [String:Any] {
                                                          if let value = jsonDictionary["msgCode"] as? String {
                                                              debugPrint(value)
                                                              let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                              bidsData.append([AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                          }else{
                                                              if let jsonDictionary = json as? [String: Any] {
                                                                  if cpmValue != "" {
                                                                      if let cpcString = getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue) as? String,
                                                                         let cpcValue = Double(cpcString),
                                                                         let cprValue = Double(cprValue) {
                                                                          finalCPCValue = String(cpcValue / (10 * cprValue))
                                                                      } else {
                                                                          print("Failed to calculate finalCPCValue")
                                                                          return
                                                                      }
                                                                  } else {
                                                                      finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                  }
                                                                  let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                  if let finalCPCValueDouble = Double(finalCPCValue) {
                                                                      servedData = [AppConstant.iZ_A_KEY: 1,AppConstant.iZ_B_KEY: finalCPCValueDouble,AppConstant.iZ_T_KEY: t,AppConstant.iZ_RETURN_BIDS: finalCPCValueDouble]
                                                                      finalDataValue.setValue("1", forKey: "result")
                                                                      bidsData.append(servedData)
                                                                  } else {
                                                                      print("Failed to convert finalCPCValue to Double")
                                                                  }
                                                              }
                                                          }
                                                      }else{
                                                          if let jsonArray = json as? [[String:Any]] {
                                                              if jsonArray[0]["msgCode"] is String{
                                                                  if let firstElement = anKey[0] as? [String: Any] {
                                                                      anData = [firstElement]
                                                                  }
                                                                  let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                  bidsData.append([AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                              }else{
                                                                  if cpmValue != "" {
                                                                      if let cpcString = getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue) as? String,
                                                                         let cpcValue = Double(cpcString),
                                                                         let cprValue = Double(cprValue) {
                                                                          finalCPCValue = String(cpcValue / (10 * cprValue))
                                                                      }
                                                                  } else {
                                                                      finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                  }
                                                                  let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                  if let finalCPCValueDouble = Double(finalCPCValue) {
                                                                      servedData = [AppConstant.iZ_A_KEY: 1,AppConstant.iZ_B_KEY: finalCPCValueDouble,AppConstant.iZ_T_KEY: t,AppConstant.iZ_RETURN_BIDS: finalCPCValueDouble]
                                                                      finalDataValue.setValue("1", forKey: "result")
                                                                      bidsData.append(servedData)
                                                                  }
                                                              }
                                                          }
                                                      }
                                                      if let firstElement = anKey[0] as? [String: Any] {
                                                          anData = [firstElement]
                                                      }
                                                      tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                      finalData["aps"] = tempData
                                                      //Bids & Served
                                                      
                                                      let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                                                      finalDataValue.setValue(ta, forKey: "ta")
                                                      finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                      finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                      
                                                      storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                      completion(finalData)
                                                      
                                                  } catch {
                                                      let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                      servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00] as NSMutableDictionary
                                                      bidsData.append(servedData)
                                                      if let firstElement = anKey[0] as? [String: Any] {
                                                          anData = [firstElement]
                                                      }
                                                      tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                      finalData["aps"] = tempData
                                                      //Bids & Served
                                                      finalDataValue.setValue(t, forKey: "ta")
                                                      finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                      finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                      
                                                      storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                      completion(finalData)
                                                  }
                                              }
                                          }.resume()
                                      }else{
                                          
                                          Utils.handleOnceException(bundleName: bundleName, exceptionName: "FetchUrl error for tp 4\(izUrlString ?? "")", className: "DATB", methodName: "fallBackAdsApi", rid: gt.value(forKey: "r") as? String ?? nil , cid: gt.value(forKey: "id") as? String ?? nil, userInfo: userInfo)
                                          
                                      }
                                  }
                              }
                          }
                      }
                      //tp = 5
                        else if let value = gt.value(forKey: AppConstant.iZ_TPKEY) as? String, value == "5" {
                          if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                              self.succ = "false"
                              bidsData.removeAll()
                              var fuDataArray = [String]()
                              for (index,valueDict) in anKey.enumerated()   {
                                  
                                  if let dict = valueDict as? [String: Any] {
                                      debugPrint("", index)
                                      let fuValue = dict["fu"] as? String ?? ""
                                      //hit fu
                                      if let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)){
                                          fuDataArray.append(izUrlString)
                                      }
                                  }
                              }
                              self.fuCount = 0
                              callFetchUrlForTp5(fuArray: fuDataArray, urlString: fuDataArray[0], anKey: anKey, bundleName: bundleName, completion: completion)
                          }
                      }
                      //tp = 6
                      else {
                          if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                              let startDate = Date()
                              bidsData.removeAll()
                              var finalArray: [[String:Any]] = []
                              var servedArray: [[String:Any]] = []
                              let myGroup = DispatchGroup()
                              
                              for (index,valueDict) in anKey.enumerated()   {
                                  if var dict = valueDict as? [String: Any] {
                                      myGroup.enter()
                                      //hit fu
                                      DispatchQueue.main.async {
                                          
                                          var cpcFinalValue = ""
                                          var cpcValue = ""
                                          var ctrValue = ""
                                          var cpmValue = ""
                                          let fuValue = dict["fu"] as? String ?? ""
                                          cpcValue = dict["cpc"] as? String ?? ""
                                          ctrValue = dict["ctr"] as? String ?? ""
                                          cpmValue = dict["cpm"] as? String ?? ""
                                          if cpcValue != ""{
                                              cpcFinalValue = cpcValue
                                          }else{
                                              cpcFinalValue = cpmValue
                                          }
                                          let session: URLSession = {
                                              let configuration = URLSessionConfiguration.default
                                              configuration.timeoutIntervalForRequest = 2
                                              return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                                          }()
                                          if let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)){
                                              if let url = URL(string: izUrlString) {
                                                  session.dataTask(with: url) { data, response, error in
                                                      if(error != nil)
                                                      {
                                                          if let element = anKey[index] as? [String : Any] {
                                                              anData = [element]
                                                          }
                                                          let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                          bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                          //debugPrint("TOP ERROR")
                                                          dict.updateValue(("0.00"), forKey: "cpcc")
                                                          finalArray.append(dict)
                                                      }
                                                      if let data = data {
                                                          do {
                                                              let json = try JSONSerialization.jsonObject(with: data)
                                                              //To Check FallBack
                                                              if let jsonDictionary = json as? [String:Any] {
                                                                  if let value = jsonDictionary["msgCode"] as? String {
                                                                      debugPrint(value)
                                                                      let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                      bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                                  }else{
                                                                      if let jsonDictionary = json as? [String: Any] {
                                                                          if cpmValue != "" {
                                                                              if let cpcString = getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue) as? String,
                                                                                 let cpcValue = Double(cpcString),
                                                                                 let ctrValue = Double(ctrValue) {
                                                                                  finalCPCValue = String(cpcValue / (10 * ctrValue))
                                                                              }
                                                                          } else {
                                                                              finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                          }
                                                                          finalDataValue.setValue("\(index + 1)", forKey: "result")
                                                                          let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                          if let finalCPCValueDouble = Double(finalCPCValue) {
                                                                              servedData = [AppConstant.iZ_A_KEY: index + 1,AppConstant.iZ_B_KEY: finalCPCValueDouble,AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCValueDouble]
                                                                              if let servedDataDict = servedData as? [String: Any] {
                                                                                  servedArray.append(servedDataDict)
                                                                              }
                                                                              bidsData.append(servedData)
                                                                          }
                                                                      }
                                                                  }
                                                              }else{
                                                                  if let jsonArray = json as? [[String:Any]] {
                                                                      
                                                                      if jsonArray[0]["msgCode"] is String{
                                                                          let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                          bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                                      }else{
                                                                          if cpmValue != "" {
                                                                              if let cpcString = getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue) as? String,
                                                                                 let cpcValue = Double(cpcString),
                                                                                 let ctrValue = Double(ctrValue) {
                                                                                  finalCPCValue = String(cpcValue / (10 * ctrValue))
                                                                              }
                                                                          } else {
                                                                              finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                          }
                                                                          finalDataValue.setValue("\(index + 1)", forKey: "result")
                                                                          let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                          if let finalCPCValueDouble = Double(finalCPCValue) {
                                                                              servedData = [AppConstant.iZ_A_KEY: index + 1,AppConstant.iZ_B_KEY: finalCPCValueDouble,AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCValueDouble]
  //                                                                            servedArray.append(servedData as! [String : Any])
                                                                              if let servedDataDict = servedData as? [String: Any] {
                                                                                  servedArray.append(servedDataDict)
                                                                              }
                                                                              bidsData.append(servedData)
                                                                          }
                                                                      }
                                                                      
                                                                      
                                                                  }
                                                              }
                                                              dict.updateValue((finalCPCValue), forKey: "cpcc")
                                                              finalArray.append(dict)
                                                          } catch let error {
                                                              debugPrint(" Error",error)
                                                              let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                              bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                              dict.updateValue(("0.00"), forKey: "cpcc")
                                                              finalArray.append(dict)
                                                          }
                                                      }
                                                      if finalArray.count == (anKey as AnyObject).count{
                                                          
                                                          let sortedArray = finalArray.sorted { (dict1, dict2) -> Bool in
                                                              if let value1 = dict1["cpcc"] as? String, let value2 = dict2["cpcc"] as? String {
                                                                  return value1 > value2
                                                              }
                                                              return false
                                                          }
                                                          
                                                          guard let cpccSortedDict = sortedArray.first as? NSDictionary else {
                                                              
                                                              return // or any other appropriate action
                                                          }
                                                          if let firstItem = sortedArray.first {
                                                              if let anDataArray = firstItem as? [[String: Any]] {
                                                                  anData = anDataArray
                                                              }
                                                          }
                                                          
                                                          tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                                                          tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                          tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                                                          
                                                          tempData.setValue(1, forKey: "mutable-content")
                                                          tempData.setValue(0, forKey: "content_available")
                                                          
                                                          finalData["aps"] = tempData
                                                          
                                                          //Bids & Served
                                                          let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                                                          finalDataValue.setValue(ta, forKey: "ta")
                                                          
                                                          // To save final served as per cpc
                                                          if servedArray.count != 0{
                                                              for data in servedArray{
                                                                  let dict = data as NSDictionary
                                                                  let cpc = dict.value(forKey: AppConstant.iZ_B_KEY) as? Double
                                                                  let result = dict.value(forKey: AppConstant.iZ_A_KEY) as? Int
                                                                  if let fCpc = cpc?.string{
                                                                      let fCPCC = cpccSortedDict.value(forKey: "cpcc") as? String
                                                                      if let finalcpc = fCPCC?.toDouble() {
                                                                          let fff = finalcpc.string
                                                                          if fCpc == fff{
                                                                              finalDataValue.setValue(dict, forKey: AppConstant.iZ_SERVEDKEY)
                                                                              finalDataValue.setValue(result, forKey: "result")
                                                                          }
                                                                      }
                                                                  }
                                                              }
                                                          }else{
                                                              let dict = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY: 435,AppConstant.iZ_RETURN_BIDS:0.00]
                                                              // bidsData.append(dict as NSDictionary)
                                                              finalDataValue.setValue(dict, forKey: AppConstant.iZ_SERVEDKEY)
                                                              finalDataValue.setValue("0", forKey: "result")
                                                          }
                                                          
                                                          finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                          //debugPrint("Type66", finalDataValue)
                                                          storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                          completion(finalData)
                                                      }
                                                  }.resume()
                                              }else{
                                                  
                                                  Utils.handleOnceException(bundleName: bundleName, exceptionName: "fetchUrl error in tp 5 = \(izUrlString)", className: "DATB", methodName: "fallBackAdsApi",rid: gt.value(forKey: "r") as? String ?? nil , cid: gt.value(forKey: "id") as? String ?? nil, userInfo: userInfo)
                                              }
                                          }
                                      }
                                      myGroup.leave()
                                  }
                              }
                              myGroup.notify(queue: .main) {
                                  debugPrint("")
                              }
                          }
                      }
                  }
              }
          }
      }
    
    
   
    
    @objc private static func callFetchUrlForTp5(fuArray: [String], urlString: String, anKey: NSArray, bundleName: String, completion: @escaping ([String : Any]) -> Void){
        
        let startDate = Date()
        let fu = fuArray[fuCount]
        if let dict = anKey[fuCount] as? NSDictionary {
            let cpmValue = dict["cpm"] as? String ?? ""
            let ctrValue = dict["ctr"] as? String ?? ""
            let cpcValue = dict["cpc"] as? String ?? ""
            if cpcValue != ""{
                cpcFinalValue = cpcValue
            }else{
                cpcFinalValue = cpmValue
            }
            let session: URLSession = {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 2
                return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
            }()
            
            if let url = URL(string: fu) {
                session.dataTask(with: url) { data, response, error in
                    
                    if(error != nil)
                    {
                        let t = Int(Date().timeIntervalSince(startDate) * 1000)
                        bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00])
                        if succ != "done"{
                            fuCount += 1
                            if fuArray.count > fuCount {
                                callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, completion: completion)
                            }
                        }
                        if fuCount == anKey.count{
                            if let element = anKey[fuCount - 1] as? [String : Any] {
                                anData = [element]
                            }
                            tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                            finalData["aps"] = tempData
                            
                            servedData = [AppConstant.iZ_A_KEY: fuCount, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                            finalDataValue.setValue(t, forKey: "ta")
                            finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                            finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                            storeBids(bundleName: bundleName, finalData: finalDataValue)
                            completion(finalData)
                        }
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data)
                            //To Check FallBack
                            if let jsonDictionary = json as? [String:Any] {
                                if let value = jsonDictionary["msgCode"] as? String {
                                    debugPrint(value)
                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS:0.00])
                                    if fuCount == anKey.count{
                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                                        if let element = anKey[fuCount - 1] as? [String : Any] {
                                            anData = [element]
                                        }
                                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                        finalData["aps"] = tempData
                                        completion(finalData)
                                    }
                                }else{
                                    if let jsonDictionary = json as? [String:Any] {
                                        if cpmValue != "" {
                                            let cpcString = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                            if let cpc = Double(cpcString),
                                               let ctrValue = Double(ctrValue) {
                                                finalCPCValue = String(cpc / (10 * ctrValue))
                                            }
                                        } else {
                                            finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                        }
                                        let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                        if let finalCPCValueDouble = Double(finalCPCValue) {
                                            bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1,AppConstant.iZ_B_KEY: finalCPCValueDouble, AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCValueDouble])
                                            if let anKeyDict = anKey[fuCount] as? [String: Any] {
                                                anData = [anKeyDict]
                                                tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                finalData["aps"] = tempData
                                            }
                                            if succ != "done" {
                                                succ = "true"
                                                servedData = [AppConstant.iZ_A_KEY: fuCount + 1,AppConstant.iZ_B_KEY: finalCPCValueDouble,AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCValueDouble]
                                                finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                            }
                                        }
                                    }
                                }
                            }else{
                                if let jsonArray = json as? [[String:Any]] {
                                    if jsonArray[0]["msgCode"] is String{
                                        let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                        bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00])
                                        if fuCount == anKey.count{
                                            servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                                            if let anKeyDict = anKey[fuCount] as? [String: Any] {
                                                anData = [anKeyDict]
                                            }
                                            tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                            finalData["aps"] = tempData
                                            completion(finalData)
                                        }
                                    }else{
                                        if cpmValue != "" {
                                            let cpcString = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                            if let cpc = Double(cpcString),
                                               let ctrValue = Double(ctrValue) {
                                                finalCPCValue = String(cpc / (10 * ctrValue))
                                            }
                                        } else {
                                            finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                        }
                                        let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                        if let finalCPCValueDouble = Double(finalCPCValue) {
                                            bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: finalCPCValueDouble, AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCValueDouble])
                                            if let anKeyDict = anKey[fuCount] as? [String: Any] {
                                                anData = [anKeyDict]
                                                tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                finalData["aps"] = tempData
                                            }
                                            if succ != "done" {
                                                succ = "true"
                                                servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: finalCPCValueDouble, AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCValueDouble]
                                                finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                            }
                                        }
                                    }
                                }
                            }
                        } catch let error {
                            if !error.localizedDescription.isEmpty{
                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00])
                                if succ != "done"{
                                    fuCount += 1
                                    if fuArray.count > fuCount {
                                        callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, completion: completion)
                                    }
                                }
                                if fuCount == anKey.count{
                                    if let anKeyDict = anKey[fuCount - 1] as? [String : Any]{
                                        anData = [anKeyDict]
                                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                        finalData["aps"] = tempData
                                        completion(finalData)
                                    }
                                }
                            }
                        }
                        if succ == "true"{
                            succ = "done"
                            //Bids & Served
                            let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                            finalDataValue.setValue(ta, forKey: "ta")
                            finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                            finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                            debugPrint("Type 5", finalDataValue)
                            storeBids(bundleName: bundleName, finalData: finalDataValue)
                            completion(finalData)
                            return
                        }
                    }
                }.resume()
            }
        }
    }
     

    
    // Handle the payload and show the notification
      @available(iOS 11.0, *)
      @objc public static func didReceiveNotificationExtensionRequest(bundleName : String,soundName :String,isBadge : Bool,
                                                                      request : UNNotificationRequest, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
      {
          var bundleNameID = ""
              bundleNameID = bundleName
          var groupName = "group."+bundleNameID+".datb"
          let userInfo = request.content.userInfo
          var isEnabled = false
          if let jsonDictionary = userInfo as? [String:Any] {
              if let aps = jsonDictionary["aps"] as? NSDictionary{
                  if aps.value(forKey: AppConstant.iZ_ANKEY) != nil {
                      if let userInfoData = userInfo as? [String: Any] {
                          self.payLoadDataChange(payload: userInfoData, bundleName: bundleNameID, userInfo: userInfo) { data in
                              if let totalData = data["aps"] as? NSDictionary{
                                  if let apsDictionary = data["aps"] as? NSDictionary {
                                      if let notificationData = Payload(dictionary: apsDictionary){
                                          if notificationData.ankey != nil {
                                              if(notificationData.global?.rid != nil && notificationData.global?.created_on != nil)
                                              {
                                                 // to handle badgeCount, Sound, and call impression
                                                  setupBadgeSoundAndHandleImpression(bundleNameID: bundleNameID, isBadge: isBadge, bestAttemptContent: bestAttemptContent, notificationData: notificationData, userInfo: userInfo, isEnabled: isEnabled, soundName: soundName)

                                                  //Relevance Score
                                                  self.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                                                  
                                                  if notificationData.ankey?.fetchUrlAd != nil && notificationData.ankey?.fetchUrlAd != ""
                                                  {
                                                      self.commonFuUrlFetcher(bestAttemptContent: bestAttemptContent, bundleName: bundleNameID, notificationData: notificationData,totalData: totalData, userInfo: userInfo, contentHandler: contentHandler)
                                                  }
                                              }
                                              else
                                              {
                                                  debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                                                  Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(AppConstant.iZ_KEY_OTHER_PAYLOD) \(userInfo)", className: "DATB", methodName: "didReceive",  rid: notificationData.global?.rid, cid: notificationData.global?.id, userInfo: userInfo)
                                              }
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }else{
                      //to get all aps data & pass it to commonfu function
                      if let totalData = userInfo["aps"] as? NSDictionary {
                          if let apsDictionary = userInfo["aps"] as? NSDictionary {
                              if let notificationData = Payload(dictionary: apsDictionary){
                                  guard notificationData.rid != nil && notificationData.created_on != nil else {
                                      debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                                      Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(AppConstant.iZ_KEY_OTHER_PAYLOD) \(userInfo)", className: "DATB", methodName: "didReceive",rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
                                      return
                                      
                                  }
                                  
                                  // to handle badgeCount, Sound, and call impression
                                  setupBadgeSoundAndHandleImpression(bundleNameID: bundleNameID, isBadge: isBadge, bestAttemptContent: bestAttemptContent, notificationData: notificationData, userInfo: userInfo, isEnabled: isEnabled, soundName: soundName)

                                  //Relevance Score
                                  self.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                                  if notificationData.fetchurl != nil && notificationData.fetchurl != ""
                                  {
                                      self.commonFuUrlFetcher(bestAttemptContent: bestAttemptContent, bundleName: bundleNameID, notificationData: notificationData, totalData: totalData, userInfo: userInfo, contentHandler: contentHandler)
                                  }
                                  else{
                                      if notificationData != nil
                                      {
                                          let firstIndex = notificationData.rid?.prefix(1).first
                                          if firstIndex != "6" && firstIndex != "7" {
                                                  notificationReceivedDelegate?.onNotificationReceived(payload: notificationData)
                                          }
                                          
                                          if notificationData.category != "" && notificationData.category != nil
                                          {
                                              //to store categories
                                              storeCategories(notificationData: notificationData, category: "")
                                              if notificationData.act1name != "" && notificationData.act1name != nil {
                                                  addCTAButtons()
                                              }
                                          }
                                          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                              autoreleasepool {
                                                  guard (notificationData.alert?.attachment_url) != nil else { return }
                                                  guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.id, rid: notificationData.rid, imgUrl: notificationData.alert?.attachment_url ?? "", userInfo: userInfo, options: nil) else {
                                                          if isEnabled == true{
                                                              debugPrint(AppConstant.IMAGE_ERROR)
                                                          }
                                                          contentHandler!(bestAttemptContent)
                                                          return
                                                      }
                                                      bestAttemptContent.attachments = [ attachment ]
                                              }
                                              contentHandler!(bestAttemptContent)
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }
    
    // To handle badgeCount, Sound and call impression
        @objc public static func setupBadgeSoundAndHandleImpression( bundleNameID: String, isBadge: Bool, bestAttemptContent :UNMutableNotificationContent, notificationData: Payload, userInfo: [AnyHashable : Any]? , isEnabled: Bool, soundName:String) {
            // custom notification sound
            if (soundName != "")
            {
                bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(string: soundName) as String)
            }
            else
            {
                bestAttemptContent.sound = .default()
            }
            if(bundleNameID != "") {
                
                var number:Int? = nil
                var rid: String? = nil
                var cid: String? = nil
                if notificationData.ankey != nil {
                    if let cfg = notificationData.global?.cfg{
                        number = Int(cfg)
                    }
                    rid = notificationData.global?.rid
                    cid = notificationData.global?.id
                }else{
                    if let cfg = notificationData.cfg{
                        number = Int(cfg)
                    }
                    rid = notificationData.rid
                    cid = notificationData.id
                }
                
                let groupName = "group."+bundleNameID+".datb"

                if let userDefaults = UserDefaults(suiteName: groupName) {
                    userDefaults.set(isBadge, forKey: "isBadge")

                    if isBadge {
                        let isFunction = userDefaults.value(forKey: "badgeViaFunction") as? Bool ?? true
                        if isFunction {
                            if let sharedUserDefaults = UserDefaults(suiteName:groupName) {
                                let badgeCount = sharedUserDefaults.integer(forKey: "BADGECOUNT")
                                if badgeCount == 1 {
                                    bestAttemptContent.badge = 1
                                }
                                else{
                                    let badgeCount = userDefaults.integer(forKey: "Badge")
                                    bestAttemptContent.badge = (max(badgeNumber, badgeCount + 1)) as NSNumber
                                    userDefaults.set(bestAttemptContent.badge, forKey: "Badge")
                                    
                                }
                            }else{
                                
                                let badgeCount = userDefaults.integer(forKey: "Badge")
                                bestAttemptContent.badge = (max(badgeNumber, badgeCount + 1)) as NSNumber
                                userDefaults.set(bestAttemptContent.badge, forKey: "Badge")
                            }
                        }else{
                            if let userDefault = UserDefaults(suiteName: groupName) {
                                let badgeStatus = userDefault.value(forKey: "isBadgeEnabled") as? String
                                if badgeStatus == "staticBadge" {
                                    bestAttemptContent.badge = 1
                                    userDefault.set(1, forKey: "Badge")
                                }else if badgeStatus == "enableBadge"{
                                    let badgeCount = userDefaults.integer(forKey: "Badge")
                                    bestAttemptContent.badge = (max(badgeNumber, badgeCount + 1)) as NSNumber
                                    userDefault.set(bestAttemptContent.badge, forKey: "Badge")
                                }else if badgeStatus == "disableBadge"{
                                    bestAttemptContent.badge = -1
                                }
                            }
                            else{
                                let badgeCount = userDefaults.integer(forKey: "Badge")
                                bestAttemptContent.badge = (max(badgeNumber, badgeCount + 1)) as NSNumber
                                userDefaults.set(bestAttemptContent.badge, forKey: "Badge")
                                
                                
                            }
                        }
                    } else {
                        bestAttemptContent.badge = -1
                    }
                    if (number != nil)
                    {
                        handleImpresseionCfgValue(cfgNumber: number ?? 0, notificationData: notificationData, bundleName: bundleNameID, isSilentPush: false, userInfo: userInfo)
                    }
                    userDefaults.synchronize()
                }
                else
                {
                    if isEnabled == true{
                        debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_APP_GROUP_ERROR_)
                    }
                    Utils.handleOnceException(bundleName: bundleNameID, exceptionName: AppConstant.iZ_APP_GROUP_ERROR_, className: "DATB", methodName: "didReceive", rid: rid, cid: cid, userInfo: userInfo)
                }
            }
        }
    
    
    
    
    
    
    
    
    
    //To set relevance score in above iOS 15
    @objc private static func setRelevanceScore(notificationData: Payload, bestAttemptContent: UNMutableNotificationContent){
        if #available(iOS 15.0, *) {
            bestAttemptContent.relevanceScore = notificationData.relevence_score ?? 0
            if(notificationData.interrutipn_level == 1 )
            {
                bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.passive
            }
            if(notificationData.interrutipn_level == 2)
            {
                bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.timeSensitive
                
            }
            if(notificationData.interrutipn_level == 3)
            {
                bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.critical
            }
        }
    }
    
    //Common method for fu fetcher
    
  
    
    //Common method for fu fetcher
    //Common method for fu fetcher
       @objc private static func commonFuUrlFetcher(bestAttemptContent :UNMutableNotificationContent,bundleName: String,notificationData : Payload,totalData: NSDictionary,userInfo: [AnyHashable : Any]?,contentHandler:((UNNotificationContent) -> Void)?){
           
           if notificationData.ankey != nil {
               var flbk : [String] = []
               if let gArray = totalData["g"] as? [String: Any] {
                   let fsd = (gArray["fsd"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "flbk"
                   let fbu = (gArray["fbu"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "default.json"
                   flbk = [fsd.isEmpty ? "flbk" : fsd, fbu.isEmpty ? "default.json" : fbu]
               }
               var adId = ""
               var adLn = ""
               var adTitle = ""
               guard let izUrlString = (notificationData.ankey?.fetchUrlAd?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) else {
                   return
               }
               let session: URLSession = {
                   let configuration = URLSessionConfiguration.default
                   configuration.timeoutIntervalForRequest = 2
                   return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
               }()
               
               if let url = URL(string: izUrlString) {
                   session.dataTask(with: url) { data, response, error in
                       if(error != nil)
                       {
                           if let notificationRid = notificationData.global?.rid {
                               fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk, notiRid: notificationRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                               return
                           }
                          
                       }
                       if let data = data {
                           do {
                               let json = try JSONSerialization.jsonObject(with: data)
                               
                               //To Check FallBack
                               if let jsonDictionary = json as? [String:Any] {
                                   if let value = jsonDictionary["msgCode"] as? String {
                                       debugPrint(value)
                                       if let notificationRid = notificationData.global?.rid {
                                           fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk, notiRid: notificationRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                           return
                                       }
                                   }else{
                                       if let jsonDictionary = json as? [String:Any] {
                                           
                                           if let title = notificationData.ankey?.titleAd, let message = notificationData.ankey?.messageAd {
                                               bestAttemptContent.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: title))"
                                               bestAttemptContent.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: message))"
                                           }
                                           if var landUrl = (notificationData.ankey?.landingUrlAd)  {
                                               landUrl = "\(getParseValue(jsonData: jsonDictionary, sourceString: landUrl))"
                                               adLn = landUrl
                                               if let adIds = notificationData.ankey?.idAd{
                                                   adId = adIds
                                               }
                                               adTitle = bestAttemptContent.title
                                               myIdLnArray.removeAll()
                                               let dict  = [AppConstant.iZ_IDKEY: adId, AppConstant.iZ_LNKEY: adLn, AppConstant.iZ_TITLE_KEY: adTitle]
                                               myIdLnArray.append(dict)
                                           }
                                           if notificationData.ankey?.bannerImageAd != "" {
                                               if let imageAd = notificationData.ankey?.bannerImageAd  {
                                                   notificationData.ankey?.bannerImageAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: imageAd))"
                                                   
                                                   if let imageAdStr = notificationData.ankey?.bannerImageAd,  imageAdStr.contains(".webp")
                                                   {
                                                       notificationData.ankey?.bannerImageAd = notificationData.ankey?.bannerImageAd?.replacingOccurrences(of: ".webp", with: ".jpeg")
                                                       
                                                   }
                                                   if let imageAdStr = notificationData.ankey?.bannerImageAd , (imageAdStr.contains("http:"))
                                                   {
                                                       notificationData.ankey?.bannerImageAd = notificationData.ankey?.bannerImageAd?.replacingOccurrences(of: "http:", with: "https:")
                                                   }
                                               }
                                           }
                                           //Check & hit RC for adMediation
                                           if notificationData.ankey?.adrc != nil{
                                               if let adID = notificationData.ankey?.idAd {
                                                   adMediationRCDataStore(totalData: totalData, jsonDictionary: jsonDictionary, bundleName: bundleName, aDId: adID)
                                               }
                                           }
                                           //Check & hit the RV for adMediation
                                           if ((notificationData.ankey?.adrv != nil)){
                                               adMediationRVApiCall(totalData: totalData, jsonDictionary: jsonDictionary)
                                           }
                                       }
                                   }
                               }else{
                                   if let jsonArray = json as? [[String:Any]] {
                                       if jsonArray[0]["msgCode"] is String {
                                           if let notiRid = notificationData.global?.rid {
                                               fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk, notiRid: notiRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                           }
                                           return
                                       }else{
                                           if let adTitle = notificationData.ankey?.titleAd, let adMessage = notificationData.ankey?.messageAd {
                                               bestAttemptContent.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: adTitle))"
                                               bestAttemptContent.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: adMessage))"
                                           }
                                           
                                           if var landUrl = (notificationData.ankey?.landingUrlAd)  {
                                               landUrl = "\(getParseArrayValue(jsonData: jsonArray, sourceString: landUrl))"
                                               adLn = landUrl
                                               if let adIds = notificationData.ankey?.idAd{
                                                   adId = adIds
                                               }
                                               adTitle = bestAttemptContent.title
                                               myIdLnArray.removeAll()
                                               let dict  = [AppConstant.iZ_IDKEY: adId, AppConstant.iZ_LNKEY: adLn, AppConstant.iZ_TITLE_KEY: adTitle]
                                               myIdLnArray.append(dict)
                                           }
                                           if let bannerImage = notificationData.ankey?.bannerImageAd, !bannerImage.isEmpty {
                                               notificationData.ankey?.bannerImageAd = "\(getParseArrayValue(jsonData: jsonArray, sourceString: bannerImage))"
                                               if let bannerImageAdString = notificationData.ankey?.bannerImageAd, bannerImageAdString.contains(".webp") {
                                                   notificationData.ankey?.bannerImageAd = bannerImageAdString.replacingOccurrences(of: ".webp", with: ".jpg")
                                               }
                                           }
                                       }
                                   }
                               }
                               if notificationData.category != "" && notificationData.category != nil
                               {
                                   storeCategories(notificationData: notificationData, category: "")
                                   if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                                       addCTAButtons()
                                   }
                               }
                               DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                   autoreleasepool {
                                           guard let string = notificationData.ankey?.bannerImageAd else { return }
                                       guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.global?.id, rid: notificationData.global?.rid, imgUrl:notificationData.ankey?.bannerImageAd ?? "", userInfo: userInfo , options: nil) else {
                                               debugPrint(AppConstant.IMAGE_ERROR)
                                               contentHandler!(bestAttemptContent)
                                               return
                                           }
                                           bestAttemptContent.attachments = [ attachment ]
                                   }
                                   storeNotiUrl_ln(bundleName: bundleName)
                                   //call impression
                                   if let rID = notificationData.global?.rid {
                                       self.ad_mediationImpressionCall(notiRid: rID, adTitle: adTitle, adLn: adLn, bundleName: bundleName, userInfo: userInfo)
                                   }
                                   // Need to review
                                   if bestAttemptContent.title == notificationData.ankey?.titleAd{
                                       if let rID = notificationData.global?.rid {
                                           self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk,notiRid: rID, userInfo: nil, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                       }
                                   }else{
                                       contentHandler!(bestAttemptContent)
                                   }
                               }
                           } catch {
                               if let rID = notificationData.global?.rid {
                                   self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk,notiRid: rID, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                               }
                           }
                       }
                   }.resume()
               }else{
                   Utils.handleOnceException(bundleName: bundleName, exceptionName: "Mediation fetch url is not in correct format\(izUrlString)", className: "DATB", methodName: "commonFetchUrl", rid: notificationData.global?.rid, cid: notificationData.global?.id, userInfo: userInfo)
               }
           }else{
               
               let fsd = (totalData["fsd"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "flbk"
               let fbu = (totalData["fbu"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "default.json"
               let flbk = [fsd.isEmpty ? "flbk" : fsd, fbu.isEmpty ? "default.json" : fbu]
               
               let izUrlString = (notificationData.fetchurl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
               let session: URLSession = {
                   let configuration = URLSessionConfiguration.default
                   configuration.timeoutIntervalForRequest = 2
                   return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
               }()
               
               if let url = URL(string: izUrlString ?? "") {
                   session.dataTask(with: url) { data, response, error in
                       if(error != nil)
                       {
                           fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk, notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                           return
                       }
                       
                       if let httpResponse = response as? HTTPURLResponse {
                                  if httpResponse.statusCode != 200 {
                                      fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk, notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                      return
                                      //return
                                  }
                              }
                       
                       
                       
                       if let data = data {
                           do {
                               let json = try JSONSerialization.jsonObject(with: data)
                               //To Check FallBack
                               if let jsonDictionary = json as? [String:Any] {
                                   if let _ = jsonDictionary["msgCode"] as? String {
                                       fallBackAdsApi(bundleName: bundleName,
                                                      fallCategory: notificationData.category ?? "", flbk: flbk,
                                                      notiRid: "", userInfo: userInfo,
                                                      bestAttemptContent: bestAttemptContent,
                                                      contentHandler: contentHandler)
                                       return
                                   }else{
                                       if let jsonDictionary = json as? [String:Any] {
                                           if let title = notificationData.alert?.title, let bodyData = notificationData.alert?.body {
                                               bestAttemptContent.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: title))"
                                               bestAttemptContent.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: bodyData))"
                                           }
                                           if let url = notificationData.url, !url.isEmpty {
                                               notificationData.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: url))"
                                           }
                                           if let url = notificationData.alert?.attachment_url, !url.isEmpty {
                                               
                                               notificationData.alert?.attachment_url = "\(getParseValue(jsonData: jsonDictionary, sourceString: url))"
                                               if let webUrl = notificationData.alert?.attachment_url, webUrl.contains(".webp") {
                                                   notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpeg")
                                               }
                                               if let httpUrl = notificationData.alert?.attachment_url, httpUrl.contains("http:"){
                                                   notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: "http:", with: "https:")
                                               }
                                           }
                                           RestAPI.fetcherAdMediationClickApi(bundleName: bundleName, url: notificationData.url ?? "", title: bestAttemptContent.title, rid: notificationData.rid ?? "", callForMedc: false, userInfo: userInfo)
                                           if notificationData.furv != nil {
                                               adMediationRVApiCall(totalData: totalData, jsonDictionary: jsonDictionary)
                                           }
                                       }
                                   }
                               }else{
                                   
                                   if let jsonArray = json as? [[String:Any]] {
                                       if jsonArray[0]["msgCode"] is String {
                                           fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk, notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                           return
                                       }else{
                                           if let title = notificationData.alert?.title, let bodyData = notificationData.alert?.body {
                                               bestAttemptContent.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: title))"
                                               bestAttemptContent.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: bodyData))"
                                           }
                                           if let url = notificationData.url, !url.isEmpty {
                                               notificationData.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: url))"
                                           }
                                           if let urlStr = notificationData.alert?.attachment_url , !urlStr.isEmpty {
                                               notificationData.alert?.attachment_url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: urlStr))"
                                               if let urlStr = notificationData.alert?.attachment_url , urlStr.contains(".webp") {
                                                   notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpg")
                                               }
                                           }
                                           RestAPI.fetcherAdMediationClickApi(bundleName: bundleName, url: notificationData.url ?? "", title: bestAttemptContent.title, rid: notificationData.rid ?? "", callForMedc: false, userInfo: userInfo)
                                       }
                                   }
                               }
                               
                               if notificationData.category != "" && notificationData.category != nil
                               {
                                   storeCategories(notificationData: notificationData, category: "")
                                   if notificationData.act1name != "" && notificationData.act1name != nil{
                                       addCTAButtons()
                                   }
                               }
                               DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                   autoreleasepool {

                                           guard let string = notificationData.alert?.attachment_url else {return}
                                       guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.id, rid: notificationData.rid, imgUrl: notificationData.alert?.attachment_url ?? "", userInfo: userInfo, options: nil) else {
                                               debugPrint(AppConstant.IMAGE_ERROR)
                                               contentHandler!(bestAttemptContent)
                                               return
                                           }
                                           bestAttemptContent.attachments = [ attachment ]
                                   }
                                   if bestAttemptContent.title == notificationData.ankey?.titleAd{
                                       self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk, notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                   }else{
                                       contentHandler!(bestAttemptContent)
                                   }
                               }
                               
                           } catch {
                               self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", flbk: flbk,notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                           }
                       }
                   }.resume()
               }else{
                   Utils.handleOnceException(bundleName: bundleName, exceptionName: "Fetcher url is not in correct format\(String(describing: izUrlString))", className: "DATB", methodName: "commonfetchUrl",rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
               }
           }
       }
    
    //To store category Id & CTA Buttons
    @objc private static func storeCategories(notificationData: Payload, category : String){
        categoryArray.removeAll()
        
        var categoryId = ""
        var button1Name = ""
        var button2Name = ""
        
        if category != ""{
            categoryId = category
            button1Name = "Sponsered"
            
        }else{
            if notificationData.global?.act1name != nil && notificationData.global?.act1name != ""{
                categoryId = notificationData.category ?? ""
                button1Name = notificationData.global!.act1name ?? ""
            }else{
                if notificationData.act1name != "" && notificationData.act1name != nil  {
                    categoryId = notificationData.category ?? ""
                    button1Name = notificationData.act1name ?? ""
                    button2Name = notificationData.act2name ?? ""
                }
            }
        }
        
        let catDict  = [AppConstant.iZ_catId: categoryId , AppConstant.iZ_b1Name:  button1Name, AppConstant.iZ_b2Name: button2Name]
        categoryArray.append(catDict)
        
        var tempArray: [[String : Any]] = []
        if UserDefaults.standard.value(forKey: AppConstant.iZ_CategoryArray) != nil {
            tempArray = UserDefaults.standard.value(forKey: AppConstant.iZ_CategoryArray) as! [[String : Any]]
        }
        let CategoryMaxCount = 100
        tempArray.append(contentsOf: categoryArray)
        if tempArray.count >= CategoryMaxCount{
            tempArray.removeFirst()
        }
        UserDefaults.standard.setValue(tempArray, forKey: AppConstant.iZ_CategoryArray)
        UserDefaults.standard.synchronize()
    }
    
    //To register Dynamic category nd Actionable buttons on notifications...
    @objc private static func addCTAButtons(){
        
        var notificationCategories: Set<UNNotificationCategory> = []
        
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        
        var catArray = [Any]()
        
        if UserDefaults.standard.array(forKey: AppConstant.iZ_CategoryArray)!.count != 0{
            catArray  = UserDefaults.standard.array(forKey: AppConstant.iZ_CategoryArray)!
        }
        
        if !catArray.isEmpty{
            
            for item in catArray{
                let dict = item as? NSDictionary
                let categoryId = dict?.value(forKey: AppConstant.iZ_catId) as? String
                var name1 = dict?.value(forKey: AppConstant.iZ_b1Name) as? String ?? ""
                let name1Id = AppConstant.FIRST_BUTTON
                var name2 = dict?.value(forKey: AppConstant.iZ_b2Name) as? String ?? ""
                let name2Id = AppConstant.SECOND_BUTTON
                
                if name1 != "" && name2 != ""{
                    
                    if name1.count > 17{
                        let mySubstring = name1.prefix(17)
                        name1 = "\(mySubstring)..."
                    }
                    if name2.count > 17{
                        let mySubstring = name2.prefix(17)
                        name2 = "\(mySubstring)..."
                    }
                    
                    let firstAction = UNNotificationAction( identifier: name1Id, title: " \(name1)", options: .foreground)
                    
                    let secondAtion = UNNotificationAction( identifier: name2Id, title: " \(name2)", options: .foreground)
                    
                    let category = UNNotificationCategory( identifier: categoryId!, actions: [firstAction, secondAtion], intentIdentifiers: [], options: [])
                    
                    notificationCategories.insert(category)
                    
                }else{
                    if name1 != ""{
                        if(name1.contains("~"))
                        {
                            name1 = name1.replacingOccurrences(of: "~", with: "")
                        }
                        let firstAction = UNNotificationAction( identifier: name1Id, title: " \(name1)", options: .foreground)
                        let category = UNNotificationCategory( identifier: categoryId!, actions: [firstAction], intentIdentifiers: [], options: [])
                        notificationCategories.insert(category)
                    }
                }
            }
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(granted, error) in
            if !granted {
                print("Notification access denied.")
            }
            center.setNotificationCategories(notificationCategories)
        }
    }
    
    
    
    
    // Fallback Url Call
    @available(iOS 11.0, *)
       @objc private static func fallBackAdsApi(bundleName: String, fallCategory: String,flbk : [String] ,notiRid: String, userInfo: [AnyHashable : Any]?,bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)?){
   //         let str = RestAPI.FALLBACK_URL
           let str = "https://\(flbk[0]).izooto.com/\(flbk[1])"
   //        print("Final Fallback URL : \(str)")
            let izUrlString = (str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            if let url = URL(string: izUrlString ?? "") {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data)
                            if let jsonDictionary = json as? [String:Any] {
                                if let apsDictionary = jsonDictionary as? NSDictionary {
                                    if let notificationData = Payload(dictionary: apsDictionary) {
                                        if let title = jsonDictionary[AppConstant.iZ_T_KEY] as? String {
                                            bestAttemptContent.title = title
                                        }
                                        if let body = jsonDictionary["m"] as? String {
                                            bestAttemptContent.body = body
                                        }
                                        if let url = notificationData.url, !url.isEmpty {
                                            let groupName = "group.\(bundleName).datb"
                                            if let userDefaults = UserDefaults(suiteName: groupName) {
                                                userDefaults.set(url, forKey: "fallBackLandingUrl")
                                                userDefaults.set(bestAttemptContent.title, forKey: "fallBackTitle")
                                            }
                                            if let newUrl = jsonDictionary["bi"] as? String {
                                                notificationData.url = newUrl
                                                if newUrl.contains(".webp") {
                                                    notificationData.url = newUrl.replacingOccurrences(of: ".webp", with: ".jpeg")
                                                }
                                                if newUrl.contains("http:") {
                                                    notificationData.url = newUrl.replacingOccurrences(of: "http:", with: "https:")
                                                }
                                            }
                                        }
                                        if fallCategory != ""{
                                            storeCategories(notificationData: notificationData, category: fallCategory)
                                            if notificationData.act1name != "" && notificationData.act1name != nil{
                                                addCTAButtons()
                                            }
                                        }
                                        //call impression
                                        if let url = notificationData.url {
                                            self.ad_mediationImpressionCall(notiRid: notiRid, adTitle: bestAttemptContent.title, adLn: url, bundleName: bundleName, userInfo: userInfo)
                                        }
                                        RestAPI.fetcherAdMediationClickApi(bundleName: bundleName, url: jsonDictionary["ln"] as? String ?? "", title: jsonDictionary["t"] as? String ?? "", rid: notificationData.rid ?? "", callForMedc: false, userInfo:userInfo)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            autoreleasepool {
                                                guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.id, rid: notificationData.rid, imgUrl: notificationData.url ?? "", userInfo: userInfo, options: nil) else {
                                                        contentHandler!(bestAttemptContent)
                                                        return
                                                    }
                                                    bestAttemptContent.attachments = [ attachment ]
                                            }
                                            contentHandler!(bestAttemptContent)
                                        }
                                    }
                                }
                            }
                        } catch let error {
                            
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "Fallback ad Api error\(error.localizedDescription)", className: "DATB", methodName: "fallBackAdsApi", rid: notiRid , cid: "0", userInfo: userInfo)
                        }
                    }
                    
                }.resume()
            }
        }
        
   // json array parsing
    @objc
    private static func getParseArrayValue(jsonData: [[String: Any]], sourceString: String) -> String {
        if sourceString.contains("~") {
            return sourceString.replacingOccurrences(of: "~", with: "")
        } else {
            if sourceString.contains(".") {  // e.g., [0].title
                let array = sourceString.split(separator: ".")
                
                // Safely unwrap the first element and remove brackets
                if let firstElement = array.first {
                    let value = String(firstElement).replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                    
                    // Safely convert value to an integer and ensure it's within bounds of jsonData
                    if let dataIndex = Int(value), dataIndex < jsonData.count {
                        let data1 = jsonData[dataIndex]
                        
                        // Safely get the last element of the array
                        if let lastElement = array.last {
                            let key = String(lastElement)
                            
                            // Safely access data1 with the key and cast it as a String
                            if let result = data1[key] as? String {
                                return result
                            }
                        }
                    }
                }
            }
        }
        return sourceString
    }

    
    // Check the notification enable or not from device setting
    @objc  public static func checkNotificationEnable()
    {
        let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
        if isNotificationEnabled!{
            debugPrint("enabled notification setting")
        }else{
            
            let alert = UIAlertController(title: "Please enable notifications for \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "APP Name")", message: "To receive these updates,you must first allow to receive \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "APP Name") notification from settings", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: " Not Now", style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Take me there", style: .default, handler: { (action: UIAlertAction!) in
        
            }))
        
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
            
            
            
        }
    }
   
    
    // for jsonObject
        @objc private static func getParseValue(jsonData :[String : Any], sourceString : String) -> String
        {
            if(sourceString.contains("~"))
            {
                return sourceString.replacingOccurrences(of: "~", with: "")
            }
            else
            {
                if(sourceString.contains("."))
                {
                    let array = sourceString.split(separator: ".")
                    let count = array.count
                    if count == 2 {
                        if array.first != nil {
                            if let content = jsonData["\(array[0])"] as? [[String:Any]] {
                                for responseData in content {
                                    if let responseDict = responseData["\(array[1])"] as? String {
                                        return responseDict
                                    }
                                }
                            }
                        }
                    }
                    if count == 3
                    {
                        if array.first != nil {
                            let value = String(array[1])
                            _ =  value.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with:"")
                            if let content = jsonData["\(array[0])"] as? [[String:Any]] {
                                for responseData in content {
                                    if let responseDict = responseData["\(array[2])"] as? String {
                                        return responseDict
                                    }
                                }
                            }
                            else
                            {
                                if let content = jsonData["\(array[0])"] as? [String:Any] {
                                    if let value = content["\(array[1])"] as? [String: Any],
                                       let fvalue = value["\(array[2])"] as? String {
                                        return fvalue
                                    }
                                }
                            }
                        }
                    }
                    if (count == 4){
                        
                        let array = sourceString.split(separator: ".")
                        if let response = jsonData["\(array[0])"] as? [String: Any],
                           let documents = response["\(array[1])"] as? [String: Any],
                           let field = documents["doc"] as? [[String: Any]], !field.isEmpty {
                            
                            if let name = field[0]["\(array[3])"] as? String {
                                return name
                            } else if let nameArray = field[0]["\(array[3])"] as? [String], !nameArray.isEmpty {
                                return nameArray[0]
                            } else {
                                return sourceString
                            }
                        } else {
                            return sourceString
                        }
                    }
                    if (count == 5){
                        if sourceString.contains("list"){
                            let array = sourceString.split(separator: ".")
                            if let response = jsonData["\(array[0])"] as? [[String: Any]], !response.isEmpty,
                               let documents = response.first,
                               let field = documents["\(array[2])"] as? [[String: Any]], !field.isEmpty,
                               let responseField = field[0]["\(array[4])"] as? String {
                                return responseField
                            } else {
                                return sourceString
                            }
                        }
                        else{
                            
                            let array = sourceString.split(separator: ".")
                            if let response = jsonData["\(array[0])"] as? [String: Any],
                               let documents = response["\(array[1])"] as? [String: Any],
                               let field = documents["doc"] as? [[String: Any]], !field.isEmpty,
                               let responseData = field[0]["\(array[3])"] as? [String: Any],
                               let responseField = responseData["\(array[4])"] as? String {
                                return responseField
                            } else {
                                return sourceString
                            }
                        }
                    }
                    if (count == 6)
                    {
                        debugPrint(sourceString)
                    }
                }
                else
                {
                    return sourceString
                }
            }
            return sourceString
        }





    
   
    //to hit & remove the landing Url On click Noti
    @objc private static func ad_mediationLandingUrlOnClick(bundleName : String,anKey: NSArray) -> String{
        var idArray: [[String:Any]] = []
        var landing = ""
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_LN_ID_ARRAY) as? [[String : Any]]{
                idArray = ids
            }
            //for Ln & Id
            for dataaa in anKey {
                if let dict = dataaa as? NSDictionary {
                    let id = dict.value(forKey: AppConstant.iZ_IDKEY) as? String
                    let filterValue = idArray.filter {$0[AppConstant.iZ_IDKEY] as? String == id}
                    if !filterValue.isEmpty{
                        if let value1 = filterValue[0] as? NSDictionary {
                            if let lan = value1.value(forKey: AppConstant.iZ_LNKEY) as? String {
                                landing = lan
                            }
                            if let index = idArray.firstIndex(where: {$0[AppConstant.iZ_LNKEY] as? String == landing }) {
                                idArray.remove(at: index)
                            }
                            userDefaults.setValue(idArray, forKey: AppConstant.iZ_LN_ID_ARRAY)
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
        if landing == ""{
            landing = RestAPI.fallBackLandingUrl
        }
        return landing
    }
    //to hit the Title On click Noti
    @objc private static func ad_mediationTitleOnClick(bundleName : String,anKey: NSArray) -> String{
        var idArray: [[String:Any]] = []
        var title = ""
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_LN_ID_ARRAY) as? [[String : Any]]{
                idArray = ids
            }
            //for Ln & Id
            for dataaa in anKey {
                if let dict = dataaa as? NSDictionary {
                    let id = dict.value(forKey: AppConstant.iZ_IDKEY) as? String
                    let filterValue = idArray.filter {$0[AppConstant.iZ_IDKEY] as? String == id}
                    if !filterValue.isEmpty{
                        if let value1 = filterValue[0] as? NSDictionary {
                            if let titleName = value1.value(forKey: AppConstant.iZ_TITLE_KEY) as? String {
                                title = titleName
                            }
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
        if title == ""{
            title = RestAPI.fallBackTitle
        }
        return title
    }
    

    
    // Parsing the jsonObject
        @objc private static func convertToDictionary(text: String) -> [String: Any]? {
            if let data = text.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch {
                    debugPrint(error.localizedDescription)
                    Utils.handleOnceException(bundleName: "", exceptionName: error.localizedDescription, className: "DATB", methodName: "convertToDictionary", rid: nil, cid: nil, userInfo: nil)
                }
            }
            return nil
        }

    
    
    // Handle the Notification behaviour
    @objc  public static func handleForeGroundNotification(notification : UNNotification,displayNotification : String,completionHandler : @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

        
        let appstate = UIApplication.shared.applicationState
        if (appstate == .active && displayNotification == AppConstant.iZ_KEY_IN_APP_ALERT)
        {
            
            let userInfo = notification.request.content.userInfo
            guard let apsDict = userInfo["aps"] as? NSDictionary else {
                return
            }
            let notificationData = Payload(dictionary: apsDict)
            let alert = UIAlertController(title: notificationData?.alert?.title, message:notificationData?.alert?.body, preferredStyle: UIAlertController.Style.alert)
            if (notificationData?.act1name != nil && notificationData?.act1name != ""){
                alert.addAction(UIAlertAction(title: notificationData?.act1name, style: .default, handler: { (action: UIAlertAction!) in
                }))
            }
            if (notificationData?.act2name != nil && notificationData?.act2name != "")
            {
                alert.addAction(UIAlertAction(title: notificationData?.act2name, style: .default, handler: { (action: UIAlertAction!) in
                    
                    let izUrlStr = notificationData?.act2link?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    if let url = URL(string:izUrlStr ?? "") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url)
                        }
                    }
                }))
            }
            alert.addAction(UIAlertAction(title: AppConstant.iZ_KEY_ALERT_DISMISS, style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        else
        {
            let userInfo = notification.request.content.userInfo
            if let jsonDictionary = userInfo as? [String:Any] {
                if let aps = jsonDictionary["aps"] as? NSDictionary{
                    if aps.value(forKey: AppConstant.iZ_ANKEY) != nil {
                        guard let userInfoData = userInfo["aps"] as? NSDictionary else {
                            return
                        }
                        let notificationData = Payload(dictionary: userInfoData)
                        if notificationData?.ankey != nil {
                            if(notificationData?.ankey?.fetchUrlAd != "" && notificationData?.ankey?.fetchUrlAd != nil)
                            {
                                if(notificationData?.global?.inApp != nil)
                                {


                                    completionHandler([.badge, .alert, .sound])
                                }
                                else
                                {
                                    if(notificationData?.global?.inApp != nil)
                                    {

                                        completionHandler([.badge, .alert, .sound])
                                    }
                                    else
                                    {
                                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "DATB Payload is not exits\(userInfo)", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "handleForeGroundNotification",rid: "",cid : "", userInfo: userInfo)
                                    }
                                }
                            }
                        }
                    }
                    else{
                        guard let aps = userInfo["aps"] as? NSDictionary else {
                            // handle the case where userInfo["aps"] is not a NSDictionary
                            print("Failed to retrieve aps dictionary from userInfo")
                            return
                        }
                        let notificationData = Payload(dictionary: aps)
                        if(notificationData?.fetchurl != "" && notificationData?.fetchurl != nil)
                        {

                            guard let rid = notificationData?.rid, let firstIndex = rid.prefix(1).first else {
                                print("notificationData, rid, or the first character is nil or empty")
                                return
                            }
                            if firstIndex == "6" || firstIndex == "7" {
                               // print("not call back working3")
                            } else {
                                if let unwrappedNotificationData = notificationData {
                                    notificationReceivedDelegate?.onNotificationReceived(payload: unwrappedNotificationData)
                                }
                            }
                            completionHandler([.badge, .alert, .sound])
                        }
                        else
                        {
                            if(notificationData?.created_on != nil)
                            {
                                completionHandler([.badge, .alert, .sound])

                                guard let rid = notificationData?.rid, let firstIndex = rid.prefix(1).first else {
                                    
                                    print("notificationData, rid, or the first character is nil or empty")
                                    return
                                }
                                if firstIndex == "6" || firstIndex == "7" {
                                    print("not call back working3")
                                } else {
                                    if let unwrappedNotificationData = notificationData {
                                        notificationReceivedDelegate?.onNotificationReceived(payload: unwrappedNotificationData)
                                    }
                                }
                            }
                            else
                            {
                                completionHandler([.badge, .alert, .sound])
                            }
                        }
                    }
                }
            }
        }
    }

    
    // handel the fallback url
    @objc public static func fallbackClickHandler(bundleName:String,flbk : [String], cid:String?, rid:String?, userInfo: [AnyHashable : Any]?) {
           
           
           let str = "https://\(flbk[0]).izooto.com/\(flbk[1])"
           
           guard let izUrlString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
               Utils.handleOnceException(bundleName: bundleName, exceptionName: "Error in URL encoding", className: "DATB", methodName: "FallbackClickHandler",rid: rid, cid: cid, userInfo:userInfo)
               return
           }
           
           guard let url = URL(string: izUrlString) else {
               Utils.handleOnceException(bundleName: bundleName, exceptionName: "Error in fallback click API \(izUrlString)", className: "DATB", methodName: "FallbackClickHandler",rid: rid, cid: cid, userInfo: userInfo)
               return
           }
           
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   Utils.handleOnceException(bundleName: bundleName, exceptionName: "Network error: \(error.localizedDescription)", className: "DATB", methodName: "FallbackClickHandler",rid: rid, cid: cid, userInfo: userInfo)
                   return
               }
               guard let data = data else {
                   Utils.handleOnceException(bundleName: bundleName, exceptionName: "No data received", className: "DATB", methodName: "FallbackClickHandler",rid: rid, cid: cid, userInfo: userInfo)
                   return
               }
               do {
                   let json = try JSONSerialization.jsonObject(with: data)
                   if let jsonDictionary = json as? [String: Any],
                      let notificationData = Payload(dictionary: jsonDictionary as NSDictionary),
                      let urlString = notificationData.url, !urlString.isEmpty,
                      let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: encodedUrlString) {

                       let title = jsonDictionary["t"] as? String ?? ""
                       
                       notificationData.url = jsonDictionary[AppConstant.iZ_LNKEY] as? String
                       
                       RestAPI.fetcherAdMediationClickApi(bundleName: bundleName, url: notificationData.url ?? "", title: jsonDictionary["t"] as? String ?? "", rid: notificationData.rid ?? "", callForMedc: true, userInfo: userInfo)
                       guard let encodedUrlString = notificationData.url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                             let url = URL(string: encodedUrlString) else {
                           return
                       }
                   

                       DispatchQueue.main.async {
                           UIApplication.shared.open(url)
                       }
                   }
               } catch let error {
                   Utils.handleOnceException(bundleName: bundleName, exceptionName: "Error in parsing JSON: \(error.localizedDescription)", className: "DATB", methodName: "FallbackClickHandler", rid: rid, cid: cid, userInfo: userInfo)
               }
           }.resume()
       }
    // Handle the clicks the notification from Banner,Button
       @objc public static func notificationHandler(response : UNNotificationResponse)
       {
           let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

           if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)) {
               let badgeC = userDefaults.integer(forKey:"Badge")
               let isBadge = userDefaults.bool(forKey: "isBadge")
              

                if isBadge{
                   self.badgeCount = badgeC-1
                   userDefaults.set(self.badgeCount, forKey:"Badge")
                   if(self.badgeCount == 0)
                   {
                       UIApplication.shared.applicationIconBadgeNumber = -1

                   }else{
                       UIApplication.shared.applicationIconBadgeNumber = self.badgeCount
                   }
               }else{
                   self.badgeCount = 0
                   userDefaults.set(0, forKey:"Badge")
                   UIApplication.shared.applicationIconBadgeNumber = -1
               }
               RestAPI.fallBackLandingUrl = userDefaults.value(forKey: "fallBackLandingUrl") as? String ?? ""
               RestAPI.fallBackTitle = userDefaults.value(forKey: "fallBackTitle") as? String ?? ""
               userDefaults.synchronize()
           }

           
           let userInfo = response.notification.request.content.userInfo
           var adlandingURL:String = ""
           var adTitle:String = ""
           let indexx = 0
           if let jsonDictionary = userInfo as? [String:Any] {
               if let aps = jsonDictionary["aps"] as? NSDictionary{
                   if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                       var finalData = [String: Any]()
                       let tempData = NSMutableDictionary()
                       var alertData = [String: Any]()
                       var gData = [String: Any]()
                       var anData: [[String: Any]] = []
                       
                       if let alert = aps.value(forKey: AppConstant.iZ_ALERTKEY) {
                           if let altData = alert as? [String : Any] {
                               alertData = altData
                           }
                       }
                       if let gt = aps.value(forKey: AppConstant.iZ_G_KEY) as? NSDictionary {
                           if let data = gt as? [String : Any]{
                               gData = data
                           }
                       }
                       if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                           //To get clicked Notification landing Url
                           adTitle = self.ad_mediationTitleOnClick(bundleName: bundleName, anKey: anKey)
                           adlandingURL = self.ad_mediationLandingUrlOnClick(bundleName:bundleName, anKey: anKey)
                           
                           getRcAndHitAPI(bundleName: bundleName, anKey: anKey)
                           if let data = anKey[indexx] as? [String : Any] {
                               anData = [data]
                           }
                           tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                           tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                           tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                           
                           tempData.setValue(1, forKey: "mutable-content")
                           tempData.setValue(0, forKey: "content_available")
                           
                           finalData["aps"] = tempData
                       }
                       guard let finalApsData = finalData["aps"] as? NSDictionary else {
                           return
                       }
                       let notificationData = Payload(dictionary: finalApsData)
                       let notiRid = notificationData?.global?.rid
                       //for rid & bids call Ad-mediation click
                       self.ad_mediationClickCall(notiRid: notiRid ?? "", adTitle: adTitle, adLn: adlandingURL, userInfo: userInfo)
                       
                       if notificationData?.ankey != nil{
                           if notificationData?.category != nil && notificationData?.category != ""
                           {
                               if response.actionIdentifier == AppConstant.FIRST_BUTTON{
                                   type = "1"
                               }
                           }
                           if let notiData = notificationData {
                               clickTrack(bundleName: bundleName,notificationData: notiData, actionType: type, userInfo: userInfo, globalLn: adlandingURL, title: adTitle)
                           }
                           if adlandingURL != ""
                           {
                               if let unencodedURLString = adlandingURL.removingPercentEncoding {
                                   if let encodedURLString = unencodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                       adlandingURL = encodedURLString
                                   }
                               } else {
                                   if let url = adlandingURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                                       adlandingURL = url
                                   }
                               }
                               if let url = URL(string: adlandingURL) {
                                   DispatchQueue.main.async {
                                       UIApplication.shared.open(url)
                                   }
                               }else{
                                   print("")
                               }
                           }else{
                               Utils.handleOnceException(bundleName: bundleName, exceptionName: "Mediation LandingUrl is blank", className: "DATB", methodName: "notificationHandler",rid: notiRid, cid: notificationData?.global?.id, userInfo: userInfo)
                           }
                       }
                   }else{
                       guard let aps = userInfo["aps"] as? NSDictionary else {
                           // handle the case where userInfo["aps"] is not a NSDictionary
                           print("Failed to retrieve aps dictionary from userInfo")
                           return
                       }
                       
                       guard let notificationData = Payload(dictionary: aps) else {
                           return
                       }

                       if notificationData.created_on != nil{

                           
                           if notificationData.fetchurl != nil && notificationData.fetchurl != ""
                           {
                               let fsd = (aps["fsd"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "flbk"
                               let fbu = (aps["fbu"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "default.json"
                               let flbk = [fsd.isEmpty ? "flbk" : fsd, fbu.isEmpty ? "default.json" : fbu]
                               
                               if notificationData.category != nil && notificationData.category != ""
                               {
                                   if response.actionIdentifier == AppConstant.FIRST_BUTTON{
                                       type = "1"
                                       
                                   }
                               }
                               guard let fetchUrl = notificationData.fetchurl,
                                     let encodedUrlString = fetchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                                   return
                               }
                               let izUrlString = encodedUrlString
                               
                               let session: URLSession = {
                                   let configuration = URLSessionConfiguration.default
                                   configuration.timeoutIntervalForRequest = 2
                                   return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                               }()
                               if let url = URL(string: izUrlString)
                               {
                                   session.dataTask(with: url) { data, response, error in
                                       if error != nil{
                                           self.fallbackClickHandler(bundleName: bundleName, flbk: flbk, cid: notificationData.id, rid: notificationData.rid, userInfo: userInfo)
                                       }
                                       if let httpResponse = response as? HTTPURLResponse {
                                           if httpResponse.statusCode != 200 {
                                               self.fallbackClickHandler(bundleName: bundleName, flbk: flbk, cid: notificationData.id, rid: notificationData.rid, userInfo: userInfo)
                                               return
                                           }
                                       }
                                       if let data = data {
                                           do {
                                               let json = try JSONSerialization.jsonObject(with: data)
                                               //To Check FallBack
                                               if let jsonDictionary = json as? [String:Any] {
                                                   if let value = jsonDictionary["msgCode"] as? String {
                                                       self.fallbackClickHandler(bundleName: bundleName, flbk: flbk,cid: notificationData.id,rid: notificationData.rid, userInfo: userInfo)
                                                   }else{
                                                       if let jsonDictionary = json as? [String:Any] {
                                                           if let title = notificationData.alert?.title {
                                                               let adTitle = "\(getParseValue(jsonData: jsonDictionary, sourceString: title))"
                                                               if notificationData.url != "" {
                                                                   notificationData.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.url ?? "no url")))"
                                                                   
                                                                   var iZfetchUrl = notificationData.url
                                                                   clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo, globalLn: iZfetchUrl ?? "", title: adTitle)
                                                                   RestAPI.fetcherAdMediationClickApi(bundleName: bundleName, url: iZfetchUrl ?? "", title: adTitle, rid: notificationData.rid ?? "", callForMedc: true, userInfo: userInfo)
                                                                   if let unencodedURLString = iZfetchUrl?.removingPercentEncoding {
                                                                       iZfetchUrl = unencodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                                   } else {
                                                                       iZfetchUrl = iZfetchUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                                   }
                                                                   
                                                                   if let url = URL(string: iZfetchUrl!) {
                                                                       DispatchQueue.main.async {
                                                                           UIApplication.shared.open(url)
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                           if notificationData.furc != nil{
                                                               var tempArray = [String]()
                                                               if let rcValue = aps.value(forKey: "rc") as? NSArray {
                                                                   for value in rcValue{
                                                                       if let val = value as? String {
                                                                           let finalRC = "\(getParseValue(jsonData: jsonDictionary , sourceString: val))"
                                                                           tempArray.append(finalRC)
                                                                       }
                                                                   }
                                                                   for valuee in tempArray{
                                                                       RestAPI.callRV_RC_Request(urlString: valuee)
                                                                   }
                                                                   tempArray.removeAll()
                                                               }
                                                           }
                                                       }
                                                   }
                                               }
                                               else
                                               {
                                                   if let jsonArray = json as? [[String:Any]] {
                                                       if jsonArray[0]["msgCode"] is String {
                                                           self.fallbackClickHandler(bundleName: bundleName, flbk: flbk, cid: notificationData.id,rid: notificationData.rid, userInfo: userInfo)
                                                           return
                                                       }else{
                                                           
                                                           if notificationData.url != "" {
                                                               
                                                               if let title = notificationData.alert?.title {
                                                                   notificationData.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: notificationData.url ?? ""))"
                                                                   adTitle = "\(getParseArrayValue(jsonData: jsonArray, sourceString: title))"
                                                                   let izUrlStr = notificationData.url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                                   clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo, globalLn: izUrlStr ?? "",title: adTitle)
                                                                   
                                                                   RestAPI.fetcherAdMediationClickApi(bundleName: bundleName, url: izUrlStr ?? "", title: adTitle, rid: notificationData.rid ?? "", callForMedc: true, userInfo: userInfo)
                                                                   if let url = URL(string: izUrlStr ?? "") {
                                                                       DispatchQueue.main.async {
                                                                           UIApplication.shared.open(url)
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                       }
                                                   }
                                               }
                                           } catch let error {
                                               debugPrint(AppConstant.TAG,error)
                                               //FallBack_Click Handler method.....
                                               self.fallbackClickHandler(bundleName: bundleName, flbk: flbk,cid: notificationData.id,rid: notificationData.rid, userInfo: userInfo)
                                               let rid = (notificationData.rid) ?? ""
                                               Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription, className: "DATB", methodName: "notificationHandler",rid: rid, cid: notificationData.rid, userInfo: userInfo)
                                           }
                                       }
                                   }.resume()
                               }
                           }
                           else
                           {
                               if notificationData.category != nil && notificationData.category != ""
                               {
                                   if response.actionIdentifier == AppConstant.FIRST_BUTTON{
                                       
                                       type = "1"
                                       clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo, globalLn: "", title: notificationData.alert?.title ?? "")
                                       
                                       if notificationData.ap != "" && notificationData.ap != nil
                                       {
                                           handleClicks(response: response, actionType: type)
                                       }
                                       else
                                       {
                                           if notificationData.act1link != nil && notificationData.act1link != ""
                                           {
                                               let launchURl = notificationData.act1link!
                                               if launchURl.contains("tel:")
                                               {
                                                   if let url = URL(string: launchURl)
                                                   {
                                                       UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                                   }
                                               }
                                               else
                                               {
                                                   if let inApp = notificationData.inApp, inApp.contains("1"), !inApp.isEmpty, let act1link = notificationData.act1link, !act1link.isEmpty {
                                                       // Your code here
                                                       if let checkWebview = sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW),
                                                          let act1link = notificationData.act1link {

                                                           if checkWebview {
                                                               landingURLDelegate?.onHandleLandingURL(url: act1link)
                                                           } else {
                                                               ViewController.seriveURL = act1link
                                                               if let keyWindow = UIApplication.shared.keyWindow {
                                                                   keyWindow.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                               }
                                                           }
                                                       }
                                                   }
                                                   else if let inApp = notificationData.inApp, inApp.contains("0"), !inApp.isEmpty, let act1link = notificationData.act1link, !act1link.isEmpty
                                                   {
                                                       handleBroserNotification(url: act1link)
                                                   }
                                               }
                                           }
                                       }
                                   }
                                   else if response.actionIdentifier == AppConstant.SECOND_BUTTON{
                                       type = "2"
                                       clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo, globalLn: "", title: notificationData.alert?.title ?? "")
                                       
                                       if notificationData.ap != "" && notificationData.ap != nil
                                       {
                                           handleClicks(response: response, actionType: type)
                                       }
                                       else
                                       {
                                           if notificationData.act2link != nil && notificationData.act2link != ""
                                           {
                                               guard let launchURl = notificationData.act2link else {return}
                                               if launchURl.contains("tel:")
                                               {
                                                   if let url = URL(string: launchURl)
                                                   {
                                                       UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                                   }
                                               }
                                               else
                                               {
                                                   if let inApp = notificationData.inApp, inApp.contains("1"), !inApp.isEmpty,
                                                      let act2link = notificationData.act2link, !act2link.isEmpty {
                                                      
                                                       if let checkWebview = sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW) {
                                                           if checkWebview {
                                                               landingURLDelegate?.onHandleLandingURL(url: act2link)
                                                           } else {
                                                               ViewController.seriveURL = act2link
                                                               if let keyWindow = UIApplication.shared.keyWindow {
                                                                   keyWindow.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                               }
                                                           }
                                                       }
                                                   }
                                                   else if let inApp = notificationData.inApp, inApp.contains("0"), !inApp.isEmpty,
                                                           let act2link = notificationData.act2link, !act2link.isEmpty
                                                   {
                                                       handleBroserNotification(url: act2link)
                                                   }
                                               }
                                           }
                                       }
                                   }else{
                                       type = "0"
                                       clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo, globalLn: "", title: notificationData.alert?.title ?? "")
                                       if notificationData.ap != "" && notificationData.ap != nil
                                       {
                                           handleClicks(response: response, actionType: type)
                                       }
                                       else{
                                           if let inApp = notificationData.inApp, inApp.contains("1"), !inApp.isEmpty,
                                              let url = notificationData.url, !url.isEmpty {
                                               if let checkWebview = sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW) {
                                                   if checkWebview {
                                                       landingURLDelegate?.onHandleLandingURL(url: url)
                                                   } else {
                                                       ViewController.seriveURL = url
                                                       if let keyWindow = UIApplication.shared.keyWindow {
                                                           keyWindow.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                       }
                                                   }
                                               }
                                           }
                                           else if let inApp = notificationData.inApp, inApp.contains("0"), !inApp.isEmpty,
                                                   let url = notificationData.url, !url.isEmpty{
                                               handleBroserNotification(url: url)
                                           }
                                       }
                                   }
                               }else{
                                   type = "0"
                                   clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo,globalLn: "", title: notificationData.alert?.title ?? "")
                                   if notificationData.ap != "" && notificationData.ap != nil
                                   {
                                       handleClicks(response: response, actionType: type)
                                   }
                                   else{
                                       if let inApp = notificationData.inApp, inApp.contains("1"), !inApp.isEmpty,
                                              let url = notificationData.url,!url.isEmpty
                                       {
                                           if let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW)){
                                               if checkWebview
                                               {
                                                   if let url = notificationData.url{
                                                       landingURLDelegate?.onHandleLandingURL(url: url)
                                                   }
                                               }
                                               else
                                               {
                                                   ViewController.seriveURL = notificationData.url
                                                   UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                               }
                                           }
                                       }
                                       else if let inApp = notificationData.inApp, inApp.contains("0"), !inApp.isEmpty,
                                               let url = notificationData.url,!url.isEmpty
                                       {
                                           handleBroserNotification(url: url)
                                       }
                                   }
                               }
                           }
                       }
                       else
                       {
                           print("other payload data")
                       }
                   }
               }
           }
       }
    
    
   
    
    //for hit & remove the landing Url On click Noti
    
    
    @objc private static func storeNotiUrl_ln(bundleName: String){
        let groupName = "group."+bundleName+".datb"
        if let userDefaults = UserDefaults(suiteName: groupName) {
            var tempArray: [[String : Any]] = []
            if userDefaults.value(forKey: AppConstant.iZ_LN_ID_ARRAY) != nil {
                tempArray = userDefaults.value(forKey: AppConstant.iZ_LN_ID_ARRAY) as! [[String : Any]]
            }
            tempArray.append(contentsOf: myIdLnArray)
            userDefaults.setValue(tempArray, forKey: AppConstant.iZ_LN_ID_ARRAY)
            userDefaults.synchronize()
        }
    }
    
    @objc private static func storeBids(bundleName: String, finalData: NSMutableDictionary){
        let groupName = "group."+bundleName+".datb"
        if let userDefaults = UserDefaults(suiteName: groupName) {
            var tempArray: [[String : Any]] = []
            if userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) != nil {
                tempArray = userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as! [[String : Any]]
            }
            tempArray.append(finalData as! [String : Any])
            userDefaults.setValue(tempArray, forKey: AppConstant.iZ_BIDS_SERVED_ARRAY)
            userDefaults.synchronize()
        }
    }
    
    //hit RV with notificatiuon display on devices
    @objc private static func adMediationRVApiCall(totalData: NSDictionary,jsonDictionary: [String:Any] ){
        
        var tempArray = [String]()
        if let annKey = totalData.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
            
            if  let rvValue = annKey.value(forKey: "rv") as? NSArray {
                
                let finalValue = rvValue[0] as! NSArray
                
                for value in finalValue{
                    
                    let finalRV = "\(getParseValue(jsonData: jsonDictionary , sourceString: value as! String))"
                    tempArray.append(finalRV)
                }
                for valuee in tempArray{
                    RestAPI.callRV_RC_Request(urlString: valuee)
                }
                tempArray.removeAll()
            }
        }else{
            if let rvValue = totalData.value(forKey: "rv") as? NSArray {
                
                for value in rvValue{
                    let finalRV = "\(getParseValue(jsonData: jsonDictionary , sourceString: value as! String))"
                    tempArray.append(finalRV)
                }
                for valuee in tempArray{
                    RestAPI.callRV_RC_Request(urlString: valuee)
                }
                tempArray.removeAll()
            }
        }
    }
    
    
    
    //Store RC with notificatiuon appear & hit on noti clicked by user
    @objc private static func adMediationRCDataStore(totalData: NSDictionary,jsonDictionary: [String:Any], bundleName: String, aDId: String){
        
        var temArray = [String]()
        if let annKey = totalData.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
            
            if  let rvValue = annKey.value(forKey: "rc") as? NSArray {
                
                let finalValue = rvValue[0] as! NSArray
                myRCArray.removeAll()
                for value in finalValue{
                    
                    let finalRC = "\(getParseValue(jsonData: jsonDictionary , sourceString: value as! String))"
                    temArray.append(finalRC)
                    
                }
                let dict = ["id": aDId, "rc": temArray] as [String : Any]
                myRCArray.append(dict)
                
                let groupName = "group."+bundleName+".datb"
                if let userDefaults = UserDefaults(suiteName: groupName) {
                    var tempArray: [[String : Any]] = []
                    if userDefaults.value(forKey: AppConstant.iZ_rcArray) != nil {
                        tempArray = userDefaults.value(forKey: AppConstant.iZ_rcArray) as! [[String : Any]]
                    }
                    tempArray.append(contentsOf: myRCArray)
                    userDefaults.setValue(tempArray, forKey: AppConstant.iZ_rcArray)
                    userDefaults.synchronize()
                }
            }
        }
    }
    
    
    //Hit the RC on click Notification
    @objc private static func getRcAndHitAPI(bundleName : String,anKey: NSArray){
        var idArray: [[String:Any]] = []
        var rcArray: NSArray = []
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_rcArray) as? [[String : Any]]{
                idArray = ids
            }
            //for Ln & Id
            for dataaa in anKey {
                if let dict = dataaa as? NSDictionary {
                    let id = dict.value(forKey: AppConstant.iZ_IDKEY) as? String
                    let filterValue = idArray.filter {$0[AppConstant.iZ_IDKEY] as? String == id}
                    
                    if !filterValue.isEmpty{
                        if let value1 = filterValue[0] as? NSDictionary {
                            rcArray = value1.value(forKey: "rc") as! NSArray
                            let iddd = value1.value(forKey: AppConstant.iZ_IDKEY) as! String
                            if let index = idArray.firstIndex(where: {$0[AppConstant.iZ_IDKEY] as? String  == iddd }) {
                                idArray.remove(at: index)
                            }
                            userDefaults.setValue(idArray, forKey: AppConstant.iZ_rcArray)
                            userDefaults.synchronize()
                        }
                    }
                    
                    for valuee in rcArray{
                        RestAPI.callRV_RC_Request(urlString: valuee as! String)
                    }
                    
                    break
                }
            }
        }
    }
    
    
    // Fetching the Advertisement ID
    @objc  public static  func identifierForAdvertising() -> String? {
        // check if advertising tracking is enabled in user’s setting
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return "Not Found"
        }
    }
    
    
    // Handle the InApp/Webview// and landing url listener
    @objc static func onHandleInAPP(response : UNNotificationResponse , actionType : String,launchURL : String)
           {
               let userInfo = response.notification.request.content.userInfo
               if let apsDict = userInfo["aps"] as? NSDictionary {
                   let notifcationData = Payload(dictionary: apsDict)
                   
                   if let inApp = notifcationData?.inApp, inApp.contains("1"), !inApp.isEmpty {
                       ViewController.seriveURL = notifcationData?.url
                       if let keyWindow = UIApplication.shared.keyWindow, let rootViewController = keyWindow.rootViewController {
                           rootViewController.present(ViewController(), animated: true, completion: nil)
                       }
                   } else {
                       onHandleLandingURL(response: response, actionType: actionType, launchURL: launchURL)
                   }
               } else {
                   onHandleLandingURL(response: response, actionType: actionType, launchURL: launchURL)
               }
           }
    
    // handle the borwser
         @objc  static func onHandleLandingURL(response : UNNotificationResponse , actionType : String,launchURL : String)
         {
             let userInfo = response.notification.request.content.userInfo
             if let apsDictionary = userInfo["aps"] as? NSDictionary {
                 let notifcationData = Payload(dictionary: apsDictionary)
                 if let inAppValue = notifcationData?.inApp, inAppValue.contains("0"), !inAppValue.isEmpty {
                     handleBroserNotification(url: launchURL)
                 }
             } else {
                 print("Failed to create Payload from userInfo.")
             }
         }
    
    /*
            - setNotificationEnable
            - isSubscribe -> true - Notification received and regsiter a devcie token
            ->isSubscribe -> false - Device token unregistered
            iOS SDK- Exposed a new method for handle the notification subscribe/unsubscribe
            */
           
           @objc public static func setSubscription(isSubscribe : Bool)
           {
               if(isSubscribe)
               {
                   UIApplication.shared.registerForRemoteNotifications()
               }
               else
               {
                   UIApplication.shared.unregisterForRemoteNotifications()
               }
           }
    // handle the addtional data
    @objc public static func handleClicks(response : UNNotificationResponse , actionType : String)
    {
        let userInfo = response.notification.request.content.userInfo
        let notifcationData = Payload(dictionary: (userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary)!)
        var data = Dictionary<String,Any>()
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_ID] = notifcationData?.act1id ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_TITLE] = notifcationData?.act1name ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_URL] = notifcationData?.act1link ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_ADDITIONAL_DATA] = notifcationData?.ap ?? ""
        data[AppConstant.iZ_KEY_DEEP_LINK_LANDING_URL] = notifcationData?.url ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_ID] = notifcationData?.act2id ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_TITLE] = notifcationData?.act2name ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_URL] = notifcationData?.act2link ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_ACTION_TYPE] = actionType
        notificationOpenDelegate?.onNotificationOpen(action: data)
    }


  
// handle impression
    
  
  

    private  static func handleImpresseionCfgValue(cfgNumber: Int , notificationData : Payload,bundleName : String, isSilentPush: Bool, userInfo: [AnyHashable : Any]?)
       {
           var pid = ""
           var token = ""
           if let userDefault = UserDefaults(suiteName: Utils.getBundleName(bundleName: bundleName)){
               pid = userDefault.value(forKey: AppConstant.REGISTERED_ID) as? String ?? ""
               token = userDefault.value(forKey: AppConstant.IZ_GRPS_TKN) as? String ?? ""
           }
           
           let binaryString = String(cfgNumber, radix: 2)
           let firstDigit = Double(binaryString)?.getDigit(digit: 1.0) ?? 0
           let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
           let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
           let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
           let seventhDigit = Double(binaryString)?.getDigit(digit: 7.0) ?? 0
           let ninthDigit = Double(binaryString)?.getDigit(digit: 9.0) ?? 0
           let eleventhDigit = Double(binaryString)?.getDigit(digit: 11.0) ?? 0
           let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
           guard let convertBinaryToDecimal = Int(domainURL, radix: 2) else {
               return
           }
           if(firstDigit == 1)
           {
               if(eleventhDigit == 1)
               {
                  RestAPI.callMoMagicImpression(notificationData: notificationData,pid: pid,token: token, bundleName: bundleName, isSilentPush: isSilentPush, userInfo: userInfo)

               }
               else{
                   RestAPI.callImpression(notificationData: notificationData,pid: pid,token: token, bundleName: bundleName, isSilentPush: isSilentPush, userInfo: userInfo)
               }
           }
           
         
           if(seventhDigit == 1)
           {
               let date = Date()
               let format = DateFormatter()
               format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
               let formattedDate = format.string(from: date)
               if(ninthDigit == 1 && seventhDigit == 1)
               {
                   if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW))
                   {
                       sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW)
                       
                       if convertBinaryToDecimal != 0{
                           
                           let url = "https://lim"+"\(convertBinaryToDecimal)"+".izooto.com/lim"+"\(convertBinaryToDecimal)"
                           RestAPI.lastImpression(notificationData: notificationData,pid:pid,token: token,url: url, bundleName: bundleName, userInfo: userInfo)
                           
                       }
                       else
                       {
                           RestAPI.lastImpression(notificationData: notificationData,pid: pid,token:token,url: RestAPI.LASTNOTIFICATIONVIEWURL,bundleName:bundleName, userInfo: userInfo)
                       }
                   }
               }
               if(ninthDigit == 0 && seventhDigit == 1)
               {
                   if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW_WEEKLY) && Date().dayOfWeek() == sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)){
                       sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW_WEEKLY)
                       sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)
                       if convertBinaryToDecimal != 0{
                           
                           let url = "https://lim"+"\(convertBinaryToDecimal)"+".izooto.com/lim"+"\(convertBinaryToDecimal)"
                           RestAPI.lastImpression(notificationData: notificationData,pid:pid,token: token,url: url,bundleName:bundleName, userInfo: userInfo)
                       }
                       else
                       {
                           RestAPI.lastImpression(notificationData: notificationData,pid: pid,token:token,url: RestAPI.LASTNOTIFICATIONVIEWURL,bundleName:bundleName, userInfo: userInfo)
                       }
                   }
               }
               
           }
       }
    @objc public static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
 //tracking click
    
    @objc static func clickTrack(bundleName : String,notificationData : Payload,actionType : String, userInfo: [AnyHashable: Any], globalLn : String,title : String)
          {
              
              
              let pid = Utils.getUserId(bundleName: bundleName) ?? ""
              let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
              guard notificationData.cfg != nil || notificationData.global?.cfg != nil else {
                  Utils.handleOnceException(bundleName: bundleName, exceptionName: "Both cfg values are nil.", className: "DATB", methodName: "ClickTrack",rid: ((notificationData.rid) ?? (notificationData.global?.rid)), cid: ((notificationData.id) ?? (notificationData.global?.id)), userInfo: userInfo)
                  return
              }
              if(notificationData.cfg != nil){
                  guard let number = Int(notificationData.cfg ?? "0") else {
                      print("Failed to convert cfg to Int.")
                      return
                  }
                  let binaryString = String(number, radix: 2)
                  let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                  let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                  let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                  let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                  let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                  let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                  let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                  guard let convertBinaryToDecimal = Int(domainURL, radix: 2) else { return }
                  if(secondDigit == 1)
                  {
                      RestAPI.clickTrack(bundleName: bundleName, notificationData: notificationData, type: actionType,pid: pid,token:token, userInfo: userInfo, globalLn: globalLn, title: title)
                  }
                  if eighthDigit == 1
                  {
                      let date = Date()
                      let format = DateFormatter()
                      format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                      let formattedDate = format.string(from: date)
                      if(tenthDigit == 1 && eighthDigit == 1){
                          let date = Date()
                          let format = DateFormatter()
                          format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                          let formattedDate = format.string(from: date)
                          if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK))
                          {
                              sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK)
                              if convertBinaryToDecimal != 0{
                                  let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                  RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid: pid,token: token,url: url, userInfo: userInfo )
                              }
                              else
                              {
                                  RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid:pid,token: token,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                              }
                          }
                      }
                      if(tenthDigit == 0 && eighthDigit == 1)
                      {
                          if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKLY) && Date().dayOfWeek() == sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)){
                              sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK_WEEKLY)
                              sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)
                              if convertBinaryToDecimal != 0{
                                  let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                  RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid:pid,token:token,url: url, userInfo: userInfo )
                              }
                              else
                              {
                                  RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid:pid,token: token,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                              }
                          }
                      }
                  }
              }else if(notificationData.global?.cfg != nil ){
                  guard let number = Int(notificationData.global?.cfg ?? "0") else {
                      // Handle the case where the conversion to Int fails
                      // For example, you can print an error message, log, or return
                      print("Failed to convert global.cfg to Int.")
                      return
                  }
                  let binaryString = String(number, radix: 2)
                  let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                  let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                  let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                  let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                  if(secondDigit == 1)
                  {
                      RestAPI.clickTrack(bundleName: bundleName, notificationData: notificationData, type: actionType,pid:pid,token: token, userInfo: userInfo, globalLn: globalLn, title: title)
                  }
                  if eighthDigit == 1
                  {
                      guard let cfg = notificationData.cfg, let number = Int(cfg) else {
                          print("Invalid cfg value")
                          return
                      }
                      let binaryString = String(number, radix: 2)
                      let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                      let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                      let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                      let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                      let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                      let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                      
                      let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                      guard let convertBinaryToDecimal = Int(domainURL, radix: 2) else { return }
                      if(secondDigit == 1)
                      {
                          RestAPI.clickTrack(bundleName: bundleName, notificationData: notificationData, type: actionType,pid: pid,token: token, userInfo: userInfo, globalLn: globalLn, title: title)
                      }
                      if eighthDigit == 1
                      {
                          let date = Date()
                          let format = DateFormatter()
                          format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                          let formattedDate = format.string(from: date)
                          if(tenthDigit == 1 && eighthDigit == 1){
                              let date = Date()
                              let format = DateFormatter()
                              format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                              let formattedDate = format.string(from: date)
                              if(tenthDigit == 1 && eighthDigit == 1){
                                  let date = Date()
                                  let format = DateFormatter()
                                  format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                                  let formattedDate = format.string(from: date)
                                  if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK))
                                  {
                                      sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK)
                                      
                                      if convertBinaryToDecimal != 0{
                                          let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                          RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid: pid,token: token,url: url, userInfo: userInfo )
                                      }
                                      else
                                      {
                                          RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid: pid,token: token,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                                      }
                                  }
                              }
                              if(tenthDigit == 0 && eighthDigit == 1)
                              {
                                  if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKLY) && Date().dayOfWeek() == sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)){
                                      sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK_WEEKLY)
                                      sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)
                                      if convertBinaryToDecimal != 0{
                                          let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                          RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid:pid,token: token,url: url, userInfo: userInfo)
                                      }
                                      else
                                      {
                                          RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid:pid,token: token,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                                      }
                                  }
                              }
                          }
                          if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK))
                          {
                              sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK)
                              
                              if convertBinaryToDecimal != 0{
                                  let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                  RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid: pid,token: token,url: url, userInfo: userInfo )
                              }
                              else
                              {
                                  RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid:pid,token: token,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                              }
                          }
                      }
                  }
              }
              else
              {
                  Utils.handleOnceException(bundleName: bundleName, exceptionName: "No CFG Key defined \(userInfo)", className: "DATB", methodName: "ClickTrack", rid: ((notificationData.rid) ?? (notificationData.global?.rid)), cid: ((notificationData.id) ?? (notificationData.global?.id)), userInfo: userInfo)
              }
          }
    
    // Add Event Functionality
    @objc  public static func addEvent(eventName : String , data : Dictionary<String,Any>)
    {
        
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        if  eventName != ""{
            let returnData = Utils.dataValidate(data: data)
            if let theJSONData = try?  JSONSerialization.data(withJSONObject: returnData,options: .fragmentsAllowed),
               let validateData = NSString(data: theJSONData,
                                           encoding: String.Encoding.utf8.rawValue) {
                let pid = Utils.getUserId(bundleName: bundleName) ?? ""
                let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
                if (token != "" && !token.isEmpty)
                {
                    
                    RestAPI.callEvents(eventName: Utils.eventValidate(eventName: eventName), data: validateData as NSString, pid: pid, token: token)
                }
                
            }
        }
        
    }
    
    
    // Add User Properties
    @objc public static func addUserProperties(data: [String: Any]) {
        // Validate data
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

        let returnData = Utils.dataValidate(data: data)
        
        do {
            // Convert validated data to JSON
            let theJSONData = try JSONSerialization.data(withJSONObject: returnData, options: .fragmentsAllowed)
            
            // Convert JSON data to a string
            guard let validationData = NSString(data: theJSONData, encoding: String.Encoding.utf8.rawValue) else {
                print("Failed to convert JSON data to string.")
                return
            }
            
            let pid = Utils.getUserId(bundleName: bundleName) ?? ""
            let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
            
            // Call API
            RestAPI.callUserProperties(bundleName: bundleName, data: validationData, pid: pid, token: token)
            
        } catch {
            print("JSON serialization error: \(error.localizedDescription)")
        }
    }

    // promptForPushNotifications
    
    @objc public  static  func promptForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
        }
        if #available(iOS 10.0, *) {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
                print(AppConstant.PERMISSION_GRANTED ,"\(granted)")
                guard granted else { return }
                getNotificationSettings()
                
                
            }
            
        }
    }
    
    @objc private static func handleBroserNotification(url : String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let izUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let izUrl = URL(string: izUrlString!) {
                UIApplication.shared.open(izUrl)
            }
        }
    }
    
    @objc  public  static  func setSubscriberID(subscriberID: String) {
    
        guard subscriberID != "" else {
                  print("Subscriber Id should not be blank")
                  return
              }
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

        let pid = Utils.getUserId(bundleName: bundleName) ?? ""
        let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
              if(subscriberID != (sharedUserDefault?.string(forKey: SharedUserDefault.Key.subscriberID)))
              {
                  sharedUserDefault?.set(subscriberID, forKey: SharedUserDefault.Key.subscriberID)
                  RestAPI.setSubscriberID(bundleName: bundleName, subscriberID: subscriberID, pid: pid, token: token)
                  

              }
              else{
                  print("subscriberID id already exits")
              }
    }
    //All Notification Data
       @objc public static func getNotificationFeed(isPagination: Bool,completion: @escaping (String?, Error?) -> Void){
           let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

           if let userID = Utils.getUserId(bundleName: bundleName), let token = Utils.getUserDeviceToken(bundleName: bundleName){
               RestAPI.fetchDataFromAPI(isPagination: isPagination,iZPID: userID) { (jsonString, error) in
                   if let error = error {
                       debugPrint(error)
                       completion("No more data", nil)
                   } else if let jsonString = jsonString {
                       completion(jsonString, nil)
                   }
               }
           }else{
               completion("Feed data is not enable, kindly contact to support team.", nil)
           }
       }

    
}

// Handle banner imange uploading and deleting
@available(iOS 11.0, *)
@available(iOSApplicationExtension 11.0, *)
extension UNNotificationAttachment {
    
    static func saveImageToDisk(bundleName : String ,cid: String?, rid: String?, imgUrl: String, userInfo: [AnyHashable: Any]?, options: [NSObject: AnyObject]?) -> UNNotificationAttachment? {
        
        // Step 1: Convert `mediaUrl` to a `URL` object.
        guard let url = URL(string: imgUrl) else {
            print("Invalid URL string: \(imgUrl)")
            return nil
        }
        
        do {
            // Step 2: Download the media data from the given URL.
            let mediaData = try Data(contentsOf: url) as NSData
            
            // Step 3: Create a unique temporary folder.
            let fileManager = FileManager.default
            let folderName = ProcessInfo.processInfo.globallyUniqueString
            let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            
            // Step 4: Dynamically determine the file extension based on URL.
            let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension  // Default to "jpg" if no extension.
            
            // Check if the file is an image or video.
            let isVideo = fileExtension.lowercased() == "mp4" || fileExtension.lowercased() == "mov"
            
            // Step 5: Generate a unique file name based on type.
            let uniqueIdentifier = UUID().uuidString + "." + fileExtension
            
            // Step 6: Create the file URL inside the temporary folder.
            let fileURL = folderURL?.appendingPathComponent(uniqueIdentifier)
            
            // Step 7: Write the media data (image or video) to the file.
            try mediaData.write(to: fileURL!, options: [])
            
            // Step 8: Create a `UNNotificationAttachment` object using the saved file.
            let attachment = try UNNotificationAttachment(identifier: uniqueIdentifier, url: fileURL!, options: options)
            
            // Step 9: Return the created attachment.
            return attachment
            
        } catch let error {
            // Handle any errors that occur during file creation or data writing.
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "mediaUrl : \(imgUrl) ErrorMessage : \(error.localizedDescription)", className: AppConstant.IZ_TAG, methodName: "saveMediaToDisk", rid: rid, cid: cid, userInfo: userInfo)
            print("Error saving media to disk: \(error.localizedDescription)")
        }
        
        return nil
    }
    
}

@objc public protocol LandingURLDelegate : NSObjectProtocol
{
    @objc func onHandleLandingURL(url : String)
}
@objc public protocol NotificationReceiveDelegate : NSObjectProtocol
{
    @objc func onNotificationReceived(payload : Payload)
}
@objc public protocol NotificationOpenDelegate : NSObjectProtocol
{
    @objc func onNotificationOpen(action : Dictionary<String,Any>)
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(string: key), value)})
}
// handle the Encyption /Decrption functionality
extension String {
    /// Encode a String to Base64
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Decode a String from Base64. Returns nil if unsuccessful.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
extension String {
    var containsSpecialCharacter: Bool {
        let regex = ".*[^A-Za-z0-9].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
}
extension Double {
    func getDigit(digit: Double) -> Int{
        let power = Int(pow(10, (digit-1)))
        return (Int(self) / power) % 10
    }
}
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}
extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}











