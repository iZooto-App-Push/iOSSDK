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
let sharedUserDefault = UserDefaults(suiteName: SharedUserDefault.suitName)
@objc public  class DATB : NSObject {
    private  static var momagic_id = Int()
    private static var momagic_uuid : String!
    static var  appDelegate = UIApplication.shared.delegate!
    private static var rid : String!
    private static var cid : String!
    private static var myIdLnArray: [[String:Any]] = []
    private static var myRCArray: [[String:Any]] = []
    private static var tokenData : String!
    private let application : UIApplication
    @available(iOS 11.0, *)
    private static var firstAction : UNNotificationAction!
    @available(iOS 11.0, *)
    private static var secondAction : UNNotificationAction!
    @available(iOS 11.0, *)
    private static var category : UNNotificationCategory!
    private static var type : String!
    private static var actionType : String!
    private static var updateURL : String!
    private static let checkData = 1 as Int
    static var  appId : String!
    static var  launchOptions : NSDictionary!
    // private static var badgeCount = 0
    private static var isAnalytics = false as Bool
    private static var isNativeWebview = false as Bool
    private static var isWebView = false as Bool
    private static var landingURL : String!
    private static var badgeNumber = 0 as NSInteger
    private static var badgeCount = 0 as NSInteger
    private static var storyBoardData = UIStoryboard.self
    private static var identifireNameData = String.self
    private static var controllerData = UIViewController.self
    @objc  public static var landingURLDelegate : LandingURLDelegate?
    private static var keySettingDetails = Dictionary<String,Any>()
    @objc  public static var notificationReceivedDelegate : NotificationReceiveDelegate?
    @objc   public static var notificationOpenDelegate : NotificationOpenDelegate?
    
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
    
    
    
    
    @objc public init(application : UIApplication)
    {
        self.application = application
    }
    
    @objc public static func initialisation(momagic_app_id : String, application : UIApplication,MoMagicInitSettings : Dictionary<String,Any>)
    {
        momagic_uuid = momagic_app_id
        keySettingDetails = MoMagicInitSettings
        RestAPI.getRequest(uuid: momagic_uuid) { (output) in
            let jsonString = output.fromBase64()
            if(jsonString != nil)
            {
                
                let data = jsonString!.data(using: .utf8)!
                let json = try? JSONSerialization.jsonObject(with: data)
                if let dictionary = json as? [String: Any] {
                    
                    sharedUserDefault?.set(dictionary["pid"]!, forKey: SharedUserDefault.Key.registerID)
                    momagic_id = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!
                }
                else{
                    debugPrint("Some error occured\(momagic_app_id)")
                }
            }
            
            
            if(keySettingDetails != nil)
            {
                let nativeWebviewKey = keySettingDetails["nativeWebview"] != nil
                if nativeWebviewKey{
                    sharedUserDefault?.set(keySettingDetails["nativeWebview"]!, forKey:AppConstant.ISWEBVIEW)
                } else {
                    debugPrint("The nativeWebview  key is not present in the dictionary")
                }
                let provisionalKey = keySettingDetails["provisionalAuthorization"] != nil
                if(provisionalKey)
                {
                    if(keySettingDetails["provisionalAuthorization"]!) as! Bool
                    {
                        registerForPushNotificationsProvisional() // check for provisional
                    }
                    else{
                        registerForPushNotifications() // check for prompt
                    }
                }
                else
                {
                    debugPrint("The provisional Authorization key  is not present in the dictionary")
                    
                }
                let autoPromptkey = keySettingDetails["auto_prompt"] != nil
                if autoPromptkey{
                    
                    if(keySettingDetails["auto_prompt"]!) as! Bool
                    {
                        if(keySettingDetails["provisionalAuthorization"]!) as! Bool
                        {
                            registerForPushNotificationsProvisional() // check for provisional
                        }
                        else{
                            registerForPushNotifications() // check for prompt
                        }// check for prompt
                    }
                }
                else {
                    debugPrint("The auto_prompt  key is not present in the dictionary")
                }
                
                if #available(iOS 10.0, *) {
                    DispatchQueue.main.async {
                        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
                    }
                }
            }
            else{
                registerForPushNotifications() // check for prompt
                
                if #available(iOS 10.0, *) {
                    DispatchQueue.main.async {
                        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
                    }
                }
                
            }
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
    @objc   private static func   registerForPushNotificationsProvisional()
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
    
    // Capture the token from APNS
    @objc  public  static  func  getToken(deviceToken : Data)
    {
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        if UserDefaults.getRegistered()
        {
            
            guard let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
            else
            {return}
            debugPrint(AppConstant.DEVICE_TOKEN," \(token)")
            if(formattedDate != (sharedUserDefault?.string(forKey: "LastVisit")))
            {
                RestAPI.lastVisit(userid: momagic_id, token:token)
                sharedUserDefault?.set(formattedDate, forKey: "LastVisit")
                
            }
            if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
                userDefaults.set(token, forKey: "DEVICETOKEN")
                userDefaults.set(momagic_id, forKey: "PID")
                userDefaults.synchronize()
            }
            
            if(RestAPI.SDKVERSION != sharedUserDefault?.string(forKey: "SDKVERSION"))
            {
                sharedUserDefault?.set(RestAPI.SDKVERSION, forKey: "SDKVERSION")
                RestAPI.registerToken(token: token, MoMagic_id: momagic_id)
                RestAPI.registerTokenWithMomagic(token: token, MoMagic_id: momagic_id)
                
            }
            
        }
        else
        {
            if(momagic_id != 0)
            {
                RestAPI.registerToken(token: token, MoMagic_id: momagic_id)
                sharedUserDefault?.set(RestAPI.SDKVERSION, forKey: "SDKVERSION")
                RestAPI.registerTokenWithMomagic(token: token, MoMagic_id: momagic_id)
                sharedUserDefault?.set(token, forKey: SharedUserDefault.Key.token)
                if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
                    userDefaults.set(token, forKey: "DEVICETOKEN")
                    userDefaults.set(momagic_id, forKey: "PID")
                    userDefaults.synchronize()
                }
                
            }
            else{
                debugPrint("MoMagic app id  is missing, kindly check on panel...")
                RestAPI.sendExceptionToServer(exceptionName: "MoMagic app id  is missing, kindly check on panel...",  className: "DATB", methodName: "getToken", pid: momagic_id, token: token, rid: "", cid: "")
            }
        }
    }
    
    // handle the badge count
    @objc public static func setBadgeCount(badgeNumber : NSInteger)
    {
        if(badgeNumber == -1)
        {
            sharedUserDefault?.setValue(badgeNumber, forKey: "BADGECOUNT")
        }
        if(badgeNumber == 1)
        {
            sharedUserDefault?.setValue(badgeNumber, forKey: "BADGECOUNT")
            
        }
        else
        {
            if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
                userDefaults.set(0, forKey: "Badge")
                userDefaults.synchronize()
                
            }
        }
    }
    
    
    // Ad's Fallback Url Call
    // Ad's Fallback Url Call
       @available(iOS 11.0, *)
       @objc private static func fallBackAdsApi(bundleName: String, fallCategory: String, bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)?){
           
           let str = RestAPI.FALLBACK_URL
           let izUrlString = (str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
           if let url = URL(string: izUrlString) {
               URLSession.shared.dataTask(with: url) { data, response, error in
                   if let data = data {
                       do {
                           let json = try JSONSerialization.jsonObject(with: data)
                           if let jsonDictionary = json as? [String:Any] {
                               let notificationData = Payload(dictionary: (jsonDictionary) as NSDictionary)
                               bestAttemptContent.title = jsonDictionary[AppConstant.iZ_T_KEY] as! String
                               bestAttemptContent.body = jsonDictionary["m"] as! String
                               if notificationData?.url! != "" {
                                   
                                   let groupName = "group."+bundleName+".DATB"
                                   if let userDefaults = UserDefaults(suiteName: groupName) {
                                       userDefaults.set(notificationData?.url!, forKey: "fallBackLandingUrl")
                                   }
                                   
                                   notificationData?.url = jsonDictionary["bi"] as? String
                                   if (notificationData?.url!.contains(".webp"))!
                                   {
                                       notificationData?.url! = (notificationData?.url?.replacingOccurrences(of: ".webp", with: ".jpeg"))!
                                       
                                   }
                                   if (notificationData?.url!.contains("http:"))!
                                   {
                                       notificationData?.url! = (notificationData?.url?.replacingOccurrences(of: "http:", with: "https:"))!
                                   }
                               }
                               if fallCategory != ""{
                                   storeCategories(notificationData: notificationData!, category: fallCategory)
                                   if notificationData!.act1name != "" && notificationData!.act1name != nil{
                                       debugPrint("Ankey button called")
                                       addCTAButtons()
                                   }
                               }
                               
                               sleep(1)
                               autoreleasepool {
                                   if let urlString = (notificationData?.url!),
                                      let fileUrl = URL(string: urlString ) {
                                       
                                       guard let imageData = NSData(contentsOf: fileUrl) else {
                                           contentHandler!(bestAttemptContent)
                                           return
                                       }
                                       let string = notificationData?.url!
                                       let url: URL? = URL(string: string!)
                                       let urlExtension: String? = url?.pathExtension
                                       guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                           debugPrint(AppConstant.IMAGE_ERROR)
                                           contentHandler!(bestAttemptContent)
                                           return
                                       }
                                       bestAttemptContent.attachments = [ attachment ]
                                   }
                               }
                               
                           }
                           //   if (UserDefaults.standard.bool(forKey: "Subscribe")) == true{
                           contentHandler!(bestAttemptContent)
                           //   }
                           
                       } catch let error {
                           debugPrint("Error",error)
                       }
                   }
                   
               }.resume()
           }
       }
    
    @objc private static func payLoadDataChange(payload: [String:Any],bundleName: String, completion: @escaping ([String:Any]) -> Void) {
        
        if let jsonDictionary = payload as? [String:Any] {
            if let aps = jsonDictionary["aps"] as? NSDictionary{
                if let category = aps.value(forKey: "category"){
                    tempData.setValue(category, forKey: "category")
                }
                
                if let alert = aps.value(forKey: AppConstant.iZ_ALERTKEY) {
                    alertData = alert as! [String : Any]
                    tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                    tempData.setValue(1, forKey: "mutable-content")
                    tempData.setValue(0, forKey: "content_available")
                }
                if let g = aps.value(forKey: AppConstant.iZ_G_KEY), let gt = aps.value(forKey: AppConstant.iZ_G_KEY) as? NSDictionary {
                    gData = gt as! [String : Any]
                    tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                    
                    let groupName = "group."+bundleName+".DATB"
                    if let userDefaults = UserDefaults(suiteName: groupName) {
                        if let pid = userDefaults.string(forKey: "PID"){
                            finalDataValue.setValue(pid, forKey: "pid")
                        }else{
                            finalDataValue.setValue("0", forKey: "pid")
                        }
                    }
                    
                    finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_IDKEY))! as! String, forKey: "pid")
                    finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_RKEY))! as! String, forKey: "rid")
                    finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_TPKEY))! as! String, forKey: "type")
                    finalDataValue.setValue("0", forKey: "result")
                    finalDataValue.setValue(RestAPI.SDKVERSION, forKey: "av")
                    
                    //tp = 4
                    if (gt.value(forKey: AppConstant.iZ_TPKEY))! as! String == "4" {
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
                                    
                                    let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                                    
                                    let session: URLSession = {
                                        let configuration = URLSessionConfiguration.default
                                        configuration.timeoutIntervalForRequest = 2
                                        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                                    }()
                                    
                                    if let url = URL(string: izUrlString) {
                                        session.dataTask(with: url) { data, response, error in
                                            if(error != nil)
                                            {
                                                let t = Date().timeIntervalSince(startDate)
                                                servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t] as NSMutableDictionary
                                                bidsData.append(servedData)
                                                
                                                anData = [anKey[0] as! [String : Any]]
                                                tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                finalData["aps"] = tempData
                                                //Bids & Served
                                                finalDataValue.setValue(t, forKey: "ta")
                                                finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                
                                                storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                
                                                completion(finalData)
                                            }
                                            if let data = data {
                                                do {
                                                    
                                                    let json = try JSONSerialization.jsonObject(with: data)
                                                    
                                                    //To Check FallBack
                                                    if let jsonDictionary = json as? [String:Any] {
                                                        if let value = jsonDictionary["msgCode"] as? String {
                                                            let t = Date().timeIntervalSince(startDate)
                                                            bidsData.append([AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                                                        }else{
                                                            if let jsonDictionary = json as? [String:Any] {
                                                                if cpmValue != ""{
                                                                    let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                    
                                                                    finalCPCValue = String(Double(cpc)!/(10  * Double(cprValue)!))
                                                                }else{
                                                                    finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                }
                                                                
                                                                let t = Date().timeIntervalSince(startDate)
                                                                servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t]
                                                                finalDataValue.setValue("1", forKey: "result")
                                                                bidsData.append(servedData)
                                                            }
                                                        }
                                                    }else{
                                                        if let jsonArray = json as? [[String:Any]] {
                                                            if jsonArray[0]["msgCode"] is String{
                                                                anData = [anKey[0] as! [String : Any]]
                                                                let t = Date().timeIntervalSince(startDate)
                                                                bidsData.append([AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                                                            }else{
                                                                
                                                                if cpmValue != ""{
                                                                    let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                    
                                                                    finalCPCValue = String(Double(cpc)!/(10  * Double(cprValue)!))
                                                                }else{
                                                                    finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                                                }
                                                                
                                                                finalDataValue.setValue("1", forKey: "result")
                                                                let t = Date().timeIntervalSince(startDate)
                                                                servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t]
                                                                bidsData.append(servedData)
                                                            }
                                                        }
                                                    }
                                                    anData = [anKey[0] as! [String : Any]]
                                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                    finalData["aps"] = tempData
                                                    //Bids & Served
                                                    let ta = Date().timeIntervalSince(startDate)
                                                    finalDataValue.setValue(ta, forKey: "ta")
                                                    finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                    
                                                    storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                    
                                                    completion(finalData)
                                                    
                                                } catch let error {
                                                    let t = Date().timeIntervalSince(startDate)
                                                    servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t] as NSMutableDictionary
                                                    bidsData.append(servedData)
                                                    
                                                    anData = [anKey[0] as! [String : Any]]
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
                                        debugPrint("Not Found")
                                    }
                                }
                            }
                        }
                    }
                    
                    //tp = 5
                    else if (gt.value(forKey: AppConstant.iZ_TPKEY))! as! String == "5" {
                        if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                            self.succ = "false"
                            
                            bidsData.removeAll()
                            var fuDataArray = [String]()
                            for (index,valueDict) in anKey.enumerated()   {
                                
                                if let dict = valueDict as? [String: Any] {
                                    debugPrint("", index)
                                    
                                    let fuValue = dict["fu"] as? String ?? ""
                                    //hit fu
                                    let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                                    fuDataArray.append(izUrlString)
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
                                        
                                        let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                                        
                                        if let url = URL(string: izUrlString) {
                                            session.dataTask(with: url) { data, response, error in
                                                if(error != nil)
                                                {
                                                    anData = [anKey[index] as! [String : Any]]
                                                    let t = Date().timeIntervalSince(startDate)
                                                    bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
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
                                                                let t = Date().timeIntervalSince(startDate)
                                                                bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                                                                // debugPrint("jsonDictionary Error", value)
                                                            }else{
                                                                if let jsonDictionary = json as? [String:Any] {
                                                                    
                                                                    if cpmValue != ""{
                                                                        let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                        
                                                                        finalCPCValue = String(Double(cpc)!/(10  * Double(ctrValue)!))
                                                                    }else{
                                                                        finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                    }
                                                                    
                                                                    //debugPrint("DictCPC",finalCPCValue)
                                                                    finalDataValue.setValue("\(index + 1)", forKey: "result")
                                                                    let t = Date().timeIntervalSince(startDate)
                                                                    servedData = [AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: finalCPCValue, AppConstant.iZ_T_KEY:t]
                                                                    servedArray.append(servedData as! [String : Any])
                                                                    bidsData.append(servedData)
                                                                }
                                                            }
                                                        }else{
                                                            if let jsonArray = json as? [[String:Any]] {
                                                                
                                                                if jsonArray[0]["msgCode"] is String{
                                                                    let t = Date().timeIntervalSince(startDate)
                                                                    bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                                                                    // debugPrint("Array error")
                                                                }else{
                                                                    
                                                                    if cpmValue != ""{
                                                                        let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                        
                                                                        finalCPCValue = String(Double(cpc)!/(10  * Double(ctrValue)!))
                                                                        //   print("CPC",finalCPCValue )
                                                                    }else{
                                                                        finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                                                    }
                                                                    
                                                                    
                                                                    // debugPrint("ArrayCPC",finalCPCValue)
                                                                    finalDataValue.setValue("\(index + 1)", forKey: "result")
                                                                    let t = Date().timeIntervalSince(startDate)
                                                                    servedData = [AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: finalCPCValue, AppConstant.iZ_T_KEY:t]
                                                                    servedArray.append(servedData as! [String : Any])
                                                                    bidsData.append(servedData)
                                                                }
                                                            }
                                                        }
                                                        dict.updateValue((finalCPCValue), forKey: "cpcc")
                                                        finalArray.append(dict)
                                                    } catch let error {
                                                        debugPrint(" Error",error)
                                                        let t = Date().timeIntervalSince(startDate)
                                                        bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                                                        dict.updateValue(("0.00"), forKey: "cpcc")
                                                        finalArray.append(dict)
                                                    }
                                                }
                                                if finalArray.count == (anKey as AnyObject).count{
                                                    
                                                    let sortedArray = finalArray.sorted { $0["cpcc"] as! String > $1["cpcc"] as! String}
                                                    
                                                    let cpccSortedDict = sortedArray.first! as? NSDictionary
                                                    // debugPrint("Sorted: \(cpccSortedDict!.value(forKey: "cpcc") as! String)")
                                                    
                                                    anData = [sortedArray.first!] as! [[String: Any]]
                                                    
                                                    tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                    tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                                                    
                                                    tempData.setValue(1, forKey: "mutable-content")
                                                    tempData.setValue(0, forKey: "content_available")
                                                    
                                                    finalData["aps"] = tempData
                                                    
                                                    //Bids & Served
                                                    let ta = Date().timeIntervalSince(startDate)
                                                    finalDataValue.setValue(ta, forKey: "ta")
                                                    
                                                    // To save final served as per cpc
                                                    if servedArray.count != 0{
                                                        for data in servedArray{
                                                            let dict = data as NSDictionary
                                                            let cpc = dict.value(forKey: AppConstant.iZ_B_KEY) as? String
                                                            let result = dict.value(forKey: AppConstant.iZ_A_KEY) as? Int
                                                            if cpc == cpccSortedDict!.value(forKey: "cpcc") as? String{
                                                                finalDataValue.setValue(dict, forKey: AppConstant.iZ_SERVEDKEY)
                                                                finalDataValue.setValue(result, forKey: "result")
                                                            }
                                                        }
                                                    }else{
                                                        let dict = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY: "0.137836933135"]
                                                        finalDataValue.setValue(dict, forKey: AppConstant.iZ_SERVEDKEY)
                                                        finalDataValue.setValue("0", forKey: "result")
                                                    }
                                                    //        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                    
                                                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                    // debugPrint("Type 6", finalDataValue)
                                                    storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                    
                                                    completion(finalData)
                                                }
                                            }.resume()
                                        }else{
                                            debugPrint("Not Found")
                                        }
                                    }
                                    myGroup.leave()
                                }
                            }
                            myGroup.notify(queue: .main) {
                                debugPrint("F")
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
        let dict = anKey[fuCount] as? NSDictionary
        let cpmValue = dict!["cpm"] as? String ?? ""
        let ctrValue = dict!["ctr"] as? String ?? ""
        let cpcValue = dict!["cpc"] as? String ?? ""
        
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
                    let t = Date().timeIntervalSince(startDate)
                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                    
                    if succ != "done"{
                        fuCount += 1
                        if fuArray.count > fuCount {
                            callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, completion: completion)
                        }
                    }
                    
                    if fuCount == anKey.count{
                        anData = [anKey[fuCount - 1] as! [String : Any]]
                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                        finalData["aps"] = tempData
                        
                        servedData = [AppConstant.iZ_A_KEY: fuCount, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t]
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
                                
                                let t = Date().timeIntervalSince(startDate)
                                bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                                
                                if fuCount == anKey.count{
                                    servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t]
                                    anData = [anKey[fuCount - 1] as! [String : Any]]
                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                    finalData["aps"] = tempData
                                    
                                    completion(finalData)
                                }
                            }else{
                                if let jsonDictionary = json as? [String:Any] {
                                    
                                    if cpmValue != ""{
                                        let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                        
                                        finalCPCValue = String(Double(cpc)!/(10  * Double(ctrValue)!))
                                    }else{
                                        finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                    }
                                    
                                    let t = Date().timeIntervalSince(startDate)
                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY:finalCPCValue, AppConstant.iZ_T_KEY:t])
                                    
                                    anData = [anKey[fuCount] as! [String : Any]]
                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                    finalData["aps"] = tempData
                                    
                                    if succ != "done"{
                                        succ = "true"
                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: finalCPCValue, AppConstant.iZ_T_KEY:t]
                                        finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                    }
                                }
                            }
                        }else{
                            if let jsonArray = json as? [[String:Any]] {
                                if jsonArray[0]["msgCode"] is String{
                                    let t = Date().timeIntervalSince(startDate)
                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                                    
                                    if fuCount == anKey.count{
                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t]
                                        anData = [anKey[fuCount - 1] as! [String : Any]]
                                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                        finalData["aps"] = tempData
                                        completion(finalData)
                                    }
                                }else{
                                    if cpmValue != ""{
                                        let cpc =  "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                        
                                        finalCPCValue = String(Double(cpc)!/(10  * Double(ctrValue)!))
                                    }else{
                                        finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                    }
                                    
                                    let t = Date().timeIntervalSince(startDate)
                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t])
                                    
                                    anData = [anKey[fuCount] as! [String : Any]]
                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                    finalData["aps"] = tempData
                                    if succ != "done"{
                                        succ = "true"
                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t]
                                        finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                    }
                                }
                            }
                        }
                    } catch let error {
                        if !error.localizedDescription.isEmpty{
                            let t = Date().timeIntervalSince(startDate)
                            bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t])
                            if succ != "done"{
                                fuCount += 1
                                if fuArray.count > fuCount {
                                    callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, completion: completion)
                                }
                            }
                            if fuCount == anKey.count{
                                anData = [anKey[fuCount - 1] as! [String : Any]]
                                tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                finalData["aps"] = tempData
                                
                                completion(finalData)
                                
                            }
                        }
                    }
                    
                    if succ == "true"{
                        succ = "done"
                        //Bids & Served
                        let ta = Date().timeIntervalSince(startDate)
                        finalDataValue.setValue(ta, forKey: "ta")
                        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                        //  debugPrint("Type 5", finalDataValue)
                        
                        storeBids(bundleName: bundleName, finalData: finalDataValue)
                        
                        completion(finalData)
                        return
                    }
                }
            }.resume()
            
        }
    }
    
    
    
    
    
    // Handle the payload and show the notification
    @available(iOS 11.0, *)
    @objc public static func didReceiveNotificationExtensionRequest(bundleName : String,soundName :String,
                                                                    request : UNNotificationRequest, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
    {
        
        let userInfo = request.content.userInfo
        
        if let jsonDictionary = userInfo as? [String:Any] {
            if let aps = jsonDictionary["aps"] as? NSDictionary{
                
                if aps.value(forKey: AppConstant.iZ_ANKEY) != nil {
                    
                    self.payLoadDataChange(payload: ((userInfo as? [String: Any])!), bundleName: bundleName) { data in
                        let totalData = data["aps"] as? NSDictionary
                        let notificationData = Payload(dictionary: (data["aps"] as? NSDictionary)!)
                        
                        if notificationData?.ankey != nil {
                            
                            if(notificationData?.global?.inApp != nil)
                            {
                                badgeNumber = (sharedUserDefault?.integer(forKey: "BADGECOUNT"))!
                                
                                // custom notification sound
                                if (soundName != "")
                                {
                                    bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(string: soundName) as String)
                                }
                                else
                                {
                                    bestAttemptContent.sound = .default()
                                }
                                
                                if(bundleName != "")
                                {
                                    let groupName = "group."+bundleName+".DATB"
                                    
                                    if let userDefaults = UserDefaults(suiteName: groupName) {
                                        
                                        badgeCount = userDefaults.integer(forKey:"Badge")
                                        if badgeCount > 0 {
                                            if(badgeNumber > 0)
                                            {
                                                bestAttemptContent.badge = 1 as NSNumber
                                            }
                                            else
                                            {
                                                userDefaults.set(badgeCount + 1, forKey: "Badge")
                                                bestAttemptContent.badge = badgeCount + 1 as NSNumber
                                            }
                                        } else {
                                            userDefaults.set(1, forKey: "Badge")
                                            bestAttemptContent.badge = 1
                                        }
                                        
                                        let deviceToken = userDefaults.string(forKey: "DEVICETOKEN") ?? ""
                                        let pid = userDefaults.integer(forKey: "PID")
                                        //To call  Impression API
                                        if (notificationData?.global?.cfg != nil)
                                        {
                                            let str = String((notificationData?.global?.cfg)!)
                                            let binaryString = (str.data(using: .utf8, allowLossyConversion: false)?.reduce("") { (a, b) -> String in a + String(b, radix: 2) })
                                            let lastChar = binaryString?.last!
                                            let str1 = String((lastChar)!)
                                            let impr = Int(str1)
                                            if(impr == 1)
                                            {
                                                RestAPI.callImpression(notificationData: notificationData!,userid: pid,token:"\(deviceToken)")
                                                
                                            }
                                        }
                                        
                                        let id = notificationData?.global?.rid
                                        
                                        //Call Ad_mediation Impression API
                                        if let ids = userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as? [[String : Any]]{
                                            
                                            for data in ids {
                                                if let dataDict = data as? NSDictionary {
                                                    if dataDict.value(forKey: "rid") as? String == id {
                                                        RestAPI.callAdMediationImpressionApi(finalDict: dataDict)
                                                    }
                                                }
                                            }
                                        }
                                        userDefaults.synchronize()
                                    }
                                    else
                                    {
                                        debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_APP_GROUP_ERROR_)
                                    }
                                }
                                
                                //Relevance Score
                                self.setRelevanceScore(notificationData: notificationData!, bestAttemptContent: bestAttemptContent)
                                
                                if notificationData?.ankey?.fetchUrlAd != nil && notificationData?.ankey?.fetchUrlAd != ""
                                {
                                    self.commonFuUrlFetcher(bestAttemptContent: bestAttemptContent, bundleName: bundleName, notificationData: notificationData!,totalData: totalData!, contentHandler: contentHandler)
                                }
                            }
                            else
                            {
                                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                            }
                        }
                    }
                }else{
                    //to get all aps data & pass it to commonfu function
                    let totalData = userInfo["aps"] as? NSDictionary
                    
                    let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                    
                    if(notificationData?.inApp != nil)
                    {
                        badgeNumber = (sharedUserDefault?.integer(forKey: "BADGECOUNT"))!
                        
                        // custom notification sound
                        if (soundName != "")
                        {
                            bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(string: soundName) as String)
                        }
                        else
                        {
                            bestAttemptContent.sound = .default()
                        }
                        
                        if(bundleName != "")
                        {
                            let groupName = "group."+bundleName+".DATB"
                            
                            if let userDefaults = UserDefaults(suiteName: groupName) {
                                
                                badgeCount = userDefaults.integer(forKey:"Badge")
                                if badgeCount > 0 {
                                    if(badgeNumber > 0)
                                    {
                                        bestAttemptContent.badge = 1 as NSNumber
                                    }
                                    else
                                    {
                                        userDefaults.set(badgeCount + 1, forKey: "Badge")
                                        bestAttemptContent.badge = badgeCount + 1 as NSNumber
                                    }
                                } else {
                                    userDefaults.set(1, forKey: "Badge")
                                    bestAttemptContent.badge = 1
                                }
                                
                                let deviceToken = userDefaults.string(forKey: "DEVICETOKEN") ?? ""
                                let pid = userDefaults.integer(forKey: "PID")
                                
                                if (notificationData?.cfg != nil)
                                {
                                    let str = String((notificationData?.cfg)!)
                                    let binaryString = (str.data(using: .utf8, allowLossyConversion: false)?.reduce("") { (a, b) -> String in a + String(b, radix: 2) })
                                    let lastChar = binaryString?.last!
                                    let str1 = String((lastChar)!)
                                    let impr = Int(str1)
                                    if(impr == 1)
                                    {
                                        RestAPI.callImpression(notificationData: notificationData!,userid: pid,token:"\(deviceToken)")
                                        
                                    }
                                }
                                
                                userDefaults.synchronize()
                            }
                            
                            else
                            {
                                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_APP_GROUP_ERROR_)
                            }
                        }
                        
                        //Relevance Score
                        self.setRelevanceScore(notificationData: notificationData!, bestAttemptContent: bestAttemptContent)
                        
                        if notificationData?.fetchurl != nil && notificationData?.fetchurl != ""
                        {
                            self.commonFuUrlFetcher(bestAttemptContent: bestAttemptContent, bundleName: bundleName, notificationData: notificationData!, totalData: totalData!, contentHandler: contentHandler)
                        }
                        else{
                            if notificationData != nil
                            {
                                notificationReceivedDelegate?.onNotificationReceived(payload: notificationData!)
                                
                                if notificationData!.category != "" && notificationData!.category != nil
                                {
                                    //to store categories
                                    storeCategories(notificationData: notificationData!, category: "")
                                    
                                    if notificationData?.act1name != "" && notificationData?.act1name != nil {
                                        addCTAButtons()
                                    }
                                    
                                }
                                
                                sleep(1)
                                autoreleasepool {
                                    if let urlString = (notificationData?.alert?.attachment_url),
                                       let fileUrl = URL(string: urlString ) {
                                        guard let imageData = NSData(contentsOf: fileUrl) else {
                                            contentHandler!(bestAttemptContent)
                                            return
                                        }
                                        let string = notificationData?.alert?.attachment_url
                                        let url: URL? = URL(string: string!)
                                        let urlExtension: String? = url?.pathExtension
                                        
                                        guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                            debugPrint(AppConstant.IMAGE_ERROR)
                                            contentHandler!(bestAttemptContent)
                                            return
                                        }
                                        bestAttemptContent.attachments = [ attachment ]
                                    }
                                }
                                contentHandler!(bestAttemptContent)
                            }
                        }
                    }
                    else
                    {
                        debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                    }
                }
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
    
    @objc private static func commonFuUrlFetcher(bestAttemptContent :UNMutableNotificationContent,bundleName: String,notificationData : Payload,totalData: NSDictionary,contentHandler:((UNNotificationContent) -> Void)?){
        
        if notificationData.ankey != nil {
            var adId = ""
            var adLn = ""
            //
            let izUrlString = (notificationData.ankey?.fetchUrlAd!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
            
            let session: URLSession = {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 2
                return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
            }()
            
            if let url = URL(string: izUrlString) {
                session.dataTask(with: url) { data, response, error in
                    if(error != nil)
                    {
                        if #available(iOS 11.0, *) {
                            fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        } else {
                            // Fallback on earlier versions
                        }
                        return
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data)
                            
                            //To Check FallBack
                            if let jsonDictionary = json as? [String:Any] {
                                if let value = jsonDictionary["msgCode"] as? String {
                                    if #available(iOS 11.0, *) {
                                        fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    return
                                }else{
                                    if let jsonDictionary = json as? [String:Any] {
                                        bestAttemptContent.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.ankey?.titleAd)!))"
                                        bestAttemptContent.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.ankey?.messageAd)!))"
                                        if var landUrl = (notificationData.ankey?.landingUrlAd)  {
                                            
                                            landUrl = "\(getParseValue(jsonData: jsonDictionary, sourceString: landUrl))"
                                            adLn = landUrl
                                            if let adIds = notificationData.ankey?.idAd{
                                                adId = adIds
                                            }
                                            
                                            myIdLnArray.removeAll()
                                            let dict  = [AppConstant.iZ_IDKEY: adId, AppConstant.iZ_LNKEY: adLn]
                                            myIdLnArray.append(dict)
                                        }
                                        if notificationData.ankey?.bannerImageAd != "" {
                                            
                                            notificationData.ankey?.bannerImageAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.ankey?.bannerImageAd)!))"
                                            if ((notificationData.ankey?.bannerImageAd!.contains(".webp")) != nil)
                                            {
                                                notificationData.ankey?.bannerImageAd = notificationData.ankey?.bannerImageAd?.replacingOccurrences(of: ".webp", with: ".jpeg")
                                                
                                            }
                                            if ((notificationData.ankey?.bannerImageAd!.contains("http:")) != nil)
                                            {
                                                notificationData.ankey?.bannerImageAd = notificationData.ankey?.bannerImageAd?.replacingOccurrences(of: "http:", with: "https:")
                                            }
                                        }
                                        
                                        
                                        
                                        //Check & hit RC for adMediation
                                        if notificationData.ankey?.adrc != nil{
                                            adMediationRCDataStore(totalData: totalData, jsonDictionary: jsonDictionary, bundleName: bundleName, aDId : (notificationData.ankey?.idAd)! )
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
                                        if #available(iOS 11.0, *) {
                                            fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                        return
                                    }else{
                                        bestAttemptContent.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.ankey?.titleAd)!))"
                                        bestAttemptContent.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.ankey?.messageAd)!))"
                                        
                                        
                                        if var landUrl = (notificationData.ankey?.landingUrlAd)  {
                                            landUrl = "\(getParseArrayValue(jsonData: jsonArray, sourceString: landUrl))"
                                            adLn = landUrl
                                            if let adIds = notificationData.ankey?.idAd{
                                                adId = adIds
                                            }
                                            
                                            myIdLnArray.removeAll()
                                            let dict  = [AppConstant.iZ_IDKEY: adId, AppConstant.iZ_LNKEY: adLn]
                                            myIdLnArray.append(dict)
                                        }
                                        if notificationData.ankey?.bannerImageAd != "" {
                                            notificationData.ankey?.bannerImageAd = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.ankey?.bannerImageAd)!))"
                                            if ((notificationData.ankey?.bannerImageAd!.contains(".webp")) != nil)
                                            {
                                                notificationData.ankey?.bannerImageAd = notificationData.ankey?.bannerImageAd?.replacingOccurrences(of: ".webp", with: ".jpg")
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if notificationData.category != "" && notificationData.category != nil
                            {
                                storeCategories(notificationData: notificationData, category: "")
                                
                                if notificationData.global!.act1name != "" && notificationData.global!.act1name != nil{
                                    addCTAButtons()
                                }
                            }
                            
                            sleep(1)
                            autoreleasepool {
                                if let urlString = (notificationData.ankey?.bannerImageAd),
                                   let fileUrl = URL(string: urlString ) {
                                    
                                    guard let imageData = NSData(contentsOf: fileUrl) else {
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    let string = notificationData.ankey?.bannerImageAd
                                    let url: URL? = URL(string: string!)
                                    let urlExtension: String? = url?.pathExtension
                                    guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                        debugPrint(AppConstant.IMAGE_ERROR)
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    bestAttemptContent.attachments = [ attachment ]
                                }
                            }
                            
                            storeNotiUrl_ln(bundleName: bundleName)
                            
                            // Need to review
                            if bestAttemptContent.title == notificationData.ankey?.titleAd{
                                if #available(iOS 11.0, *) {
                                    self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }else{
                                contentHandler!(bestAttemptContent)
                            }
                            
                        } catch let error {
                            if #available(iOS 11.0, *) {
                                self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    
                }.resume()
            }else{
                debugPrint("Not Found")
            }
            
        }else{
            let izUrlString = (notificationData.fetchurl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
            
            
            let session: URLSession = {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 2
                return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
            }()
            
            if let url = URL(string: izUrlString) {
                session.dataTask(with: url) { data, response, error in
                    if(error != nil)
                    {
                        if #available(iOS 11.0, *) {
                            fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        } else {
                            // Fallback on earlier versions
                        }
                        return
                    }
                    if response == nil{
                        debugPrint("RESPONSE ======+++++++++++++++")
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data)
                            
                            //To Check FallBack
                            if let jsonDictionary = json as? [String:Any] {
                                if let value = jsonDictionary["msgCode"] as? String {
                                    if #available(iOS 11.0, *) {
                                        fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    return
                                }else{
                                    if let jsonDictionary = json as? [String:Any] {
                                        bestAttemptContent.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.alert?.title)!))"
                                        bestAttemptContent.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.alert?.body)!))"
                                        if notificationData.url != "" {
                                            notificationData.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.url)!))"
                                            // print("URL TO TEST LANDING", notificationData.url)
                                        }
                                        if notificationData.alert?.attachment_url != "" {
                                            
                                            notificationData.alert?.attachment_url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.alert?.attachment_url)!))"
                                            if ((notificationData.alert?.attachment_url!.contains(".webp")) != nil)
                                            {
                                                notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpeg")
                                                
                                            }
                                            if ((notificationData.alert?.attachment_url!.contains("http:")) != nil)
                                            {
                                                notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: "http:", with: "https:")
                                                
                                            }
                                        }
                                        if notificationData.furv != nil {
                                            adMediationRVApiCall(totalData: totalData, jsonDictionary: jsonDictionary)
                                        }
                                    }
                                }
                            }else{
                                
                                if let jsonArray = json as? [[String:Any]] {
                                    if jsonArray[0]["msgCode"] is String {
                                        if #available(iOS 11.0, *) {
                                            fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                        return
                                    }else{
                                        bestAttemptContent.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.alert?.title)!))"
                                        bestAttemptContent.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.alert?.body)!))"
                                        if notificationData.url != "" {
                                            notificationData.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.url)!))"
                                            // print("URL TO TEST LANDING", notificationData.url)
                                        }
                                        if notificationData.alert?.attachment_url != "" {
                                            notificationData.alert?.attachment_url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.alert?.attachment_url)!))"
                                            if ((notificationData.alert?.attachment_url!.contains(".webp")) != nil)
                                            {
                                                notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpg")
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if notificationData.category != "" && notificationData.category != nil
                            {
                                storeCategories(notificationData: notificationData, category: "")
                                if notificationData.act1name != "" && notificationData.act1name != nil{
                                    // debugPrint("Fetch single button called")
                                    addCTAButtons()
                                }
                            }
                            sleep(1)
                            autoreleasepool {
                                if let urlString = (notificationData.alert?.attachment_url),
                                   let fileUrl = URL(string: urlString ) {
                                    
                                    guard let imageData = NSData(contentsOf: fileUrl) else {
                                        //  if (UserDefaults.standard.bool(forKey: "Subscribe")) == true{
                                        contentHandler!(bestAttemptContent)
                                        //  }
                                        return
                                    }
                                    let string = notificationData.alert?.attachment_url
                                    let url: URL? = URL(string: string!)
                                    let urlExtension: String? = url?.pathExtension
                                    guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                        debugPrint(AppConstant.IMAGE_ERROR)
                                        //  if (UserDefaults.standard.bool(forKey: "Subscribe")) == true{
                                        contentHandler!(bestAttemptContent)
                                        //  }
                                        return
                                    }
                                    bestAttemptContent.attachments = [ attachment ]
                                }
                            }
                            
                            if bestAttemptContent.title == notificationData.ankey?.titleAd{
                                if #available(iOS 11.0, *) {
                                    self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }else{
                                contentHandler!(bestAttemptContent)
                            }
                            
                        } catch let error {
                            if #available(iOS 11.0, *) {
                                self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                }.resume()
            }else{
                debugPrint("Not Found")
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
    @objc private static func fallBackAdsApi(bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)?){
        
        let str = RestAPI.FALLBACK_URL
        let izUrlString = (str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        if let url = URL(string: izUrlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        if let jsonDictionary = json as? [String:Any] {
                            let notificationData = Payload(dictionary: (jsonDictionary) as NSDictionary)
                            bestAttemptContent.title = jsonDictionary["t"] as! String
                            bestAttemptContent.body = jsonDictionary["m"] as! String
                            if notificationData?.url! != "" {
                                notificationData?.url = jsonDictionary["bi"] as? String
                                if (notificationData?.url!.contains(".webp"))!
                                {
                                    notificationData?.url! = (notificationData?.url?.replacingOccurrences(of: ".webp", with: ".jpeg"))!
                                    
                                }
                                if (notificationData?.url!.contains("http:"))!
                                {
                                    notificationData?.url! = (notificationData?.url?.replacingOccurrences(of: "http:", with: "https:"))!
                                    
                                }
                            }
                            
                            autoreleasepool {
                                if let urlString = (notificationData?.url!),
                                   let fileUrl = URL(string: urlString ) {
                                    
                                    guard let imageData = NSData(contentsOf: fileUrl) else {
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    let string = notificationData?.url!
                                    let url: URL? = URL(string: string!)
                                    let urlExtension: String? = url?.pathExtension
                                    guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                        print(AppConstant.IMAGE_ERROR)
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    bestAttemptContent.attachments = [ attachment ]
                                }
                            }
                            
                        }
                        contentHandler!(bestAttemptContent)
                        
                    } catch let error {
                        print("Error",error)
                    }
                }
                
            }.resume()
        }
    }
    
    
    
    
    
    
    
    // for json aaray
    @objc  private static func getParseArrayValue(jsonData :[[String : Any]], sourceString : String) -> String
    {
        if(sourceString.contains("~"))
        {
            return sourceString.replacingOccurrences(of: "~", with: "")
        }
        else
        {
            if(sourceString.contains("."))//[0].title -? [0].title // ads .[0].title
            
            {
                let array = sourceString.split(separator: ".")
                let value = "\(array[0])".replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                let data = Int(value)
                let data1 = jsonData[data!]
                let lastData = array.last
                let res = String(lastData!)
                return   data1[res]! as! String
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
                
                
                //                         DispatchQueue.main.async {
                //                            guard let settingsUrl = URL(string: UIApplication.UIApplicationOpenSettingsURLString) else {
                //                                    return
                //                                }
                //
                //                                if UIApplication.shared.canOpenURL(settingsUrl) {
                //                                    if #available(iOS 10.0, *) {
                //                                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                //                                            print("Settings opened: \(success)") // Prints true
                //                                        })
                //                                    } else {
                //                                        UIApplication.shared.openURL(settingsUrl as URL)
                //                                    }
                //                                }
                //                            }
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
                debugPrint(count)
                if count == 2 {
                    if array.first != nil {
                        if let content = jsonData["\(array[0])"] as? [[String:Any]] {
                            for responseData in content {
                                return responseData["\(array[1])"]! as! String
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
                                return responseData["\(array[2])"]! as! String
                            }
                        }
                        else
                        {
                            if let content = jsonData["\(array[0])"] as? [String:Any] {
                                let value = content["\(array[1])"] as! [String:Any]
                                let fvalue = value["\(array[2])"] as! String
                                return fvalue
                            }
                        }
                    }
                }
                if (count == 4){
                    let array = sourceString.split(separator: ".")
                    let response = jsonData["\(array[0])"] as! [String:Any]
                    let documents = response["\(array[1])"] as! [String:Any]
                    //  let field = documents["\(array[2])"] as! [[String:Any]]
                    let field = documents["doc"] as! [[String:Any]]
                    
                    if !field.isEmpty{
                        if (field[0]["\(array[3])"] as? String != nil){
                            let name = field[0]["\(array[3])"]!
                            return (name as? String)!
                            
                        }else if (field[0]["\(array[3])"] as? NSArray != nil){
                            let name = field[0]["\(array[3])"]!
                            if let checkName = name as? NSArray{
                                let finalName = checkName[0] as! String
                                return finalName
                            }
                        }else{
                            return sourceString
                        }
                    }
                }
                if (count == 5){
                    if sourceString.contains("list"){
                        let array = sourceString.split(separator: ".")
                        let response = jsonData["\(array[0])"] as! [[String:Any]]
                        let documents = response[0]
                        let field = documents["\(array[2])"] as! [[String:Any]]
                        if(field.count>0)
                        {
                            // let responseData = field[0]["\(array[3])"]as! [String:Any]
                            let response  = field[0]["\(array[4])"]!
                            return response as! String
                            
                        }
                    }
                    else{
                        
                        let array = sourceString.split(separator: ".")
                        let response = jsonData["\(array[0])"] as! [String:Any]
                        let documents = response["\(array[1])"] as! [String:Any]
                        // let field = documents["\("doc")"] as! [[String:Any]]
                        let field = documents["doc"] as! [[String:Any]]
                        
                        if(!field.isEmpty)
                        {
                            let responseData = field[0]["\(array[3])"]as! [String:Any]
                            let response  = responseData["\(array[4])"]!
                            return response as! String
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
    
    
    
    // Parsing the jsonObject
    @objc  private static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                debugPrint(error.localizedDescription)
                let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)) ?? 0
                let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? "No token here"
                RestAPI.sendExceptionToServer(exceptionName: error.localizedDescription, className: "DATB", methodName: "convertToDictionary", pid: userID, token: token, rid: "0", cid: "0")
            }
        }
        return nil
    }
    
    
    // Handle the Notification behaviour
    @objc  public static func handleForeGroundNotification(notification : UNNotification,displayNotification : String,completionHandler : @escaping (UNNotificationPresentationOptions) -> Void)
    
    {
        let appstate = UIApplication.shared.applicationState
        if (appstate == .active && displayNotification == AppConstant.iZ_KEY_IN_APP_ALERT)
        {
            
            let userInfo = notification.request.content.userInfo
            let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
            
            let alert = UIAlertController(title: notificationData?.alert?.title, message:notificationData?.alert?.body, preferredStyle: UIAlertController.Style.alert)
            if (notificationData?.act1name != nil && notificationData?.act1name != ""){
                alert.addAction(UIAlertAction(title: notificationData?.act1name, style: .default, handler: { (action: UIAlertAction!) in
                    // UIApplication.shared.openURL(NSURL(string: notificationData!.act1link!)! as URL)
                    
                }))
            }
            if (notificationData?.act2name != nil && notificationData?.act2name != "")
            {
                alert.addAction(UIAlertAction(title: notificationData?.act2name, style: .default, handler: { (action: UIAlertAction!) in
                    
                    let izUrlStr = notificationData!.act2link!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    if let url = URL(string:izUrlStr!) {
                        
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
                   if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) {
                       debugPrint(anKey)
                       
                       let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                       
                       if notificationData?.ankey != nil {
                           if(notificationData?.ankey?.fetchUrlAd != "" && notificationData?.ankey?.fetchUrlAd != nil)
                           {
                               if(notificationData?.global?.inApp != nil)
                               {
                                   
                                   if (notificationData?.global?.cfg != nil)
                                   {
                                       impressionTrack(notificationData: notificationData!)
                                       
                                   }
                               }
                               
                               completionHandler([.badge, .alert, .sound])
                               
                           }
                           else
                           {
                               if(notificationData?.global?.inApp != nil)
                               {
                                   
                                   if (notificationData?.global?.cfg != nil)
                                   {
                                       impressionTrack(notificationData: notificationData!)
                                       
                                   }
                                   completionHandler([.badge, .alert, .sound])
                                   
                               }
                               else
                               {
                                   debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                                   
                                   RestAPI.sendExceptionToServer(exceptionName: "MoMagic Payload is not exits\(userInfo)", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "handleForeGroundNotification", pid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, rid: "",cid : "")
                                   
                               }
                           }
                       }
                       //    }
                   }else{
                       let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                       
                       if(notificationData?.fetchurl != "" && notificationData?.fetchurl != nil)
                       {
                           
                           
                           if (notificationData?.cfg != nil)
                           {
                               
                               impressionTrack(notificationData: notificationData!)
                               
                           }
                           
                           completionHandler([.badge, .alert, .sound])
                           
                           
                       }
                       else
                       {
                           if(notificationData?.inApp != nil)
                           {
                               notificationReceivedDelegate?.onNotificationReceived(payload: notificationData!)
                               if (notificationData?.cfg != nil)
                               {
                                   
                                   
                                   impressionTrack(notificationData: notificationData!)
                                   
                                   
                               }
                               completionHandler([.badge, .alert, .sound])
                               
                           }
                           else
                           {
                               debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                               
                               RestAPI.sendExceptionToServer(exceptionName: "MoMagic Payload is not exits\(userInfo)", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "handleForeGroundNotification", pid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, rid: "",cid : "")
                           }
                       }
                   }
               }
           }
        }
    }
    
    
    
    // handel the fallback url
    
    // handel the fallback url
       
       @objc public static func fallbackClickHandler(){
           
           let str = RestAPI.FALLBACK_URL
           let izUrlString = (str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
           if let url = URL(string: izUrlString) {
               URLSession.shared.dataTask(with: url) { data, response, error in
                   if let data = data {
                       do {
                           let json = try JSONSerialization.jsonObject(with: data)
                           if let jsonDictionary = json as? [String:Any] {
                               let notificationData = Payload(dictionary: (jsonDictionary) as NSDictionary)
                               if notificationData?.url! != "" {
                                   
                                   notificationData?.url = jsonDictionary[AppConstant.iZ_LNKEY] as? String
                                   //  debugPrint("URLFALL", notificationData?.url!)
                                   
                                   let izUrlStr = notificationData?.url!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                   
                                   if let url = URL(string:izUrlStr!) {
                                       if notificationData?.act1name != nil && notificationData?.act1name != ""
                                       {
                                           DispatchQueue.main.async {
                                               UIApplication.shared.open(url)
                                           }
                                       }
                                       else
                                       {
                                           DispatchQueue.main.async {
                                               UIApplication.shared.open(url)
                                           }
                                       }
                                   }
                               }
                           }
                       } catch let error {
                           debugPrint("Error",error)
                       }
                   }
               }.resume()
           }else{
               debugPrint("Wrong URL")
           }
       }
    
    
    
    // Handle the clicks the notification from Banner,Button
    @objc public static func notificationHandler(response : UNNotificationResponse)
    {
        
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
                   let badgeC = userDefaults.integer(forKey:"Badge")
                   self.badgeCount = badgeC
                   userDefaults.set(badgeC - 1, forKey: "Badge")
                   RestAPI.fallBackLandingUrl = userDefaults.value(forKey: "fallBackLandingUrl") as? String ?? ""
                   userDefaults.synchronize()
               }
               
               badgeNumber = (sharedUserDefault?.integer(forKey: "BADGECOUNT"))!
               if(badgeNumber == -1)
               {
                   UIApplication.shared.applicationIconBadgeNumber = -1 // clear the badge count // notification is not removed
               }
               else if(badgeNumber == 1)
               {
                   UIApplication.shared.applicationIconBadgeNumber = 0 // clear the badge count
               }else{
                   UIApplication.shared.applicationIconBadgeNumber = self.badgeCount - 1 //set badge default value
               }
               
               let userInfo = response.notification.request.content.userInfo
               
               var adlandingURL:String = ""
               let indexx = 0
               if let jsonDictionary = userInfo as? [String:Any] {
                   if let aps = jsonDictionary["aps"] as? NSDictionary{
                       if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                           debugPrint(anKey)
                           var finalData = [String: Any]()
                           let tempData = NSMutableDictionary()
                           var alertData = [String: Any]()
                           var gData = [String: Any]()
                           var anData: [[String: Any]] = []
                           
                           if let alert = aps.value(forKey: AppConstant.iZ_ALERTKEY) {
                               alertData = alert as! [String : Any]
                           }
                           if let gt = aps.value(forKey: AppConstant.iZ_G_KEY) as? NSDictionary {
                               gData = gt as! [String : Any]
                           }
                           
                           if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                               
                               //To get clicked Notification landing Url
                               adlandingURL = self.ad_mediationLandingUrlOnClick(anKey: anKey)
                               
                               //On click hit rc API
                               getRcAndHitAPI(anKey: anKey)
                               
                               
                               anData = [anKey[indexx] as! [String : Any]]
                               
                               tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                               tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                               tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                               
                               tempData.setValue(1, forKey: "mutable-content")
                               tempData.setValue(0, forKey: "content_available")
                               
                               finalData["aps"] = tempData
                           }
                           
                           let notificationData = Payload(dictionary: (finalData["aps"] as? NSDictionary)!)
                           
                           clickTrack(notificationData: notificationData!, actionType: "0")
                           let notiRid = notificationData?.global?.rid
                           //for rid & bids call Ad-mediation click
                           self.ad_mediationClickCall(notiRid: notiRid!)
                           
                           if notificationData?.ankey != nil{
                               if adlandingURL != ""
                               {
                                   if let unencodedURLString = adlandingURL.removingPercentEncoding {
                                       adlandingURL = unencodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                   } else {
                                       adlandingURL = adlandingURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                   }
                                   
                                   if let url = URL(string: adlandingURL) {
                                       if notificationData?.global!.act1name != nil && notificationData?.global!.act1name != ""
                                       {
                                           DispatchQueue.main.async {
                                               UIApplication.shared.open(url)
                                           }
                                       }
                                       else
                                       {
                                           DispatchQueue.main.async {
                                               UIApplication.shared.open(url)
                                           }
                                       }
                                   }else{
                                       print("OUTSIDE")
                                   }
                               }
                           }
                       }else{
                           let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                           
                           if notificationData?.fetchurl != nil && notificationData?.fetchurl != ""
                           {
                               clickTrack(notificationData: notificationData!, actionType: "0")
                               
                               let izUrlString = (notificationData?.fetchurl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                               
                               let session: URLSession = {
                                   let configuration = URLSessionConfiguration.default
                                   configuration.timeoutIntervalForRequest = 2
                                   return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                               }()
                               if let url = URL(string: izUrlString)
                               {
                                   session.dataTask(with: url) { data, response, error in
                                       if error != nil{
                                           self.fallbackClickHandler()
                                       }
                                       if let data = data {
                                           do {
                                               
                                               let json = try JSONSerialization.jsonObject(with: data)
                                               
                                               //To Check FallBack
                                               if let jsonDictionary = json as? [String:Any] {
                                                   if let value = jsonDictionary["msgCode"] as? String {
                                                       debugPrint(value)
                                                       self.fallbackClickHandler()
                                                       
                                                   }else{
                                                       if let jsonDictionary = json as? [String:Any] {
                                                           
                                                           if notificationData?.url != "" {
                                                               notificationData?.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData?.url)!))"
                                                               
                                                               var stringUrl = notificationData?.url
                                                               
                                                               if let unencodedURLString = stringUrl?.removingPercentEncoding {
                                                                   stringUrl = unencodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                                               } else {
                                                                   stringUrl = stringUrl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                                               }
                                                               
                                                               if let url = URL(string: stringUrl!) {
                                                                   if notificationData?.act1name != nil && notificationData?.act1name != ""
                                                                   {
                                                                       DispatchQueue.main.async {
                                                                           UIApplication.shared.open(url)
                                                                       }
                                                                   }
                                                                   else
                                                                   {
                                                                       DispatchQueue.main.async {
                                                                           UIApplication.shared.open(url)
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                           
                                                           if notificationData?.furc != nil{
                                                               var tempArray = [String]()
                                                               if let rcValue = aps.value(forKey: "rc") as? NSArray {
                                                                   for value in rcValue{
                                                                       let finalRC = "\(getParseValue(jsonData: jsonDictionary , sourceString: value as! String))"
                                                                       tempArray.append(finalRC)
                                                                   }
                                                                   debugPrint("Fetcher RC ++++++++", tempArray)
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
                                                       if notificationData?.url != "" {
                                                           
                                                           notificationData?.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData?.url)!))"
                                                           let izUrlStr = notificationData?.url!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                           
                                                           if notificationData?.act1name != nil && notificationData?.act1name != ""
                                                           {
                                                               if let url = URL(string:izUrlStr!) {
                                                                   DispatchQueue.main.async {
                                                                       UIApplication.shared.open(url)
                                                                   }
                                                               }
                                                           }
                                                           else
                                                           {
                                                               if let url = URL(string:izUrlStr!) {
                                                                   DispatchQueue.main.async {
                                                                       UIApplication.shared.open(url)
                                                                   }
                                                               }
                                                           }
                                                       }
                                                   }
                                               }
                                           } catch let error {
                                               debugPrint(AppConstant.TAG,error)
                                               
                                               //FallBack_Click Handler method.....
                                               self.fallbackClickHandler()
                                               let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)) ?? 0
                                               let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? "No token here"
                                               RestAPI.sendExceptionToServer(exceptionName: error.localizedDescription, className: "DATB", methodName: "notificationHandler", pid: userID, token: token, rid: "0", cid: "0")
                                           }
                                       }
                                   }.resume()
                               }
                           }
                           else
                           {
                               notificationReceivedDelegate?.onNotificationReceived(payload: notificationData!)
                               
                               if notificationData?.category != nil && notificationData?.category != ""
                               {
                                   if response.actionIdentifier == AppConstant.FIRST_BUTTON{
                                       
                                       type = "1"
                                       clickTrack(notificationData: notificationData!, actionType: "1")
                                       
                                       if notificationData?.ap != "" && notificationData?.ap != nil
                                       {
                                           handleClicks(response: response, actionType: "1")
                                       }
                                       else
                                       {
                                           if notificationData?.act1link != nil && notificationData?.act1link != ""
                                           {
                                               let launchURl = notificationData?.act1link!
                                               if launchURl!.contains("tel:")
                                               {
                                                   if let url = URL(string: launchURl!)
                                                   {
                                                       UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                                   }
                                                   
                                               }
                                               else
                                               {
                                                   if ((notificationData?.inApp?.contains("1"))! && notificationData?.inApp != "" && notificationData?.act1link != nil && notificationData?.act1link != "")
                                                   {
                                                       
                                                       
                                                       let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                                       if checkWebview!
                                                       {
                                                           landingURLDelegate?.onHandleLandingURL(url: (notificationData?.act1link)!)
                                                       }
                                                       else
                                                       {
                                                           ViewController.seriveURL = notificationData?.act1link
                                                           UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                       }
                                                   }
                                                   else
                                                   {
                                                       if(notificationData?.fetchurl != "" && notificationData?.fetchurl != nil)
                                                       {
                                                           handleBroserNotification(url: (notificationData?.url)!)
                                                           
                                                       }
                                                       else
                                                       {
                                                           if notificationData!.act1link == nil {
                                                               debugPrint("")
                                                           }
                                                           else
                                                           {
                                                               handleBroserNotification(url: (notificationData?.act1link)!)
                                                           }
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }
                                   else if response.actionIdentifier == AppConstant.SECOND_BUTTON{
                                       type = "2"
                                       clickTrack(notificationData: notificationData!, actionType: "2")
                                       if notificationData?.ap != "" && notificationData?.ap != nil
                                       {
                                           handleClicks(response: response, actionType: "2")
                                       }
                                       else
                                       {
                                           if notificationData?.act2link != nil && notificationData?.act2link != ""
                                           {
                                               let launchURl = notificationData?.act2link!
                                               if launchURl!.contains("tel:")
                                               {
                                                   if let url = URL(string: launchURl!)
                                                   {
                                                       UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                                   }
                                               }
                                               else
                                               {
                                                   if ((notificationData?.inApp?.contains("1"))! && notificationData?.inApp != "" && notificationData?.act2link != nil && notificationData?.act2link != "")
                                                   {
                                                       
                                                       let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                                       if checkWebview!
                                                       {
                                                           landingURLDelegate?.onHandleLandingURL(url: (notificationData?.act2link)!)
                                                       }
                                                       else
                                                       {
                                                           ViewController.seriveURL = notificationData?.act2link
                                                           UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                       }
                                                       
                                                   }
                                                   else
                                                   {
                                                       
                                                       if notificationData!.act2link == nil {
                                                           debugPrint("")
                                                       }
                                                       else
                                                       {
                                                           handleBroserNotification(url: (notificationData?.act2link)!)
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }else{
                                       type = "0"
                                       clickTrack(notificationData: notificationData!, actionType: "0")
                                       if notificationData?.ap != "" && notificationData?.ap != nil
                                       {
                                           handleClicks(response: response, actionType: "0")
                                           
                                       }
                                       else{
                                           if ((notificationData?.inApp?.contains("1"))! && notificationData?.inApp != "" && notificationData?.url != nil && notificationData?.url != "")
                                           {
                                               
                                               let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                               if checkWebview!
                                               {
                                                   landingURLDelegate?.onHandleLandingURL(url: (notificationData?.url)!)
                                               }
                                               else
                                               {
                                                   ViewController.seriveURL = notificationData?.url
                                                   UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                               }
                                           }
                                           else
                                           {
                                               if notificationData!.url == nil {
                                                   debugPrint("")
                                               }
                                               else
                                               {
                                                   handleBroserNotification(url: (notificationData?.url)!)
                                                   
                                               }
                                           }
                                       }
                                   }
                               }else{
                                   type = "0"
                                   clickTrack(notificationData: notificationData!, actionType: "0")
                                   if notificationData?.ap != "" && notificationData?.ap != nil
                                   {
                                       handleClicks(response: response, actionType: "0")
                                       
                                   }
                                   else{
                                       if ((notificationData?.inApp?.contains("1"))! && notificationData?.inApp != "" && notificationData?.url != nil && notificationData?.url != "")
                                       {
                                           
                                           let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                           if checkWebview!
                                           {
                                               landingURLDelegate?.onHandleLandingURL(url: (notificationData?.url)!)
                                           }
                                           else
                                           {
                                               ViewController.seriveURL = notificationData?.url
                                               UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                           }
                                       }
                                       else
                                       {
                                           if notificationData!.url == nil {
                                               debugPrint("")
                                           }
                                           else
                                           {
                                               handleBroserNotification(url: (notificationData?.url)!)
                                               
                                           }
                                       }
                                   }
                               }
                           }
                       }
                   }
               }
    }
    //for rid & bids call mediation click
    
    @objc private static func ad_mediationClickCall(notiRid: String){
        
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as? [[String : Any]]{
                var tempIdArray = ids// userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as! [[String : Any]]
                for (index,data) in ids.enumerated() {
                    if let dataDict = data as? NSDictionary {
                        if (dataDict.value(forKey: "rid") as! String) == notiRid {
                            RestAPI.callAdMediationClickApi(finalDict: dataDict)
                            if index <= tempIdArray.count - 1{
                                tempIdArray.remove(at: index)
                            }
                            userDefaults.setValue(tempIdArray, forKey: AppConstant.iZ_BIDS_SERVED_ARRAY)
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
    }
    
    
    //for hit & remove the landing Url On click Noti
    
    @objc private static func ad_mediationLandingUrlOnClick(anKey: NSArray) -> String{
        var idArray: [[String:Any]] = []
        var landing = ""
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()){
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
                            landing = value1.value(forKey: AppConstant.iZ_LNKEY) as! String

                            if let index = idArray.firstIndex(where: {$0[AppConstant.iZ_LNKEY] as? String  == landing }) {
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
    
    
    
    
    
    
    
    
    //Store fallBack ln & id
    
    @objc private static func storeNotiUrl_ln(bundleName: String){
        let groupName = "group."+bundleName+".DATB"
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
        let groupName = "group."+bundleName+".DATB"
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
                
                let groupName = "group."+bundleName+".DATB"
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
    @objc private static func getRcAndHitAPI(anKey: NSArray){
        var idArray: [[String:Any]] = []
        var rcArray: NSArray = []
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()){
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
        let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
        
        if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
        {
            ViewController.seriveURL = notifcationData?.url
            UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
        }
        else
        {
            onHandleLandingURL(response: response, actionType: actionType, launchURL: launchURL)
        }
    }
    
    // handle the borwser
    @objc  static func onHandleLandingURL(response : UNNotificationResponse , actionType : String,launchURL : String)
    {
        let userInfo = response.notification.request.content.userInfo
        let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
        if ((notifcationData?.inApp?.contains("0"))! && notifcationData?.inApp != "")
        {
            handleBroserNotification(url: launchURL)
        }
    }
    
    // Check the notification subscribe or not 0-> Subscribe 2- UNSubscribe
    @objc  public static func setSubscription(isSubscribe : Bool)
    {
        var value = 2
        if isSubscribe
        {
            value = 0
        }
        
        let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
        let momagic_id = sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)
        if token != nil && momagic_id != 0{
            RestAPI.callSubscription(isSubscribe : value,token : token!,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!)
        }
        else{
            debugPrint("No Subscription Call")
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
    @objc static func impressionTrack(notificationData : Payload)
    {
        if(notificationData.cfg != nil || notificationData.global?.cfg != nil)
        {
            if(notificationData.cfg != nil)
            {
               
                let number = Int(notificationData.cfg ?? "0")
                let binaryString = String(number!, radix: 2)
                let firstDigit = Double(binaryString)?.getDigit(digit: 1.0) ?? 0
                let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                let thirdDigit = Double(binaryString)?.getDigit(digit: 3.0) ?? 0
                let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                let seventhDigit = Double(binaryString)?.getDigit(digit: 7.0) ?? 0
                let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                let ninthDigit = Double(binaryString)?.getDigit(digit: 9.0) ?? 0
                let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                let eleventhDigit = Double(binaryString)?.getDigit(digit: 11.0) ?? 0
                let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                let convertBinaryToDecimal = Int(domainURL, radix: 2)!
               
                if(firstDigit == 1 && eleventhDigit == 1)
                {
                    RestAPI.callMoMagicImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!)
                }
                else
                {
                    if(firstDigit == 1)
                    {
                        RestAPI.callImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!)
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
                                print("URL",url)
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url)
                            }
                            else
                            {
                                
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONVIEWURL)
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
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url)
                            }
                            else
                            {
                                
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONVIEWURL)
                            }
                            
                        }
                    }
                }
            }
            
            if(notificationData.global?.cfg != nil)
            {
                
                let number = Int(notificationData.global?.cfg ?? "0")
                let binaryString = String(number!, radix: 2)
                let firstDigit = Double(binaryString)?.getDigit(digit: 1.0) ?? 0
                let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                let thirdDigit = Double(binaryString)?.getDigit(digit: 3.0) ?? 0
                let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                let seventhDigit = Double(binaryString)?.getDigit(digit: 7.0) ?? 0
                let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                let ninthDigit = Double(binaryString)?.getDigit(digit: 9.0) ?? 0
                let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                let convertBinaryToDecimal = Int(domainURL, radix: 2)!
                if(firstDigit == 1)
                {
                    RestAPI.callImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!)
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
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url)
                            }
                            else
                            {
                                
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONVIEWURL)
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
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url)
                            }
                            else
                            {
                                
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONVIEWURL)
                            }
                            
                        }
                    }
                }
            }
        }
        else
        {
            print(" No CFG Key defined ")

        }
        
    }
    
    @objc public static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    @objc static func clickTrack(notificationData : Payload,actionType : String)
    {
       
            if(notificationData.cfg != nil || notificationData.global?.cfg != nil)
            {
                if(notificationData.cfg != nil){
                    let number = Int(notificationData.cfg ?? "0")
                    let binaryString = String(number!, radix: 2)
                   // let firstDigit = Double(binaryString)?.getDigit(digit: 1.0) ?? 0
                    let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                   // let thirdDigit = Double(binaryString)?.getDigit(digit: 3.0) ?? 0
                    let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                    let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                    let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                   // let seventhDigit = Double(binaryString)?.getDigit(digit: 7.0) ?? 0
                    let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                   // let ninthDigit = Double(binaryString)?.getDigit(digit: 9.0) ?? 0
                    let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                    
                    let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                    let convertBinaryToDecimal = Int(domainURL, radix: 2)!

                   
                    
                    if(secondDigit == 1)
                    {
                        RestAPI.clickTrack(notificationData: notificationData, type: actionType,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
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
                                    print("URL",url)
                                    RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url )
                                }
                                else
                                {
                                    
                                    RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL )
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
                                   RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url )
                               }
                               else
                               {
                                   
                                   RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL )
                               }
                               
                               
                           }
                        }
                    }
                }
                if(notificationData.global?.cfg != nil ){
                    
                    let number = Int(notificationData.global?.cfg ?? "0")
                    
                    let binaryString = String(number!, radix: 2)
                    // let firstDigit = Double(binaryString)?.getDigit(digit: 1.0) ?? 0
                    let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                    // let thirdDigit = Double(binaryString)?.getDigit(digit: 3.0) ?? 0
                    let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                    let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                    let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                    // let seventhDigit = Double(binaryString)?.getDigit(digit: 7.0) ?? 0
                    let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                    // let ninthDigit = Double(binaryString)?.getDigit(digit: 9.0) ?? 0
                    let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                    
                    let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                    let convertBinaryToDecimal = Int(domainURL, radix: 2)!
                    
                    
                    
                    if(secondDigit == 1)
                    {
                        RestAPI.clickTrack(notificationData: notificationData, type: actionType,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
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
                                    RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url )
                                }
                                else
                                {
                                    
                                    RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL )
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
                                    print("URL",url)
                                    RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url )
                                }
                                else
                                {
                                    
                                    RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL )
                                }
                                
                                
                            }
                        }
                    }
                }
            }
        else
        {
            print(" No CFG defined")
        }
        
        
    }
    
    
    
    // Add Event Functionality
    @objc  public static func addEvent(eventName : String , data : Dictionary<String,Any>)
    {
        
        if  eventName != ""{
            let returnData = Utils.dataValidate(data: data)
            if let theJSONData = try?  JSONSerialization.data(
                withJSONObject: returnData,
                options: .fragmentsAllowed),
               let validateData = NSString(data: theJSONData,
                                           encoding: String.Encoding.utf8.rawValue) {
                let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
                if (token != nil && !token!.isEmpty)
                {
                    
                    RestAPI.callEvents(eventName: Utils.eventValidate(eventName: eventName), data: validateData as NSString, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: token!)
                }
                
            }
        }
        
    }
    
    
    // Add User Properties
    @objc public static func addUserProperties( data : Dictionary<String,Any>)
    {
        let returnData =  Utils.dataValidate(data: data)
        if returnData != nil {
            if let theJSONData = try?  JSONSerialization.data(withJSONObject: returnData,options: .fragmentsAllowed),
               let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue) {
                let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
                if (token != nil && !token!.isEmpty)
                {
                    RestAPI.callUserProperties(data: validationData as NSString, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: token!)
                    
                }
            }
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
        
        if subscriberID != ""{
            let subs_id = sharedUserDefault?.string(forKey: SharedUserDefault.Key.subscriberID) ?? ""
            let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!
            let tokens = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
            if(tokens != nil && userID != 0){
                if subscriberID != subs_id {
                    sharedUserDefault?.set(subscriberID, forKey: SharedUserDefault.Key.subscriberID)
                    RestAPI.setSubscriberID(subscriberID: subscriberID, userid: userID, token: tokens!)
                }else{
                    debugPrint("Already sent subscriberID\(subs_id)")
                    
                }
            }
            else
            {
                debugPrint("Check your device token is generated properly or not")
            }
        }
    }
    
}

// Handle banner imange uploading and deleting
@available(iOS 10.0, *)
@available(iOSApplicationExtension 10.0, *)

extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
            
            
        } catch let error {
            let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)) ?? 0
            let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? "No token here"
            RestAPI.sendExceptionToServer(exceptionName: error.localizedDescription, className: AppConstant.IZ_TAG, methodName: "saveImageToDisk", pid: userID, token: token, rid: "0", cid: "0")
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
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}









