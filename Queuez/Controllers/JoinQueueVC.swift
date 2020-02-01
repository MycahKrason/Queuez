//
//  JoinQueueVC.swift
//  Queuez
//
//  Created by Mycah on 8/6/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class JoinQueueVC: UIViewController, UITextFieldDelegate{
    
    //Outlets
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var queueCodeField: UITextField!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let userEmail = Auth.auth().currentUser?.email
    let userId = Auth.auth().currentUser?.uid
    
    var queueTitleToSend : String?
    var queueSubtitleToSend : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //bind keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        //Set up Delegates
        displayNameField.delegate = self
        queueCodeField.delegate = self
        
        //Set padding on info icon
        infoBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        ///Set padding on back icon
        backBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
        //Set up the ad banner
        //TODO: change this to a DEPLOYMENT adUnitID
        //TEST
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //Legit - is legit
        bannerView.adUnitID = Private().ADMOB_BANNER_ID_JOIN
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    @objc func handleScreenTap(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @IBAction func joinBtnPressed(_ sender: Any) {
        
        //Check to ensure that the display name and queue code fields are filled in - and that the queue code entered exists
        if (displayNameField.text?.isEmpty)! || (displayNameField.text?.hasPrefix(" "))! || (queueCodeField.text?.isEmpty)! || (queueCodeField.text?.hasPrefix(" "))! || (queueCodeField.text?.hasSuffix(" "))!{
            
            //Alert the user that they need to fill stuff in
            let alertController = UIAlertController(title: nil, message:"A Name and Queue Code must be provided.\n\nThere should not be any spaces before or after the text.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            //check that the queue code exists
            DataService.instance.REF_QUEUES.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let queuezSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    for queue in queuezSnapshot{
                        if queue.childSnapshot(forPath: "QueueCode").value as? String == self.queueCodeField.text!{
                            print("Correct Queue")
                            
                            if let queueDict = queue.value as? Dictionary<String, AnyObject>{
                                
                                self.queueTitleToSend = queueDict["Title"] as? String
                                self.queueSubtitleToSend = queueDict["Subtitle"] as? String
                                
                                if let memberDict = queueDict["Members"] as? Dictionary<String, AnyObject>{
                                    for child in memberDict{
                                        if let memberDict2 = child.value as? Dictionary<String, AnyObject>{
                                            if memberDict2["UserID"] as? String == self.userId! {
                                                //Alert the that the Queue Code was not found
                                                let alertController = UIAlertController(title: nil, message:"You are already a member of this Queue.", preferredStyle: UIAlertControllerStyle.alert)
                                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                                                self.present(alertController, animated: true, completion: nil)
                                                return
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                            //Add the user to the Queue as a member
                            DataService.instance.REF_QUEUES.child(self.queueCodeField.text!).child("Members").childByAutoId().updateChildValues(["DisplayName" : self.displayNameField.text!, "UserID": self.userId!, "Active": true], withCompletionBlock: { (error, ref) in
                                
                                    if error != nil{
                                        print(error)
                                        return
                                    }
                                
                                    print("something should have saved")
                                    let userQueue = DataService.instance.REF_USERS.child(self.userId!).child("JoinedQueuez")
                                
                                    userQueue.child(self.queueCodeField.text!).updateChildValues(["CurrentlyJoined" : true, "DisplayName" : self.displayNameField.text!])
                                
                                DataService.instance.REF_QUEUES.child(self.queueCodeField.text!).child("DeleteList").childByAutoId().updateChildValues(["UserID": self.userId!])
                                
                                })
                            
                            self.performSegue(withIdentifier: "joinToJoined", sender: nil)
                        }
                    }
                    //Alert the that the Queue Code was not found
                    let alertController = UIAlertController(title: nil, message:"The Queue Code you have entered was not found.\n\nThere should not be any spaces before or after the text.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }, withCancel: nil)
            
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //TODO set up transition
        
        if segue.identifier == "joinToJoined"{
            
            //Get the destination view controller
            let destVC = segue.destination as! JoinedQueuezVC
            //Send things to the destVC
            destVC.receivedQueueCode = queueCodeField.text!
            destVC.receivedQueueTitle = queueTitleToSend!
            destVC.receivedQueueSubtitle = queueSubtitleToSend!
            
        }else if segue.identifier == "joinToModal"{
            let destVC = segue.destination as! InfoModalVC
            destVC.receivedInfo = "The \"Display Name\" is the name you will be known by in the Queue. This will be visible to the entity who created the Queue.\n\nThe \"Queue Code\" is the unique password for the Queue you are trying to join. This will typically be distributed by the entity that created the Queue."
        }
    }
}
