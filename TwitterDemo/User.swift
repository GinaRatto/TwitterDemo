//
//  User.swift
//  TwitterDemo
//
//  Created by Gina Ratto on 2/3/17.
//  Copyright © 2017 Gina Ratto. All rights reserved.
//

import UIKit

class User: NSObject {

    var name: NSString?
    var screenname: NSString?
    var profileUrl: NSURL?
    var backgroundUrl: NSURL?
    var tagline: NSString?
    var tweetsCount: Int = 0
    var followingCount: Int = 0
    var followersCount: Int = 0
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String as NSString?
        screenname = dictionary["screen_name"] as? String as NSString?
        tagline = dictionary["description"] as? String as NSString?
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = NSURL(string: profileUrlString)
        }
        else {
            profileUrl = NSURL(string: "")
        }
        
        let backgroundUrlString = dictionary["profile_background_image_url_https"] as? String
        if let backgroundUrlString = backgroundUrlString {
            backgroundUrl = NSURL(string: backgroundUrlString)
        }
        else {
            backgroundUrl = NSURL(string: "")
        }
        
        tweetsCount = dictionary["statuses_count"] as! Int
        followingCount = dictionary["friends_count"] as! Int
        followersCount = dictionary["followers_count"] as! Int
    }
    
    static let userDidLogoutNotification = "UserDidLogout"
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil{
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? Data
                
                if let userData = userData {
                    let dict = try! JSONSerialization.jsonObject(with: userData, options: [])
                    _currentUser = User(dictionary: dict as! NSDictionary)
                }
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            
            if let user = _currentUser{
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary ?? [], options: [])
                defaults.set(data, forKey: "currentUserData")
            }
            else {
                defaults.removeObject(forKey: "currentUserData")
            }
            
            defaults.synchronize()
        }
    }
}

