//
//  DeleteViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 4/17/23.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class DeleteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // check if they are logged in; we want to take any action to not be in this screen
    func isSignedIn(){
        
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "deleteToProfile", sender: nil)
        }
        
    }
    
    // warning to make sure they truly do want to delete their account
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alertContoller = UIAlertController(title: "Delete Account?!", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        alertContoller.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { (_) in
            self.deleteProfile()
        }))
        alertContoller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        self.present(alertContoller, animated: true, completion: nil)
    }
    
    // delete profile and if they are sign in; which they shouldnt be; then they should be taken to profile picture
    func deleteProfile(){
        let user = Auth.auth().currentUser
        user?.delete { error in
          if let error = error {
            // An error happened.
          } else {
              self.isSignedIn()
          }
        }
    }
}
