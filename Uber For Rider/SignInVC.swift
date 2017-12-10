//
//  SignInVC.swift
//  Uber For Rider
//
//  Created by Shreyash Kawalkar on 07/12/17.
//  Copyright © 2017 Sk. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    private let Rider_Segue = "RiderVC"
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func logIn(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProviders.instance.signIn(email: emailTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in if message != nil {
                self.alertTheUser(title: "Problem With Authentication", message: message!)
            }
            else {
                UberHandler.instance.rider = self.emailTextField.text!
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.performSegue(withIdentifier: self.Rider_Segue, sender: nil)
                }
            })
        }else{
            alertTheUser(title: "Email and Password are required", message: "Please enter email and password in the field")}
        

    }
    
    @IBAction func signUp(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProviders.instance.signUp(email: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in if message != nil {
                self.alertTheUser(title: "Problem With Authentication", message: message!)
            }
            else {
                
                UberHandler.instance.rider = self.emailTextField.text!
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                //UberHandler.instance.
                self.performSegue(withIdentifier: self.Rider_Segue, sender: nil)                }
            })
        }
        else{
            alertTheUser(title: "Email and Password are required", message: "Please enter email and password in the field")}
        

    }
    
    func alertTheUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title : "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
