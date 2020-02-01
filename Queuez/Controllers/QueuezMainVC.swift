//
//  QueuezMainVC.swift
//  Queuez
//
//  Created by Mycah on 8/6/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase

class QueuezMainVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var segmentedControlBtn: UISegmentedControl!
    
    //variables
    var myQueuezArray: [QueueListObject] = [QueueListObject]()
    var joinedQueuezArray: [QueueListObject] = [QueueListObject]()
    
    let user = Auth.auth().currentUser?.uid
    
    var ref : DatabaseReference?
    var ref2 : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set padding on info icon
        infoBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        //Set up Cell
        tableView.register(UINib(nibName: "QueueCell", bundle: nil), forCellReuseIdentifier: "queueCell")
        
        //change color or separator
        tableView.separatorColor = UIColor(red: 112/255, green: 205/255, blue: 255/255, alpha: 1.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Stup tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        fillQueueArray()
    }
    
    //fill the array with My queue items
    func fillQueueArray(){
        if let theUser = user{
            
            myQueuezArray = []
            joinedQueuezArray = []
            
            ref = DataService.instance.REF_USERS.child(theUser).child("MyQueuez")
            
            ref?.observe(.childAdded, with: { (snapshot) in
                
                let queueID = snapshot.key
                let queueReference = DataService.instance.REF_QUEUES.child(queueID)
                queueReference.observeSingleEvent(of: .value, with: { (snapshot2) in
                    
                    if let vendorDict = snapshot2.value as? Dictionary<String, AnyObject>{
                        
                        //Create the queue object and append it to the array
                        let queueItem = QueueListObject()
                        queueItem.title = vendorDict["Title"] as? String
                        queueItem.subtitle = vendorDict["Subtitle"] as? String
                        queueItem.queueCode = vendorDict["QueueCode"] as? String
                        
                        self.myQueuezArray.append(queueItem)
                        self.tableView.reloadData()
                        
                    }
                }, withCancel: nil)
            }, withCancel: nil)
            
            //Joined
            ref2 = DataService.instance.REF_USERS.child(theUser).child("JoinedQueuez")
            
            ref2?.observe(.childAdded, with: { (snapshot) in
                
                let queueID = snapshot.key
                let queueReference = DataService.instance.REF_QUEUES.child(queueID)
                queueReference.observeSingleEvent(of: .value, with: { (snapshot2) in
                    
                    if let vendorDict = snapshot2.value as? Dictionary<String, AnyObject>{
                        
                        print(vendorDict)
                        
                        //Create the queue object and append it to the array
                        let queueItem = QueueListObject()
                        queueItem.title = vendorDict["Title"] as? String
                        queueItem.subtitle = vendorDict["Subtitle"] as? String
                        queueItem.queueCode = vendorDict["QueueCode"] as? String
                        
                        self.joinedQueuezArray.append(queueItem)
                        self.tableView.reloadData()
                        
                    }
                    
                }, withCancel: nil)
                
            }, withCancel: nil)
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    //Table Stuff
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Set the cell to be the custom queueCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as! QueueCell
        
        //Get the cell information depending on whether you have chosen My Queuez or Joined Queuez
        if self.segmentedControlBtn.selectedSegmentIndex == 0{
            //Set up MyQueuez cells
            cell.queueTitle.text = myQueuezArray[indexPath.row].title
            cell.queueSubtitle.text = myQueuezArray[indexPath.row].subtitle
            
        }else{
            //Set up JoinedQueuez cells
            cell.queueTitle.text = joinedQueuezArray[indexPath.row].title
            cell.queueSubtitle.text = joinedQueuezArray[indexPath.row].subtitle
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.segmentedControlBtn.selectedSegmentIndex == 0{
            return myQueuezArray.count
        }else{
            //TODO: retrun the proper amount of cells for Joined Queuez
            return joinedQueuezArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.segmentedControlBtn.selectedSegmentIndex == 0{
            
            performSegue(withIdentifier: "queuezToMyQueuez", sender: nil)
        }else{
            performSegue(withIdentifier: "queuezToJoinedQueuez", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mainToModal"{
            let destVC = segue.destination as! InfoModalVC
            destVC.receivedInfo = "\"My Queuez\" will provide a list of the Queuez that you have created.\n\n\"Joined Queuez\" will provide a list of the Queuez you have joined.\n\n\"Create Queue\" will create a Queue to allow others to join.\n\n\"Join Queue\" will let you join a Queue if you have a Queue Code."
        }
        
        //Get the indexPath so we know what was clicked
        if let indexPath = tableView.indexPathForSelectedRow{
            
            self.ref?.removeAllObservers()
            self.ref2?.removeAllObservers()
            
            if segue.identifier == "queuezToMyQueuez"{
                
                let sendQueueCode = myQueuezArray[indexPath.row].queueCode
                let sendQueueTitle = myQueuezArray[indexPath.row].title
                let sendQueueSubtitle = myQueuezArray[indexPath.row].subtitle
                
                //Get the destination view controller
                let destVC = segue.destination as! MyQueuezVC
                //Send things to the destVC
                destVC.receivedQueueCode = sendQueueCode!
                destVC.receivedQueueTitle = sendQueueTitle!
                destVC.receivedQueueSubtitle = sendQueueSubtitle!
            }else if segue.identifier == "queuezToJoinedQueuez"{
                
                let sendQueueCode = joinedQueuezArray[indexPath.row].queueCode
                let sendQueueTitle = joinedQueuezArray[indexPath.row].title
                let sendQueueSubtitle = joinedQueuezArray[indexPath.row].subtitle
                
                //Get the destination view controller
                let destVC = segue.destination as! JoinedQueuezVC
                //Send things to the destVC
                destVC.receivedQueueCode = sendQueueCode!
                destVC.receivedQueueTitle = sendQueueTitle!
                destVC.receivedQueueSubtitle = sendQueueSubtitle!
                
            }
        }
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
