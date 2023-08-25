//
//  LogInViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 2/20/23.
//

import UIKit
import FirebaseAuth
import Firebase


class LogInViewController: UIViewController {
    
    // storyboard references
    
    @IBOutlet weak var mainErrorLabel: UILabel!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var emailTextfieldLabel: UITextField!
    
    @IBOutlet weak var passwordTextfieldLabel: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide labels
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        mainErrorLabel.isHidden = true
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        // we want to remove keyboard so we can see error label just in case
        self.view.endEditing(true)
        // check to see if anything is wrong with textfields
        if !anyErrorsWithTextfields(){
            guard let email = emailTextfieldLabel.text else {return}
            guard let password = passwordTextfieldLabel.text else {return}
            
            // log the user in
            logUserIn(email: email, password: password)
        }
        
    }
    
    
    func anyErrorsWithTextfields() -> Bool{
        
        var errorChecker = false
        var emptyChecker = false
        
        // make errors hidden again if the button has been pressed
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        mainErrorLabel.isHidden = true
        
        // check to see if the textfields are empty, print errors if so
        if emailTextfieldLabel.text!.isEmpty == true{
            emailErrorLabel.isHidden = false
            errorChecker = true
            emptyChecker = true
        }
        if passwordTextfieldLabel.text!.isEmpty == true{
            passwordErrorLabel.isHidden = false
            errorChecker = true
            emptyChecker = true
        }
        // check for valid email format in email textfield
        if !emptyChecker && !validateEmail(enteredEmail: emailTextfieldLabel.text!){
            let incorrectError = "Invalid Email"
            mainErrorLabel.text = incorrectError
            mainErrorLabel.isHidden = false
            errorChecker = true
            emptyChecker = true
            
        }
        
        return errorChecker
    }
    
    // check if its in an email format
    func validateEmail(enteredEmail:String) -> Bool {

        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)

    }
    
    
    // Firebase API
    func logUserIn(email: String, password: String){
        self.showSpinnerProfile(onView: self.view)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard error == nil else{
                self.removeSpinnerProfile()
                self.mainErrorLabel.text = "Invalid log in"
                self.mainErrorLabel.isHidden = false
                
                return
            }
            //Log in succesful
            self.performSegue(withIdentifier: "logInToProfile", sender: nil)
            self.removeSpinnerProfile()
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
