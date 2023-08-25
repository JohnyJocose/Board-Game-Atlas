//
//  ChangeUsernameViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 4/17/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ChangeUsernameViewController: UIViewController {
    
    @IBOutlet weak var currentUsernameLabel: UILabel!

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var newUsernameErrorLabel: UILabel!
    
    @IBOutlet weak var newUsernameTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        newUsernameErrorLabel.isHidden = true
        isSignedIn()
        populateCurrentUsername()

    }
    
    // check if username is satifying; if it is we change it on the firebase
    @IBAction func changeUsernameButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        errorLabel.text = ""
        errorLabel.isHidden = true
        
        if checkUsernameRequirements(){
            let newUsername = newUsernameTextfield.text
            changeUsernameFirebase(newUsername: newUsername!)
        }
    }
    
    func isSignedIn(){
        
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "changeProfileToProfile", sender: nil)
        }
        
    }
    
    // check textfield requirments
    func checkUsernameRequirements() -> Bool{
        
        var correctFormat = true
        // check for username length
        if newUsernameTextfield.text!.count < 2 {
            let incorrectError = "Sorry, your username must be 2 or more characters in length. Please choose a longer username and try again."
            errorLabel.text = incorrectError
            errorLabel.isHidden = false
            correctFormat = false
            
        }
        
        // max name length of 40
        if newUsernameTextfield.text!.count > 20 {
            let incorrectError = "Sorry, your username must be 20 characters or less in length. Please choose a shorter username and try again."
            errorLabel.text = incorrectError
            errorLabel.isHidden = false
            correctFormat = false

        }
        
        return correctFormat
        
    }
    
    // function to change username in that users firebase database
    func changeUsernameFirebase(newUsername:String){
        
        errorLabel.text = ""
        errorLabel.isHidden = true
        
        let database = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        
        let databaseRef = database.child("users").child(userID!)
        
        databaseRef.updateChildValues(["username" : newUsername]) { (error, ref) in
            guard error == nil else{
                self.errorLabel.text = "Sorry, we couldn't change your username. Please try again."
                self.errorLabel.isHidden = false
                return
            }
            let alertContoller = UIAlertController(title: "Username Changed", message: "Congratulations! Your username has been successfully updated.", preferredStyle: .alert)
            alertContoller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                needsFirebaseUpdate = true
                self.performSegue(withIdentifier: "UsernameToProfile", sender: nil)
                
            }))
            self.present(alertContoller, animated: true, completion: nil)
        }
        
        
    }
    
    // show the users current user name
    func populateCurrentUsername(){
        errorLabel.text = ""
        errorLabel.isHidden = true
        newUsernameErrorLabel.isHidden = true
        
        _Concurrency.Task {
            
            do {
                
                let database = Database.database().reference()
                let userID = Auth.auth().currentUser?.uid
                
                let databaseRef = database.child("users").child(userID!).child("username")
                let Snapshot : DataSnapshot = try await databaseRef.getData()
                
                if let data = Snapshot.value as? String{
                    currentUsernameLabel.text = data
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
