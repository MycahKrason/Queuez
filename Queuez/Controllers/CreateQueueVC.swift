//
//  CreateQueueVC.swift
//  Queuez
//
//  Created by Mycah on 8/6/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class CreateQueueVC: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var queueTitleField: UITextField!
    @IBOutlet weak var queueSubtitleField: UITextField!
    @IBOutlet weak var bannerView: GADBannerView!
    
    //Var to send
    var queueCode : String = ""
    
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //bind keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        //Set up Delegates
        queueTitleField.delegate = self
        queueSubtitleField.delegate = self
        
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
        //Legit
        bannerView.adUnitID = Private().ADMOB_BANNER_ID_CREATE
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    @objc func handleScreenTap(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @IBAction func createBtnPressed(_ sender: Any) {
        print(1)
        
        if let userID : String = Auth.auth().currentUser?.uid{
           
            //check to make sure a Title has been added
            if (queueTitleField.text?.isEmpty)! || (queueTitleField.text?.hasPrefix(" "))!{
                
                //Let the user know that they must enter a title
                let alertController = UIAlertController(title: nil, message:"A Title must be entered to create a Queue.\n\nThere should not be any spaces before the text.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                
                let ref = DataService.instance.REF_QUEUES.childByAutoId()
                let queueIdName = ref.key
                queueCode = queueIdName
                
                ref.updateChildValues(["Title": queueTitleField.text!, "Subtitle": queueSubtitleField.text!, "QueueCode": queueIdName]) { (error, ref) in
                    
                    if error != nil{
                        print(error)
                        return
                    }
                    
                    print("something should have saved")
                    let userQueue = DataService.instance.REF_USERS.child(userID).child("MyQueuez")
                    let queueIdName = ref.key
                    
                    userQueue.updateChildValues([queueIdName : 1])
                    
                }
                
                performSegue(withIdentifier: "createToMyQueuez", sender: nil)
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createToMyQueuez"{
            
            //Get the destination view controller
            let destVC = segue.destination as! MyQueuezVC
            
            let sendQueueCode = queueCode
            let sendQueueTitle = queueTitleField.text!
            let sendQueueSubtitle = queueSubtitleField.text!
            
            //Send things to the destVC
            destVC.receivedQueueCode = sendQueueCode
            destVC.receivedQueueTitle = sendQueueTitle
            destVC.receivedQueueSubtitle = sendQueueSubtitle
            
        }else if segue.identifier == "createToModal"{
            let destVC = segue.destination as! InfoModalVC
            destVC.receivedInfo = "The \"Queue Title\" is required, and will be the title of the Queue.\n\nThe \"Queue Subtitle\" is optional, but may be helpful if your \"Queue Title\" is the same for multiple Queuez."
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
    
}
