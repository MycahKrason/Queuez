//
//  JoinedQueuezVC.swift
//  Queuez
//
//  Created by Mycah on 8/7/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class JoinedQueuezVC: UIViewController {

    //Outlets
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var queueTitleDisplay: UILabel!
    @IBOutlet weak var queueSubtitleDisplay: UILabel!
    @IBOutlet weak var currentPlaceDisplay: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    //Received variables
    var receivedQueueTitle : String = ""
    var receivedQueueCode : String = ""
    var receivedQueueSubtitle : String = ""
    
    //Variables
    let user = Auth.auth().currentUser?.uid
    var userEmail = Auth.auth().currentUser?.email
    var userDisplayName : String = ""
    var membersArray : [MemberListObject] = [MemberListObject]()
    var notInQueue = "Removed"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queueTitleDisplay.text = receivedQueueTitle
        queueSubtitleDisplay.text = receivedQueueSubtitle

        //Set padding on info icon
        infoBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        //Set padding on back icon
        backBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
        //Set up the ad banner
        //TODO: change this to a DEPLOYMENT adUnitID
        //TEST
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //Legit - is legit
        bannerView.adUnitID = Private().ADMOB_BANNER_ID_JOINED
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        //Get and update your current number
        getCurrentNumber()
        
        //Set up the request Btn to be either Cancel Request - Rejoin Queue
        DataService.instance.REF_USERS.child(user!).child("JoinedQueuez").child(receivedQueueCode).observe(.value) { (snapshot) in
            if let joinedSnap = snapshot.value as? Dictionary<String, AnyObject>{
                let isJoined = joinedSnap["CurrentlyJoined"] as! Bool

                //Set the Display name here so we don't have to reach out to the DB later
                self.userDisplayName = joinedSnap["DisplayName"] as! String

                if isJoined{
                    self.requestBtn.setTitle("Cancel Request", for: .normal)
                }else{
                    self.requestBtn.setTitle("Rejoin Queue", for: .normal)
                }
            }
        }
    }
    
    func getCurrentNumber(){
        membersArray = []
        
        if let theUser = user{
            
            DataService.instance.REF_QUEUES.child(self.receivedQueueCode).observeSingleEvent(of: .value) { (snapshot) in
                
                if let membersSnapshot = snapshot.value as? Dictionary<String, AnyObject>{
                    
                    for child in membersSnapshot{
                        if child.key == "Members"{
                            print("\n\nThere are people here\n\n")
                            return
                        }else{
                            self.currentPlaceDisplay.text = self.notInQueue
                        }
                    }
                }
            }
            
            let ref = DataService.instance.REF_QUEUES.child(self.receivedQueueCode).child("Members")
            ref.observe(.childAdded, with: { (snapshot) in
                
                if let memberDict = snapshot.value as? Dictionary<String, AnyObject>{
                    
                    //make a list of the users
                    let memberItem = MemberListObject()
                    let userID = memberDict["UserID"] as? String
                    
                    memberItem.memberID = userID
                    
                    self.membersArray.append(memberItem)
                    
                }
                
                //find the user's index in the array, then add 1 to get their number
                let findIndex = self.membersArray.index{
                    
                    for child in self.membersArray{
                        
                        if $0.memberID == theUser{
                            return true
                        }
                    }
                    return false
                }
                
                if let foundIndex = findIndex {
                    self.currentPlaceDisplay.text = "\(foundIndex + 1)"
                }else{
                    self.currentPlaceDisplay.text = self.notInQueue
                }
                
                ref.observe(.childRemoved) { (snapshot2) in
                    
                    if let memberDict = snapshot2.value as? Dictionary<String, AnyObject>{
                        
                        //We get who was removed... find them in the array and have them removed
                        let userID = memberDict["UserID"] as? String
                        
                        let removeIndex = self.membersArray.index{
                            for child in self.membersArray{
                                
                                if $0.memberID == userID{
                                    return true
                                }
                                
                            }
                            self.currentPlaceDisplay.text = self.notInQueue
                            return false
                        }
                        
                        if let foundIndex = removeIndex{
                            
                            self.membersArray.remove(at: foundIndex)
                            
                        }
                        
                        //This updates your status
                        let findIndex = self.membersArray.index{
                            for child in self.membersArray{
                                
                                if $0.memberID == theUser{
                                    return true
                                }
                                
                            }
                            
                            return false
                        }
                        
                        print("\n\n\(findIndex)\n\n")
                        if let foundIndex = findIndex{
                            self.currentPlaceDisplay.text = "\(foundIndex + 1)"
                           
                        }else{
                            self.currentPlaceDisplay.text = self.notInQueue
                        }
                        
                    }
                }
                
            }, withCancel: nil)
            //End of Child added
        }
    }
    
    @IBAction func requestCancelBtnPressed(_ sender: Any) {
        //This will remove you from the members in queue, and change your joined status to false - also changing the button label to "Rejoin Queue"
        //Check if the JoinedCurrently is false or true - if true, remove user, else, add user
        DataService.instance.REF_USERS.child(user!).child("JoinedQueuez").child(receivedQueueCode).observeSingleEvent(of: .value) { (snapshot) in
            if let joinedSnap = snapshot.value as? Dictionary<String, AnyObject>{
                let isJoined = joinedSnap["CurrentlyJoined"] as! Bool
                if isJoined{
                    
                    //create alert for to make sure user is sure
                    let alertController = UIAlertController(title: nil, message:"Are you sure you want to be removed from the queue?", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
                        //Remove from Queuez if user wants to
                        DataService.instance.REF_QUEUES.observeSingleEvent(of: .value) { (snapshot) in
                            if let queuezSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                                for queue in queuezSnapshot{
                                    if queue.childSnapshot(forPath: "QueueCode").value as? String == self.receivedQueueCode{
                                        if let queueDict = queue.value as? Dictionary<String, AnyObject>{
                                            if let memberDict = queueDict["Members"] as? Dictionary<String, AnyObject>{
                                                for child in memberDict{
                                                    if let memberDict2 = child.value as? Dictionary<String, AnyObject>{
                                                        if memberDict2["UserID"] as? String == self.user! {
                                                            
                                                            //Remove from Queues
                                                            let deleteMember = DataService.instance.REF_QUEUES.child(self.receivedQueueCode).child("Members").child(child.key)

                                                            deleteMember.removeValue(completionBlock: { (error, ref) in
                                                                self.currentPlaceDisplay.text = self.notInQueue
                                                            })
                                                            
                                                            //Change Queue status to false
                                                            DataService.instance.REF_USERS.child(self.user!).child("JoinedQueuez").child(self.receivedQueueCode).updateChildValues(["CurrentlyJoined": false])
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }else{
                    //If you are here, that means CurrentlyJoined is false - you will want to Rejoin the queue
                    
                    //Add the user to the Queue as a member
                    DataService.instance.REF_QUEUES.child(self.receivedQueueCode).child("Members").childByAutoId().updateChildValues(["DisplayName" : self.userDisplayName, "UserID": self.user!], withCompletionBlock: { (error, ref) in

                        if error != nil{
                            print(error)
                            return
                        }

                        print("something should have saved")
                        let userQueue = DataService.instance.REF_USERS.child(self.user!).child("JoinedQueuez")

                        userQueue.child(self.receivedQueueCode).updateChildValues(["CurrentlyJoined" : true])

                    })
                }
            }
        }
        
    }
    
    @IBAction func removeQueueBtnPressed(_ sender: Any) {
        
        //Confirm that the user wants to Delete the Queue
        let alertController = UIAlertController(title: nil, message:"Are you sure you want to remove this Queue from your list of \"Joined Queuez\"?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
            //Remove from Queuez
            DataService.instance.REF_QUEUES.observeSingleEvent(of: .value) { (snapshot) in
                if let queuezSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                    for queue in queuezSnapshot{
                        if queue.childSnapshot(forPath: "QueueCode").value as? String == self.receivedQueueCode{
                            if let queueDict = queue.value as? Dictionary<String, AnyObject>{
                                if let memberDict = queueDict["Members"] as? Dictionary<String, AnyObject>{
                                    for child in memberDict{
                                        if let memberDict2 = child.value as? Dictionary<String, AnyObject>{
                                            if memberDict2["UserID"] as? String == self.user! {
                                                
                                                //Remove from Queues
                                                let deleteMember = DataService.instance.REF_QUEUES.child(self.receivedQueueCode).child("Members").child(child.key)
                                                
                                                //Remove from Users
                                                let deleteQueue = DataService.instance.REF_USERS.child(self.user!).child("JoinedQueuez").child(self.receivedQueueCode)
                                                
                                                deleteMember.removeValue()
                                                deleteQueue.removeValue()
                                                
                                                self.dismiss(animated: true, completion: nil)
                                                
                                            }else{
                                                //This will be the instance where the member is not found in the Queuez list because they have already removed themself. They just need to be removed from the Users list.
                                                //Remove from Users
                                                let deleteQueue = DataService.instance.REF_USERS.child(self.user!).child("JoinedQueuez").child(self.receivedQueueCode)
                                                
                                                
                                                deleteQueue.removeValue()
                                                
                                                self.dismiss(animated: true, completion: nil)
                                                
                                            }
                                        }
                                    }
                                }else{
                                    //This would happen if there are no member left
                                    let deleteQueue = DataService.instance.REF_USERS.child(self.user!).child("JoinedQueuez").child(self.receivedQueueCode)
                                    
                                    
                                    deleteQueue.removeValue()
                                    
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "joinedQueuezToModal"{
            let destVC = segue.destination as! InfoModalVC
            destVC.receivedInfo = "\"Your Current Place\" is your current place in the Queue. As other members are assisted, your number will decrease until you are number 1.\n\n\"Cancel Request\" will remove you from the Queue, losing your place in the Queue, however the Queue will still be listed in your \"Joined Queuez\" list, so you may easily rejoin. Please note that rejoining will put you at the end of the Queue.\n\n\"Remove Queue\" will remove you from the Queue, and also remove the Queue from your \"Joined Queuez\" list."
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
