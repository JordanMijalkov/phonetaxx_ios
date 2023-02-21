//
//  FCMNotification.swift
//  Stylco
//
//  Created by SMIT iMac27 on 21/07/20.
//  Copyright © 2020 smartitventures. All rights reserved.
//

import Foundation
import UIKit
class PushNotificationSender {
    
  /*  {
      "to": "cHPpZ_s14EA:APA91bG56z nW...",
      "priority": "high",
      "notification" : {
        "body" : "hello!",
        "title": "afruz",
        "sound": "default"
      }
    } */
    
    
    func sendPushNotification(to token: String, title: String, body: String,senderId: String,typeId:String, userName: String, userImage: String, appType:String) {
        
      //  print("token->\(token), body->\(body) senderid->\(senderId), typeid->\(typeId)")
        if typeId == "I" {
            
            let urlString = "https://fcm.googleapis.com/fcm/send"
                let url = NSURL(string: urlString)!
                let paramString: [String : Any] = ["to" : token,
                                                 //  "priority": "high",
                                                   "notification" : ["title" : title, "body" : body, "sound" :"default","sender_id":senderId,"userName":userName,"userImage":userImage,"appType":appType],
                                                   "data":["sender_id":senderId,"userName":userName,"userImage":userImage,"appType":appType,"title" : title, "body" : body, "sound" :"default"]]
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=AAAAYRBCRCc:APA91bHP8Mh_QJhnqarGAUhbtLP-7d-849ehXDCwEXSZKmiGbZrQgmG8m_6kwccp52NBJxYkBWp2gD47e-OfAET8MGjqVu7iAhXWMygVVQFbg8s8rRl9Tzdc6dhoyeS4XX3nU3_-eZrI", forHTTPHeaderField: "Authorization")
                let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                    do {
                        if let jsonData = data {
                            if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                                NSLog("Received data:\n\(jsonDataDict))")
                            }
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
                }
                task.resume()
            
        }else{
            let urlString = "https://fcm.googleapis.com/fcm/send"
                let url = NSURL(string: urlString)!
                let paramString: [String : Any] = ["to" : token,
                                                   "data" : ["title" : title, "body" : body,"userName":userName,"userImage":userImage,"sender_id":senderId,"appType":appType]]
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=AAAAYRBCRCc:APA91bHP8Mh_QJhnqarGAUhbtLP-7d-849ehXDCwEXSZKmiGbZrQgmG8m_6kwccp52NBJxYkBWp2gD47e-OfAET8MGjqVu7iAhXWMygVVQFbg8s8rRl9Tzdc6dhoyeS4XX3nU3_-eZrI", forHTTPHeaderField: "Authorization")
                let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                    do {
                        if let jsonData = data {
                            if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                                NSLog("Received data:\n\(jsonDataDict))")
                            }
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
                }
                task.resume()
        }
        
        
    }
}
