//
//  UserDefaults.swift
//  MomagiciOSSDK
//
//  Created by Amit on 13/06/21.
//

import Foundation
struct Constant
{
     let userID = "isUserID"
     let userToken = "userToken"
    let isRegister = "isRegister"
    let userDefault = UserDefaults.standard

}
internal extension UserDefaults
{
    static func saveUserID(userID : Int)
    {
      // print(userID)
        Constant().userDefault.set(userID, forKey: Constant().userID)
       // UserDefaults.standard.synchronize()
    }
    static func getUserID()->Int
    {
        if  Constant().userDefault.integer(forKey:  Constant().userID) != 0{
            return  Constant().userDefault.integer(forKey: Constant().userID)
        }
        else{
            return 404
        }
    }
    static func saveUserToken(token: NSString)
    {
         Constant().userDefault.set(token, forKey: Constant().userToken)
       // UserDefaults.standard.synchronize()
    }
    static func isRegistered(isRegister : Bool)
    {
         Constant().userDefault.set(isRegister, forKey:Constant().isRegister)
        //UserDefaults.standard.synchronize()
    }
    static func getRegistered()->Bool
    {
        if  Constant().userDefault.bool(forKey: Constant().isRegister) != false
        {
            return  Constant().userDefault.bool(forKey: Constant().isRegister)
        }
        else
        {
            return false
        }
    }
}

