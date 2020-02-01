//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
      
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
       
    }
    
    @IBAction func loginViaWebsiteTapped() {
     //   performSegue(withIdentifier: "completeLogin", sender: nil)
    print ("Get token")
          TMDBClient.getApiToke(completionHandler: handleFirstResponse(success:err:))
   
    }
    


    func handleGetSessionIDResponse(success:Bool , error:Error?){
        print ("The session id is : \(TMDBClient.Auth.sessionId)")
        if (success){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
          
        }
    }
    
    func handleLoginResponse(success:Bool , err:Error?)->Void{
        print ("success")
        print (TMDBClient.Auth.requestToken)
        TMDBClient.getSessionID(completionHandler: handleGetSessionIDResponse(success:error:))
    }
    
    func handleFirstResponse(success:Bool , err:Error?)->Void{
           print ("first response")
        if (success){
            DispatchQueue.main.async {
                  TMDBClient.authWithLogin(userName: self.emailTextField.text!, password: self.passwordTextField.text!, completionHandler: self.handleLoginResponse(success:err:))
            }
           
        }
       }
}
