//
//  MyQueuezVC.swift
//  Queuez
//
//  Created by Mycah on 8/7/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class MyQueuezVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Outlets
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    //Received variables
    var receivedQueueTitle : String = ""
    var receivedQueueCode : String = ""
    var receivedQueueSubtitle : String = ""
    
    //Variables
    var membersArray : [MemberListObject] = [MemberListObject]()
    let user = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up table delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        //Set up the ad banner
        //TODO: change this to a DEPLOYMENT adUnitID
        //TEST
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //Legit - is legit
        bannerView.adUnitID = Private().ADMOB_BANNER_ID_MYQUEUEZ
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        //Set up the title and the Subtitle
        titleLabel.text = receivedQueueTitle
        if let subtitle : String = receivedQueueSubtitle{
            subtitleLabel.text = subtitle
        }
        subtitleLabel.text = receivedQueueSubtitle
        
        //Set padding on info icon
        infoBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        //Set padding on back icon
        backBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
        fillMemberArray()
        
        //Set up Cell
        tableView.register(UINib(nibName: "MemberCell", bundle: nil), forCellReuseIdentifier: "memberCell")
      
    }
   
    func fillMemberArray(){
        
        membersArray = []
        
        if let theUser = user{
            let ref = DataService.instance.REF_QUEUES.child(self.receivedQueueCode).child("Members")
            
            ref.observe(.childAdded, with: { (snapshot) in
                
                
                if let memberDict = snapshot.value as? Dictionary<String, AnyObject>{
                    
                    //we have a list of the users
                    let memberItem = MemberListObject()
                    let userEmail = memberDict["Email"] as? String
                    let userDisplayName = memberDict["DisplayName"] as? String
                    let userID = memberDict["UserID"] as? String
                    
                    memberItem.memberEmail = userEmail
                    memberItem.memberName = userDisplayName
                    memberItem.memberID = userID
                            
                    self.membersArray.append(memberItem)
                            
                }
                self.tableView.reloadData()
                    
            }, withCancel: nil)
            
            ref.observe(.childRemoved) { (snapshot2) in
                if let memberDict = snapshot2.value as? Dictionary<String, AnyObject>{
                    
                    let userID = memberDict["UserID"] as? String
                    
                    let findIndex = self.membersArray.index{
                        for child in self.membersArray{
                        
                            if $0.memberID == userID{
                                return true
                            }
                            
                        }
                        return false
                    }
                    
                    if let removeIndex = findIndex{
                        
                        self.membersArray.remove(at: removeIndex)
                        
                    }
                    
                }
                self.tableView.reloadData()
            }
        }
        
    }

    @IBAction func cancelBtnPressed(_ sender: Any) {
        //This is the delete button
        
        //create alert for to make sure user is sure
        let alertController = UIAlertController(title: nil, message:"Are you sure you want to delete this Queue?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
            
            DataService.instance.REF_QUEUES.child(self.receivedQueueCode).child("DeleteList").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let deleteDict = snapshot.value as? Dictionary<String, AnyObject>{
                    
                    for child in deleteDict{
                        if let delete = child.value as? Dictionary<String, AnyObject>{
                            let userToBeDeleted = delete["UserID"] as! String
                            let removeFromMembersJoinedList = DataService.instance.REF_USERS.child(userToBeDeleted).child("JoinedQueuez").child(self.receivedQueueCode)
                            removeFromMembersJoinedList.removeValue()
                        }
                    }
                }
                
                let removeQueueFromQueuez = DataService.instance.REF_QUEUES.child(self.receivedQueueCode)
                removeQueueFromQueuez.removeValue()
                let removeQueueFromMember = DataService.instance.REF_USERS.child(self.user!).child("MyQueuez").child(self.receivedQueueCode)
                removeQueueFromMember.removeValue()
                
            })
            
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: TABLE STUFF
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! MemberCell
        
        cell.memberName.text = membersArray[indexPath.row].memberName
        cell.queueNumber.text = "\(indexPath.row + 1)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return membersArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: nil, message:"Are you sure you want to remove this Member?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
            //remove user from the Queuez
            DataService.instance.REF_QUEUES.child(self.receivedQueueCode).child("Members").observeSingleEvent(of: .value, with: { (snapshot) in
                
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    
                    
                    if snap.childSnapshot(forPath: "UserID").value as? String == self.membersArray[indexPath.row].memberID{
                        
                        let userToBeDeletedFromQueuez = DataService.instance.REF_QUEUES.child(self.receivedQueueCode).child("Members").child(snap.key)
                        
                        
                        let userToBeDeletedFromUsers = DataService.instance.REF_USERS.child(self.membersArray[indexPath.row].memberID!).child("JoinedQueuez").child(self.receivedQueueCode)
                        
                        userToBeDeletedFromQueuez.removeValue()
                        userToBeDeletedFromUsers.updateChildValues(["CurrentlyJoined": false])
                        
                    }
                }
                //self.tableView.reloadData()
            })
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myQueuezToModal"{
            let destVC = segue.destination as! InfoModalVC
            destVC.receivedInfo = "The Queue Code for this Queue is as follows: \n\n \"\(receivedQueueCode)\" \n\nDistribute this code to people you want to join your Queue. \n\nClick on a member to remove them from the Queue.\n\nPress \"Delete Queue\" if you would like to delete the Queue and have it removed from your \"My Queuez\" list."
        }
    }
}
