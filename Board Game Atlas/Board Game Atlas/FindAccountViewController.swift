//
//  FindAccountViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 2/27/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FindAccountViewController: UIViewController {
    
    @IBOutlet weak var resetPasswordTextfield: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    var comingFrom = ""
    var delegate: UIViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailErrorLabel.isHidden = true
        errorLabel.isHidden = true
        // we need to check where it's from; determined by coming from variable
        // if from account settings then we check if signed in; if not we send to profile page
        if comingFrom == "Settings"{
            isSignedIn()
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        // make key board go away when pressed to see message
        self.view.endEditing(true)
        // check if textfield is empty or not
        if resetPasswordTextfield.text != ""{
            // if form account settings we check if email is the same as logged in to send reset password
            if comingFrom == "Settings"{
                verifyEmailAndActAccordingly()
            }
            else{
                // if not we just send it because theres no need to verify
                sendResetEmail(textfieldString: resetPasswordTextfield.text!)
            }
        }
        else{
            // if empty present error
            emailErrorLabel.isHidden = false
        }
    }
    
    func isSignedIn(){
        
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "resetToProfile", sender: nil)
        }
        
    }
    
    // send reset email; user has to go to their email;
    func sendResetEmail(textfieldString: String){
        
        self.showSpinnerProfile(onView: self.view)
        
        errorLabel.text = ""
        errorLabel.isHidden = true
        emailErrorLabel.isHidden = true
        Auth.auth().sendPasswordReset(withEmail: textfieldString) { error in
            if error != nil {
                self.errorLabel.text = "We could not find an account associated with the email address you entered. Please check and try again or create a new account if you haven't signed up yet."
                self.removeSpinnerProfile()
            }
            self.errorLabel.text = "An email has been sent to your email address with instructions on how to reset your password. Please check your inbox (and your spam folder, just in case!) and follow the steps provided in the email to reset your password."
            self.removeSpinnerProfile()
            self.errorLabel.isHidden = false
        }
        
        
    }
    // verify email entered is same as currentlh logged in
    func verifyEmailAndActAccordingly(){
        
        errorLabel.text = ""
        errorLabel.isHidden = true
        emailErrorLabel.isHidden = true
        
        _Concurrency.Task {
            
            do {
                
                let database = Database.database().reference()
                let userID = Auth.auth().currentUser?.uid
                
                
                
                let databaseRef = database.child("users").child(userID!).child("email")
                
                let Snapshot : DataSnapshot = try await databaseRef.getData()
                
                if let data = Snapshot.value as? String{
                    
                    if data == resetPasswordTextfield.text{
                        
                        Auth.auth().sendPasswordReset(withEmail: data) { error in
                            self.errorLabel.text = "An email has been sent to your registered email address with instructions on how to reset your password. Please check your inbox (and your spam folder, just in case!) and follow the steps provided in the email to reset your password."
                            self.errorLabel.isHidden = false
                        }
                        
                    }
                    else{
                        self.errorLabel.text = "Sorry, the email you entered does not match our records. Please check and try again"
                        self.errorLabel.isHidden = false
                    }
                    
                }

                
                else{
                    print("no data exist")
                }
                
            } catch {
                print("Something went wrong with firebase data")

            }
            
        }
        
    }

    // code to enable tapping on the background to remove software keyboard
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
}
