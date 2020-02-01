//
//  ViewController.swift
//  Queuez
//
//  Created by Mycah on 8/6/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase


class LoginVC: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rememberMeToggleBtn: UISwitch!
    @IBOutlet weak var infoBtn: UIButton!
    
    let userDefaults = UserDefaults.standard
    var emailFromDefaults: String?
    var passwordFromDefaults: String?
    var didSaveDefaults: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set up Delegates
        emailField.delegate = self
        passwordField.delegate = self
        
        //Enable sign in button
        signInBtn.isEnabled = true
        
        //Set padding on info icon
        infoBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        //Get the email and password - if they are saved
        emailFromDefaults = userDefaults.string(forKey: "savedEmail")
        passwordFromDefaults = userDefaults.string(forKey: "savedPassword")
        
        didSaveDefaults = userDefaults.bool(forKey: "didSaveDefaults")
        if didSaveDefaults == true{
            rememberMeToggleBtn.isOn = true
        }else{
            rememberMeToggleBtn.isOn = false
        }
        emailField.text = emailFromDefaults
        passwordField.text = passwordFromDefaults
        
        //bind keyboard
        bindToKeyboard()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(_:)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Enable sign in button
        signInBtn.isEnabled = true
    }
    
    @objc func handleScreenTap(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }

    @IBAction func signInBtnPressed(_ sender: Any) {
        
        signInBtn.isEnabled = false
        
        //Save user Defaults if rememberMeBtn is on
        if rememberMeToggleBtn.isOn{
            //Save Data
            userDefaults.set(true, forKey: "didSaveDefaults")
            let enteredEmail = emailField.text
            userDefaults.set(enteredEmail, forKey: "savedEmail")
            let enteredPassword = passwordField.text
            userDefaults.set(enteredPassword, forKey: "savedPassword")
        }else{
            //Save empty defaults
            userDefaults.set("", forKey: "savedEmail")
            userDefaults.set("", forKey: "savedPassword")
            userDefaults.set(false, forKey: "didSaveDefaults")
        }
        
        if emailField.text != nil && passwordField.text != nil{
            self.view.endEditing(true)
            
            if let email = emailField.text, let password = passwordField.text{
                
                //First Try to sign in - if user doesnt exist, create the user
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if error == nil{
                        print("Signed in!")
                        //TODO: Segue loginToMain
                        self.performSegue(withIdentifier: "loginToMain", sender: nil)

                    }else{
                        //if there was an error, that means the user wasnt able to sign in
                        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                            
                            if error != nil{
                                self.signInBtn.isEnabled = true
                                //create alert for Error
                                let alertController = UIAlertController(title: nil, message:"The Email or Password you have entered is incorrect.\nIf assistance is needed, please visit\nwww.Hipstatronic.com", preferredStyle: UIAlertControllerStyle.alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                                self.present(alertController, animated: true, completion: nil)
                                
                            }else{
                                if let user = user{
                                    
                                    //Create users
                                    let userData = ["Email": email] as [String: Any]
                                    DataService.instance.createFBDBUser(uid: user.user.uid, userData: userData)
                                    
                                    //Segue loginToMain
                                    self.performSegue(withIdentifier: "loginToMain", sender: nil)
                                }
                                print("User Created!")
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToModal"{
            let destVC = segue.destination as! InfoModalVC
            destVC.receivedInfo = "For assistance with logging in or a password reset, please visit www.Hipstatronic.com\n\nTerms & Conditions\n\nBy downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy, or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, and you also shouldn’t try to translate the app into other languages, or make derivative versions. The app itself, and all the trade marks, copyright, database rights and other intellectual property rights related to it, still belong to Hipstatronic LLC.\n\nHipstatronic LLC is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for.\n\nThe Queuez app stores and processes personal data that you have provided to us, in order to provide our Service. It’s your responsibility to keep your phone and access to the app secure. We therefore recommend that you do not jailbreak or root your phone, which is the process of removing software restrictions and limitations imposed by the official operating system of your device. It could make your phone vulnerable to malware/viruses/malicious programs, compromise your phone’s security features and it could mean that the Queuez app won’t work properly or at all.\n\nYou should be aware that there are certain things that Hipstatronic LLC will not take responsibility for. Certain functions of the app will require the app to have an active internet connection. The connection can be Wi-Fi, or provided by your mobile network provider, but Hipstatronic LLC cannot take responsibility for the app not working at full functionality if you don’t have access to Wi-Fi, and you don’t have any of your data allowance left.\n\nIf you’re using the app outside of an area with Wi-Fi, you should remember that your terms of the agreement with your mobile network provider will still apply. As a result, you may be charged by your mobile provider for the cost of data for the duration of the connection while accessing the app, or other third party charges. In using the app, you’re accepting responsibility for any such charges, including roaming data charges if you use the app outside of your home territory (i.e. region or country) without turning off data roaming. If you are not the bill payer for the device on which you’re using the app, please be aware that we assume that you have received permission from the bill payer for using the app.\n\nAlong the same lines, Hipstatronic LLC cannot always take responsibility for the way you use the app i.e. You need to make sure that your device stays charged – if it runs out of battery and you can’t turn it on to avail the Service, Hipstatronic LLC cannot accept responsibility\n\nWith respect to Hipstatronic LLC’s responsibility for your use of the app, when you’re using the app, it’s important to bear in mind that although we endeavour to ensure that it is updated and correct at all times, we do rely on third parties to provide information to us so that we can make it available to you. Hipstatronic LLC accepts no liability for any loss, direct or indirect, you experience as a result of relying wholly on this functionality of the app.\n\nAt some point, we may wish to update the app. The app is currently available on iOS and Android – the requirements for system(and for any additional systems we decide to extend the availability of the app to) may change, and you’ll need to download the updates if you want to keep using the app. Hipstatronic LLC does not promise that it will always update the app so that it is relevant to you and/or works with the iOS or Android version that you have installed on your device. However, you promise to always accept updates to the application when offered to you, We may also wish to stop providing the app, and may terminate use of it at any time without giving notice of termination to you. Unless we tell you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must stop using the app, and (if needed) delete it from your device.\n\nChanges to This Terms and Conditions\n\nWe may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Terms and Conditions on this page. These changes are effective immediately after they are posted on this page.\n\n\nPrivacy Policy\n\nHipstatronic LLC built the Queuez app as a Free app. This SERVICE is provided by Hipstatronic LLC at no cost and is intended for use as is.\n\nThis page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.\n\nIf you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.\n\nThe terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Queuez unless otherwise defined in this Privacy Policy.\n\nInformation Collection and Use\n\nFor a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to Email. The information that we request will be retained by us and used as described in this privacy policy.\n\nThe app does use third party services that may collect information used to identify you.\n\nLink to privacy policy of third party service providers used by the app\n\n - AdMob\n\n - Firebase Analytics\n\nLog Data\n\nWe want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.\n\nCookies\n\nCookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.\n\nThis Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.\n\nService Providers\n\nWe may employ third-party companies and individuals due to the following reasons:\n\nTo facilitate our Service;\n\nTo provide the Service on our behalf;\n\nTo perform Service-related services; or\n\nTo assist us in analyzing how our Service is used.\n\nWe want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose. \n\nSecurity \n\nWe value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.\n\nLinks to Other Sites\n\nThis Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.\n\nChildren’s Privacy\n\nThese Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions.\n\nChanges to This Privacy Policy\n\nWe may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page."
        }
    }
    
    //Keyboard Stuff - this will only be on the login page as the keyboard will not be an issue on the other Views
    func bindToKeyboard(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification){
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curveFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curveFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
            self.view.frame.origin.y += deltaY
        }, completion: nil)
        
    }
}

