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
@objc public class RestAPI : NSObject
{
    public static var BASEURL = "https://aevents.izooto.com/"
    public static var ENCRPTIONURL="https://cdn.izooto.com/app/app_"
    private static var  IMPRESSION_URL="https://impr.izooto.com/imp?";
    public static var LOG = "MoMagic :"
    private static  var EVENT_URL = "https://et.izooto.com/evt?";
    private static var  PROPERTIES_URL="https://prp.izooto.com/prp?";
    private static var CLICK_URL="https://clk.izooto.com/clk?";
    private static var REGISTRATION_URL="https://aevents.izooto.com/app.php?";
    private static  var LASTVISITURL="https://lvi.izooto.com/lvi?";

 @objc  public static func registerToken(token : String, MoMagic_id : Int)
    {
    var request = URLRequest(url: URL(string:RestAPI.REGISTRATION_URL+"s=2&pid=\(MoMagic_id)&btype=8&dtype=3&tz=\(currentTimeInMilliSeconds())&bver=\(getVersion())&os=5&allowed=1&bKey=\(token)&check=\(getAppVersion())&deviceName=\(getDeviceName())&osVersion=\(getVersion())&it=\(getUUID())&adid=\(identifierForAdvertising()!)")!)
   
  
        request.httpMethod = AppConstant.REQUEST_GET
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    do {
                        print(AppConstant.DEVICE_TOKEN,token)
                        UserDefaults.isRegistered(isRegister: true)
                         print(AppConstant.SUCESSFULLY)
                        let date = Date()
                        let format = DateFormatter()
                        format.dateFormat = "yyyy-MM-dd"
                        let formattedDate = format.string(from: date)
                        if(formattedDate != (sharedUserDefault?.string(forKey: "LastVisit")))
                        {
                            RestAPI.lastVisit(userid: MoMagic_id, token:token)
                            sharedUserDefault?.set(formattedDate, forKey: "LastVisit")

                        }

                    }
                }).resume()

                 
             }
   @objc public static func callSubscription(isSubscribe : Int,token : String,userid : Int)
        
    {
        var request = URLRequest(url: URL(string: "https://usub.izooto.com/sunsub?pid=\(userid)&btype=8&dtype=3&pte=3&bver=\(getVersion())&os=5&pt=0&bKey=\(token)&ge=1&action=\(isSubscribe)")!)
        request.httpMethod = AppConstant.REQUEST_POST
                       URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                           do {

                           }
                       }).resume()
    }

  @objc static  public func createRequest(uuid: String, completionBlock: @escaping (String) -> Void) -> Void
    {

   
    let requestURL = URL(string: "https://cdn.izooto.com/app/app_\(uuid).dat")
        let request = URLRequest(url: requestURL!)
        let requestTask = URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in

            if(error != nil) {
                print("Error:  ")
            }else
            {
                let outputStr  = String(data: data!, encoding: String.Encoding.utf8)!
                completionBlock(outputStr);
            }
        }
        requestTask.resume()
    
    
    
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
        let device_id = UIDevice.current.identifierForVendor!.uuidString
        
        return device_id

    }
      
      @objc static func  getVersion() -> String {
        return UIDevice.current.systemVersion

      }
    
  @objc static func getAppInfo()->String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return version + "(" + build + ")"
    }
   @objc static func getAppName()->String {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        return appName
    }
    @objc static func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    @objc static func getAppVersion() -> String {
           let dictionary = Bundle.main.infoDictionary!
           let version = dictionary["CFBundleShortVersionString"] as! String
           return "\(version)"
       }

    
    @objc public static func callEvents(eventName : String, data : NSString,userid : Int,token : String)
      {
        if( eventName != " "  ){
        let escapedString = data.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
                var request = URLRequest(url: URL(string: RestAPI.EVENT_URL+"pid=\(userid)&act=\(eventName)&et=evt&bKey=\(token)&val=\(escapedString!)")!)
                     request.httpMethod = AppConstant.REQUEST_POST
                           URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                               do {
                                print(AppConstant.ADD_EVENT)
                               }
                            }).resume()

        
        }
        else{
            print(AppConstant.ERROR_EVENT)
        }
        

          
      }
    @objc  public static func callUserProperties( data : NSString,userid : Int,token : String)
         {
        if( data != "" ){


              let userpropertiesData = data.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
            var request = URLRequest(url: URL(string: RestAPI.PROPERTIES_URL+"pid=\(userid)&act=add&et=userp&bKey=\(token)&val=\(userpropertiesData!)")!)
               request.httpMethod = AppConstant.REQUEST_POST
                              URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                                  do {
                                    print(AppConstant.ADD_PROPERTIES)
                                  }
                               }).resume()
                        }
            else{
            print( AppConstant.ERROR_PROPERTIES)
                }
            
            
         }
    @objc public static func callImpression(notificationData : Payload,userid : Int,token : String)
    {
        var request = URLRequest(url: URL(string: RestAPI.IMPRESSION_URL+"pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=\(token)&op=view")!)
    

            request.httpMethod = AppConstant.REQUEST_POST
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    print("i","s")

                }
            }).resume()

        
    }
    @objc public static func clickTrack(notificationData : Payload,type : String, userid : Int,token : String)
    {
        var request = URLRequest(url: URL(string: RestAPI.CLICK_URL+"pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=\(token)&op=click&btn=\(type)&ver=\(getVersion())")!)
        
                request.httpMethod = AppConstant.REQUEST_POST

                   URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                       do {
                        print("c","s")
                       }
                   }).resume()

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
    public static func lastVisit(userid : Int,token : String)
    {
            let data = ["last_website_visit":"true","lang":"en"] as [String:String]
        if let theJSONData = try?  JSONSerialization.data(withJSONObject: data,options: .fragmentsAllowed),
           let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue) {
            
            let lastVisitData = validationData.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
            var request = URLRequest(url: URL(string: RestAPI.LASTVISITURL+"pid=\(userid)&act=add&isid=1&et=userp&bKey=\(token)&val=\(lastVisitData ??  "")")!)

                request.httpMethod = AppConstant.REQUEST_POST
                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    do {
                        print("l","v")
                    }
                }).resume()
        
          }
        
    }
    public static func lastImpression(notificationData : Payload,userid : Int,token : String)
    {
        var request = URLRequest(url: URL(string: RestAPI.IMPRESSION_URL+"pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=\(token)&op=view")!)

            request.httpMethod = AppConstant.REQUEST_POST
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                }
            }).resume()

        
    }
    public static func lastClick(notificationData : Payload,userid : Int,token : String)
    {
        var request = URLRequest(url: URL(string: RestAPI.IMPRESSION_URL+"pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=\(token)&op=view")!)

            request.httpMethod = AppConstant.REQUEST_POST
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                }
            }).resume()

        
    }
}

