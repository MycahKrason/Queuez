//
//  InfoModalVC.swift
//  Queuez
//
//  Created by Mycah on 8/7/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit

class InfoModalVC: UIViewController {

    //Outlets
    @IBOutlet weak var termsPrivacyDesciption: UITextView!
    
    //received information
    var receivedInfo : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termsPrivacyDesciption.isScrollEnabled = false
        
        var myStringArr = receivedInfo?.components(separatedBy: " ")
        for child in myStringArr!{
            if child.count == 22{
                //Change font of this word
                
                let longestWordRange = (receivedInfo! as NSString).range(of: child)
                let attributedString = NSMutableAttributedString(string: receivedInfo!, attributes: [NSAttributedStringKey.font : UIFont(name: "RobotoSlab-Light", size: 17.0)!])

                attributedString.setAttributes([NSAttributedStringKey.font : UIFont(name: "Verdana", size: 18.0)!, NSAttributedStringKey.foregroundColor : UIColor.red], range: longestWordRange)

                termsPrivacyDesciption.attributedText = attributedString
                
                return
            }else{
                termsPrivacyDesciption.text = receivedInfo
                
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        termsPrivacyDesciption.textAlignment = .center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        termsPrivacyDesciption.isScrollEnabled = true
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
