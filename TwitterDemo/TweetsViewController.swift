//
//  TweetsViewController.swift
//  TwitterDemo
//
//  Created by Gina Ratto on 2/3/17.
//  Copyright © 2017 Gina Ratto. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var composeButton: UIButton!
    
    var tweets: [Tweet]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        composeButton.setImage(UIImage(named: "edit-icon"), for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        TwitterClient.sharedInstance?.homeTimeLine(success: { (tweets: [Tweet]) -> () in
            
            self.tweets = tweets
            self.tableView.reloadData()
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return tweets.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        
        return cell
        
    }
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "detailSegue" {
            let vc = segue.destination as! TweetViewController
            
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            let tweet = tweets[(indexPath?.row)!]
            vc.tweet = tweet
            
            let cell = sender as! UITableViewCell
            cell.selectionStyle = .gray
        }
        else if segue.identifier == "profileSegue" {
            let vc = segue.destination as! ProfileViewController
            
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)
                let tweet = tweets[(indexPath?.row)!]
                vc.user = tweet.user
            }
        }
        else if segue.identifier == "composeSegue" {
            let vc = segue.destination as! ComposeViewController
            vc.user = User.currentUser
        }
        else if segue.identifier == "replySegue" {
            let vc = segue.destination as! ComposeViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)
                let tweet = tweets[(indexPath?.row)!]
                vc.user = User.currentUser
                vc.replyText = "@" + String(describing: tweet.screenname!) + " "
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
