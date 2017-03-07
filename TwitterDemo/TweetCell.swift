//
//  TweetCell.swift
//  TwitterDemo
//
//  Created by Gina Ratto on 2/3/17.
//  Copyright © 2017 Gina Ratto. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var favoriteCount: Int = 0
    var favoriteCountString: String = ""
    var favorited = false
    
    var retweetCount: Int = 0
    var retweetCountString: String = ""
    var retweeted = false
    
    var tweet: Tweet! {
        didSet {
            profileNameLabel.text = tweet.name! as String?
            userNameLabel.text = "@" + (tweet.screenname! as String)
            timestampLabel.text = String(describing: tweet.timestamp!)
            tweetLabel.text = tweet.text! as String?
            
            var timeDifference = Int(Date().timeIntervalSince(tweet.timestamp as! Date))
            var timeString = ""
            
            if timeDifference < 60 {
                timeString = String("less that a minute ago")
            }
            else if timeDifference < 3600 {
                timeDifference = timeDifference/60
                timeString = String(timeDifference) + "m"
            }
            else if timeDifference < 24 * 3600 {
                timeDifference = timeDifference/24
                timeString = String(timeDifference) + "h"
            }
            else {
                timeDifference = timeDifference/(24 * 3600)
                timeString = String(timeDifference) + " days ago"
            }
            
            timestampLabel.text = timeString
            
            // Set reply button image
            let replyImage = UIImage(named: "reply-icon")
            replyButton.setImage(replyImage, for: .normal)
            
            // Set retweet boolean/button image
            if tweet.retweeted == false {
                let retweetImage = UIImage(named: "retweet-icon")
                retweetButton.setImage(retweetImage, for: .normal)
                retweeted = false
            }
            else {
                let retweetImage = UIImage(named: "retweet-icon-green")
                retweetButton.setImage(retweetImage, for: .normal)
                retweeted = true
            }
            
            // Set favorited boolean/button image
            if tweet.favorited == false {
                let likeImage = UIImage(named: "favor-icon")
                favoriteButton.setImage(likeImage, for: .normal)
                retweeted = false
            }
            else {
                let likeImage = UIImage(named: "favor-icon-red")
                favoriteButton.setImage(likeImage, for: .normal)
                retweeted = true
            }
            
            favoriteCount = tweet.favoritesCount
            retweetCount = tweet.retweetCount
            setButtonCountString()
            
            if let photoData = NSData(contentsOf: tweet.profileUrl as! URL) {
                profilePhotoButton.setImage(UIImage(data: photoData as Data), for: .normal)
            }
        }
    }
    
    @IBAction func retweetButtonTapped(_ sender: Any) {
        if retweeted {
            retweetCount = retweetCount - 1
        }
        else {
            retweetCount = retweetCount + 1
        }
        retweeted = !retweeted
        setButtonCountString()
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if favorited{
            favoriteCount = favoriteCount - 1
        }
        else {
            favoriteCount = favoriteCount + 1
        }
        favorited = !favorited
        setButtonCountString()
    }
    
    func setButtonCountString() {
        if favoriteCount < 1000 {
            favoriteCountString = String(favoriteCount)
        }
        else {
            favoriteCountString = String((favoriteCount/1000)) + "K"
        }
        
        favoriteButton.setTitle(favoriteCountString, for: .normal)
        
        if retweetCount < 1000 {
            retweetCountString = String(retweetCount)
        }
        else {
            retweetCountString = String((retweetCount/1000)) + "K"
        }
        retweetButton.setTitle(retweetCountString, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
