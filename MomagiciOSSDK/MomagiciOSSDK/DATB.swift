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
    private static var rid : String!
    private static var cid : String!
    private static var tokenData : String!
    private let application : UIApplication
    @available(iOS 10.0, *)
    private static var firstAction : UNNotificationAction!
    @available(iOS 10.0, *)
    private static var secondAction : UNNotificationAction!
    @available(iOS 10.0, *)
    private static var category : UNNotificationCategory!
    private static var type : String!
    private static var actionType : String!
    private static var updateURL : String!
    private static let checkData = 1 as Int
    private static var badgeCount = 0
    private static var isAnalytics = false as Bool
    private static var isNativeWebview = false as Bool
    private static var momagic_uuid : String!
    private static var isWebView = false as Bool
    private static var landingURL : String!
    private static var storyBoardData = UIStoryboard.self
    private static var identifireNameData = String.self
    private static var controllerData = UIViewController.self
    @objc public static var landingURLDelegate : LandingURLDelegate?
    private static var keySettingDetails = Dictionary<String,Any>()
    @objc public static var notificationReceivedDelegate : NotificationReceiveDelegate?
    @objc public static var notificationOpenDelegate : NotificationOpenDelegate?
    private static var badgeNumber = 0 as NSInteger
    
    
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
    
    
    // Handle the payload and show the notification
    
    // Handle the payload and show the notification
    @available(iOS 10.0, *)
    @objc public static func didReceiveNotificationExtensionRequest(request : UNNotificationRequest, bundleName : String, soundName :String, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
    {
        let userInfo = request.content.userInfo
        let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
        
        if(notificationData?.inApp != nil)
        {
            badgeNumber = (sharedUserDefault?.integer(forKey: "BADGECOUNT"))!
            
            
            if (soundName != "")
            {
                
                bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(string: soundName) as String)
            }
            else
            {
                bestAttemptContent.sound = .default()
            }
            if(bundleName != nil)
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
                    
                    let deviceToken = userDefaults.string(forKey: "DEVICETOKEN")
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
            if #available(iOS 15.0, *) {
                bestAttemptContent.relevanceScore = notificationData?.relevence_score ?? 0
                if(notificationData?.interrutipn_level == 1 )
                {
                    bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.passive
                }
                if(notificationData?.interrutipn_level == 2)
                {
                    bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.timeSensitive
                    
                }
                if(notificationData?.interrutipn_level == 3)
                {
                    bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.critical
                    
                }
            }
            
            if notificationData?.fetchurl != nil && notificationData?.fetchurl != ""
            {
                let izUrlString = notificationData?.fetchurl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if let url = URL(string: izUrlString!) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if(error != nil)
                        {
                            fallBackAdsApi(bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        }
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data)
                                
                                //To Check FallBack
                                if let jsonDictionary = json as? [String:Any] {
                                    if let value = jsonDictionary["msgCode"] as? String {
                                        fallBackAdsApi(bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    }
                                    
                                }
                                else
                                {
                                    
                                    let json = try JSONSerialization.jsonObject(with: data)
                                    
                                    if let jsonArray = json as? [[String:Any]] {
                                        bestAttemptContent.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData?.alert!.title)!))"
                                        print(bestAttemptContent.title)
                                        bestAttemptContent.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData?.alert!.body)!))"
                                        if notificationData?.url != "" {
                                            notificationData?.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData?.url)!))"
                                            
                                        }
                                        if notificationData?.alert?.attachment_url != "" {
                                            notificationData?.alert?.attachment_url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData?.alert!.attachment_url)!))"
                                            
                                            
                                        }
                                        
                                    } else if let jsonDictionary = json as? [String:Any] {
                                        
                                        
                                        bestAttemptContent.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData?.alert!.title)!))"
                                        bestAttemptContent.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData?.alert!.body)!))"
                                        if notificationData?.url != "" {
                                            notificationData?.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData?.url)!))"
                                        }
                                        if notificationData?.alert?.attachment_url != "" {
                                            
                                            
                                            notificationData?.alert?.attachment_url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData?.alert!.attachment_url)!))"
                                            
                                        }
                                    }
                                    
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
                            } catch let error {
                                debugPrint("Error",error)
                                
                                
                            }
                        }
                        
                    }.resume()
                }else{
                    print("NOT Found")
                }
                
                let firstAction = UNNotificationAction( identifier: "FirstButton", title: "Sponsored", options: .foreground)
                let  category = UNNotificationCategory( identifier: "datb_category", actions: [firstAction], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])
                
                
            }
            
            
            else{
                if notificationData != nil
                {
                    
                    
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
                    
                    
                    //}
                    
                }
            }
        }
        else
        {
            debugPrint("MoMagic payload is not exist\(userInfo)")
            
        }
        
    }
    
    
    // Fallback Url Call
    @available(iOS 10.0, *)
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
    
    
    
    
    
    
    
    @objc private static func getParseArrayValue(jsonData :[[String : Any]], sourceString : String) -> String
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
    @objc   private static func getParseValue(jsonData :[String : Any], sourceString : String) -> String
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
                    }
                }
                if (count == 4){
                    let array = sourceString.split(separator: ".")
                    let response = jsonData["\(array[0])"] as! [String:Any]
                    let documents = response["\(array[1])"] as! [String:Any]
                    //  let field = documents["\(array[2])"] as! [[String:Any]]
                    let field = documents["doc"] as! [[String:Any]]
                    if !field.isEmpty{
                        let name = field[0]["\(array[3])"]!
                        return name as! String
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
                        let field = documents["\("doc")"] as! [[String:Any]]
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
            }
        }
        return nil
    }
    
    
    
    @objc public static func handleForeGroundNotification(notification : UNNotification,displayNotification : String,completionHandler : @escaping (UNNotificationPresentationOptions) -> Void){
        let appstate = UIApplication.shared.applicationState
        
        if (appstate == .active && displayNotification == "InAppAlert")
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
                    UIApplication.shared.openURL(NSURL(string: notificationData!.act2link!)! as URL)
                }))
            }
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        else
        {
            let userInfo = notification.request.content.userInfo
            
            let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
            if(notificationData?.inApp != nil)
            {
                notificationReceivedDelegate?.onNotificationReceived(payload: notificationData!)
                if (notificationData?.cfg != nil)
                {
                    let str = String((notificationData?.cfg)!)
                    let binaryString = (str.data(using: .utf8, allowLossyConversion: false)?.reduce("") { (a, b) -> String in a + String(b, radix: 2) })
                    let lastChar = binaryString?.last!
                    let str1 = String((lastChar)!)
                    let impr = Int(str1)
                    if(impr == 1)
                    {
                        
                        RestAPI.callImpression(notificationData: notificationData!,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!)
                        
                        
                        
                    }
                }
                completionHandler([.badge, .alert, .sound])
            }
            else
            {
                debugPrint("MoMagic payload is not exist\(userInfo)")
                RestAPI.sendExceptionToServer(exceptionName: "MoMagic payload is not exist \(userInfo)", className: "DATB", methodName: "handleForeGroundNotification", pid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! , rid: "",cid : "")
            }
            
            
            
        }
        
        
    }
    
    
    
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
                                
                                notificationData?.url = jsonDictionary["ln"] as? String
                                
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
                        print("Error",error)
                    }
                }
            }.resume()
        }else{
            print("Wrong URL")
        }
    }
    
    
    
    // Handle the clicks the notification from Banner,Button
    @objc  public static func notificationHandler(response : UNNotificationResponse)
    {
        
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
            let badgeC = userDefaults.integer(forKey:"Badge")
            self.badgeCount = badgeC
            userDefaults.set(badgeC - 1, forKey: "Badge")
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
        let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
        
        clickTrack(notificationData: notifcationData!, actionType: "0")
        
        if notifcationData?.fetchurl != nil && notifcationData?.fetchurl != ""
        {
            let izUrlString = notifcationData?.fetchurl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            if let url = URL(string: izUrlString!)
            {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    
                    if error != nil{
                        self.fallbackClickHandler()
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data)
                            
                            //To Check FallBack
                            if let jsonDictionary = json as? [String:Any] {
                                if let value = jsonDictionary["msgCode"] as? String {
                                    self.fallbackClickHandler()
                                }
                            }
                            else
                            {
                                if let jsonArray = json as? [[String:Any]] {
                                    if notifcationData?.url != "" {
                                        notifcationData?.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notifcationData?.url)!))"
                                        handleBroserNotification(url: (notifcationData!.url!))
                                        
                                    }
                                }
                                else if let jsonDictionary = json as? [String:Any] {
                                    if notifcationData?.url != "" {
                                        notifcationData?.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notifcationData?.url)!))"
                                        handleBroserNotification(url: (notifcationData!.url!))
                                    }
                                }
                            }
                        } catch let error {
                            debugPrint(AppConstant.TAG,error)
                            self.fallbackClickHandler()
                        }
                    }
                }.resume()
            }
        }
        else
        {
            if notifcationData?.category != nil
            {
                switch response.actionIdentifier
                {
                case "FirstButton" :
                    type = "1"
                    // clickTrack(notificationData: notifcationData!, actionType: "1")
                    
                    if notifcationData?.ap != "" && notifcationData?.ap != nil
                    {
                        handleClicks(response: response, actionType: "1")
                    }
                    else
                    {
                        if notifcationData?.act1link != nil && notifcationData?.act1link != ""
                        {
                            let launchURl = notifcationData?.act1link!
                            if launchURl!.contains("tel:")
                            {
                                if let url = URL(string: launchURl!)
                                {
                                    handleBroserNotification(url: (notifcationData!.url!))
                                }
                                
                            }
                            else
                            {
                                if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
                                {
                                    
                                    let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                    if checkWebview!
                                    {
                                        landingURLDelegate?.onHandleLandingURL(url: (notifcationData?.act1link)!)
                                    }
                                    else
                                    {
                                        ViewController.seriveURL = notifcationData?.act1link
                                        UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                    }
                                    
                                    
                                }
                                else
                                {
                                    if(notifcationData?.fetchurl != "" && notifcationData?.fetchurl != nil)
                                    {
                                        if let url = URL(string: notifcationData!.url!) {
                                            // handleBroserNotification(url: (notifcationData!.url!))
                                            handleBroserNotification(url: (notifcationData!.url!))
                                            
                                        }
                                    }
                                    else
                                    {
                                        if let url = URL(string: notifcationData!.act1link!) {
                                            // handleBroserNotification(url: (notifcationData!.url!))
                                            handleBroserNotification(url: (notifcationData!.url!))
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    break
                case "SecondButton" :
                    type = "2"
                    // clickTrack(notificationData: notifcationData!, actionType: "2")
                    
                    
                    if notifcationData?.ap != "" && notifcationData?.ap != nil
                    {
                        handleClicks(response: response, actionType: "2")
                    }
                    else
                    {
                        if notifcationData?.act2link != nil && notifcationData?.act2link != ""
                        {
                            let launchURl = notifcationData?.act2link!
                            if launchURl!.contains("tel:")
                            {
                                if let url = URL(string: launchURl!)
                                {
                                    // handleBroserNotification(url: (notifcationData!.url!))
                                    handleBroserNotification(url: (notifcationData!.url!))
                                }
                            }
                            else
                            {
                                if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
                                {
                                    
                                    let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                    if checkWebview!
                                    {
                                        landingURLDelegate?.onHandleLandingURL(url: (notifcationData?.act2link)!)
                                    }
                                    else
                                    {
                                        ViewController.seriveURL = notifcationData?.act2link
                                        UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                    }
                                    
                                }
                                else
                                {
                                    if let url = URL(string: notifcationData!.act2link!)
                                    {
                                        handleBroserNotification(url: (notifcationData!.url!))
                                    }
                                }
                            }
                        }
                    }
                    break
                default:
                    type = "0"
                    // clickTrack(notificationData: notifcationData!, actionType: "0")
                    
                    if notifcationData?.ap != "" && notifcationData?.ap != nil
                    {
                        handleClicks(response: response, actionType: "0")
                    }
                    else{
                        if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "" && notifcationData?.url != nil && notifcationData?.url != "")
                        {
                            
                            let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                            if checkWebview!
                            {
                                landingURLDelegate?.onHandleLandingURL(url: (notifcationData?.url)!)
                            }
                            else
                            {
                                ViewController.seriveURL = notifcationData?.url
                                UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                            }
                        }
                        else{
                            if notifcationData!.url == nil {
                                print("")
                            }else{
                                handleBroserNotification(url: (notifcationData?.url)!)
                            }
                        }
                    }
                }//close switch
                
            }// close if
            else{
                type = "0"
                // clickTrack(notificationData: notifcationData!, actionType: "0")
                
                if notifcationData?.ap != "" && notifcationData?.ap != nil
                {
                    handleClicks(response: response, actionType: "0")
                    
                }
                else
                {
                    if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "" && notifcationData?.url != nil && notifcationData?.url != "")
                    {
                        
                        let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                        if checkWebview!
                        {
                            landingURLDelegate?.onHandleLandingURL(url: (notifcationData?.url)!)
                        }
                        else
                        {
                            ViewController.seriveURL = notifcationData?.url
                            UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        if notifcationData!.url == nil {
                            print("")
                        }else{
                            handleBroserNotification(url: (notifcationData?.url)!)
                        }
                    }
                }
            } //close else
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
    
    // Handle the InApp/Webview
    private static func onHandleInAPP(response : UNNotificationResponse , actionType : String,launchURL : String)
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
    private static func onHandleLandingURL(response : UNNotificationResponse , actionType : String,launchURL : String)
    {
        let userInfo = response.notification.request.content.userInfo
        let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
        if ((notifcationData?.inApp?.contains("0"))! && notifcationData?.inApp != "")
        {
            if let url = URL(string: launchURL) {
                if #available(iOS 10.0, *) {
                    handleBroserNotification(url: (notifcationData!.url!))
                    
                }
                
            }
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
    @objc  private static func handleClicks(response : UNNotificationResponse , actionType : String)
    {
        let userInfo = response.notification.request.content.userInfo
        let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
        var data = Dictionary<String,Any>()
        data["button1ID"] = notifcationData?.act1id
        data["button1Title"] = notifcationData?.act1name
        data["button1URL"] = notifcationData?.act1link
        data["additionalData"] = notifcationData?.ap
        data["landingURL"] = notifcationData?.url
        data["button2ID"] = notifcationData?.act2id
        data["button2Title"] = notifcationData?.act2name
        data["button2URL"] = notifcationData?.act2link
        data["actionType"] = actionType
        notificationOpenDelegate?.onNotificationOpen(action: data)
        
        
    }
    @objc private static func clickTrack(notificationData : Payload,actionType : String)
    {
        if(notificationData.cfg != nil)
        {
            let str = notificationData.cfg
            let binaryString = (str!.data(using: .utf8, allowLossyConversion: false)?.reduce("") { (a, b) -> String in a + String(b, radix: 2) })
            let data = binaryString!.suffix(2)
            let clickCFG = data.prefix(1)
            let click = Int(clickCFG)
            
            if(click == 1)
            {
                RestAPI.clickTrack(notificationData: notificationData, type: actionType,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
            }
        }
        
    }
    
    
    public static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
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
    
    @objc private static func  handleBroserNotification(url : String)
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
            if subscriberID != subs_id {
                RestAPI.setSubscriberID(subscriberID: subscriberID, userid: userID, token: tokens!)
            }else{
                debugPrint("Store subscriberID\(subs_id)")
                
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









