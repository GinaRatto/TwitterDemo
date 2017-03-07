//
//  TwitterClient.swift
//  TwitterDemo
//
//  Created by Gina Ratto on 2/3/17.
//  Copyright © 2017 Gina Ratto. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "345JcRdgSTnd4oSVGPfbytaP2", consumerSecret: "pVyq3XFpEiuPeixa9O7acGu0CnExRs3o8VE3RJ4sMXUnxQ1EEJ")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "ginatwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) -> Void in
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }, failure:{ (error: Error?) in
            print("error: \(error?.localizedDescription)")
            self.loginFailure?(error!)
        })
    }

    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken : BDBOAuth1Credential?) -> Void in
            
            self.currentAccount(success: { (user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) -> () in
                self.loginFailure?(error)
            })
        }) { (error: Error?) -> Void in
            print("error: \(error?.localizedDescription)")
            self.loginFailure?(error!)
        }
        
    }
    
    func homeTimeLine(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()){
        
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            
            let dictionaries = response as! [NSDictionary]
            
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()){
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            success(user)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    class func sendTweet(status: String, callBack: @escaping (_ response: Tweet?, _ error: Error?) -> Void) {
        
        guard let encodedStatus = status.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            else {
                callBack(nil, nil)
                return
        }
        let _ = TwitterClient.sharedInstance?.post("https://api.twitter.com/1.1/statuses/update.json?status=" + encodedStatus, parameters: nil, progress: nil, success: { (URLSessionDataTask, response: Any?) in
            
            if let tweetDictionary = response as? [String: Any] {
                let tweet = Tweet(dictionary: tweetDictionary as NSDictionary)
                callBack(tweet, nil)
            }
            else {
                callBack(nil, nil)
            }
            
        }, failure: { (URLSessionDataTask, error: Error) in
            print(error.localizedDescription)
            callBack(nil, error)
        })
    }
    
    func retweet(tweetID: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/retweet/\(tweetID).json", parameters: ["id":tweetID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweetDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: tweetDictionary)
            success(tweet)
            
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func unretweet(tweetID: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/unretweet/\(tweetID).json", parameters: ["id":tweetID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweetDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: tweetDictionary)
            success(tweet)
            
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func favorite(tweetID: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()){
        post("https://api.twitter.com/1.1/favorites/create.json?id=" + String(tweetID), parameters: ["id":tweetID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let responseDictionary = response as! NSDictionary
            let tweet = Tweet.init(dictionary: responseDictionary)
            success(tweet)
            
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func unfavorite(tweetID: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()){
        post("https://api.twitter.com/1.1/favorites/destroy.json?id=" + String(tweetID), parameters: ["id":tweetID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let responseDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: responseDictionary)
            success(tweet)
            
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
}
