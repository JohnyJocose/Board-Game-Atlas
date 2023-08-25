//
//  SignUpViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 2/27/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var mainErrorLabel: UILabel!
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var usernameTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var usernameErrorLabel: UILabel!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailErrorLabel.isHidden = true
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        confirmPasswordErrorLabel.isHidden = true
        mainErrorLabel.isHidden = true
    }
    
    // code similar to log in but creates user instead
    @IBAction func signUpButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        if !anyErrorsWithTextfields(){
            guard let email = emailTextfield.text else {return}
            guard let username = usernameTextfield.text else {return}
            guard let password = passwordTextfield.text else {return}
            
            createUser(email: email, password: password, username: username)
            
            
        }
        
        
    }
    
    // check for errors in checkfield and shows which label is needed
    func anyErrorsWithTextfields() -> Bool{
        
        var errorChecker = false
        var emptyChecker = false
        
        // make errors hidden again if the button has been pressed
        emailErrorLabel.isHidden = true
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        confirmPasswordErrorLabel.isHidden = true
        mainErrorLabel.isHidden = true
        
        // check to see if the textfields are empty, print errors if so
        if emailTextfield.text!.isEmpty == true{
            emailErrorLabel.isHidden = false
            errorChecker = true
            emptyChecker = true
        }
        if usernameTextfield.text!.isEmpty == true{
            usernameErrorLabel.isHidden = false
            errorChecker = true
            emptyChecker = true
            
        }
        if passwordTextfield.text!.isEmpty == true{
            passwordErrorLabel.isHidden = false
            errorChecker = true
            emptyChecker = true
        }
        if confirmPasswordTextfield.text! != passwordTextfield.text!{
            confirmPasswordErrorLabel.isHidden = false
            errorChecker = true
            emptyChecker = true
        }
        
        // check for valid email format in email textfield
        if !emptyChecker && !validateEmail(enteredEmail: emailTextfield.text!){
            let incorrectError = "Invalid Email"
            mainErrorLabel.text = incorrectError
            mainErrorLabel.isHidden = false
            errorChecker = true
            emptyChecker = true
            
        }
        
        // check for username length
        if !emptyChecker && usernameTextfield.text!.count < 2 {
            let incorrectError = "At least 2 characters are required for username"
            mainErrorLabel.text = incorrectError
            mainErrorLabel.isHidden = false
            errorChecker = true
            
            
        }
        
        // max name length of 40
        if !emptyChecker && usernameTextfield.text!.count > 20 {
            let incorrectError = "Username's character length must be 20 or under"
            mainErrorLabel.text = incorrectError
            mainErrorLabel.isHidden = false
            errorChecker = true
        }

        
        // firebase does not create an account on their part
        if !emptyChecker && passwordTextfield.text!.count <= 5 {
            let incorrectError = "A minimum password length of 6 is required"
            mainErrorLabel.text = incorrectError
            mainErrorLabel.isHidden = false
            errorChecker = true
            
            
        }
        
        return errorChecker
    }
    
    func validateEmail(enteredEmail:String) -> Bool {

        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)

    }
    
    
    func createUser(email: String, password: String, username: String){
        
        self.showSpinnerProfile(onView: self.view)
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            
            
            guard error == nil else{
                self.mainErrorLabel.text = "Account already exist; please log in"
                self.mainErrorLabel.isHidden = false
                return
            }
            
            guard let uid = result?.user.uid else {return}
            
            // set a default picture automatically
            let values = ["email": email, "username": username, "profilePictureID": "https://firebasestorage.googleapis.com/v0/b/board-game-connect.appspot.com/o/DefaultProfilePicture.png?alt=media&token=2653c703-9343-4f14-a814-156364e1a94e"]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock:{ (error, ref) in
                guard error == nil else{
                    self.removeSpinnerProfile()
                    self.mainErrorLabel.text = "We ran into an error; please try again"
                    self.mainErrorLabel.isHidden = false
                    return
                }
                
                self.removeSpinnerProfile()
                
                let alertContoller = UIAlertController(title: "Account Created", message: "Take profile picture?", preferredStyle: .actionSheet)
                alertContoller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                    self.performSegue(withIdentifier: "signUpToProfilePic", sender: nil)
                    
                }))
                alertContoller.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
                    self.performSegue(withIdentifier: "signUpToProfile", sender: nil)
                    
                }))
                self.present(alertContoller, animated: true, completion: nil)
            })
            
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
