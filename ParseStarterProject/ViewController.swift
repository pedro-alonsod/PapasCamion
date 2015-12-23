/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var savePasswordSwitch: UISwitch!
    
    
    var userNow: PFUser!
    
    var saveInDevice: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let savedName = saveInDevice.stringForKey("username") {
            
            usernameText.text = savedName
        }
        
        if let savedPassword = saveInDevice.stringForKey("password") {
            
            passwordText.text = savedPassword
            
        }
        
        usernameText.delegate = self
        passwordText.delegate = self
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func logInTapped(sender: UIButton) {
        
        
        if usernameText.text != "" && passwordText.text != "" {
            
            
            saveInDevice.setObject(usernameText.text, forKey: "username")
            saveInDevice.setObject(passwordText.text, forKey: "password")
            
            
            PFUser.logInWithUsernameInBackground(usernameText.text!, password: passwordText.text!) {
                
                (user: PFUser?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    self.userNow = user
                    
                    self.performSegueWithIdentifier("CamionMapaTrackSegue", sender: self)
                    
                } else {
                    
                    print(" we got an error here \(error)")
                }
            }
            
            
        } else {
            
            displayError("Error", message: "Los campos no pueden esta vacios.")
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "CamionMapaTrackSegue" {
            
            let camionMapaTrackVC = segue.destinationViewController as! CamionMapaTrackViewController
            
            camionMapaTrackVC.userNow = self.userNow
        }
    }



    func displayError(error: String, message: String) {
        
        let alert: UIAlertController = UIAlertController(title: error, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { alert in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            })
        presentViewController(alert, animated: true, completion: nil)
    
    }


 func textFieldDidEndEditing(textField: UITextField) {
        
        textField.resignFirstResponder()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
    }


}
