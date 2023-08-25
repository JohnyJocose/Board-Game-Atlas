//
//  AccountSettingsTableViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 4/16/23.
//

import UIKit
import Firebase
import FirebaseAuth


class AccountSettingsTableViewController: UITableViewController {
    
    // list to give titles to table cells of this page
    let settingTypes = ["Change Profile Picture", "Change Username", "Change Password", "Delete Account"]

    override func viewDidLoad() {
        super.viewDidLoad()
        authAndAccordingly()

    }
    // make sure user is logged in; if not send to profile
    func authAndAccordingly(){
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "accountSettingToProfile", sender: nil)
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settingTypes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)

        let row = indexPath.row
        var content = cell.defaultContentConfiguration()
        
        content.text = settingTypes[row]
        // we need to show that delete account is dangerous
        if settingTypes[row] == "Delete Account"{
            content.textProperties.color = UIColor.red
        }
        else{
            content.textProperties.color = UIColor.black
        }
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        // send user to appropriate view controller to perform the fuction of
        // there name
        if settingTypes[row] == "Change Profile Picture"{
        
            performSegue(withIdentifier: "AccountToProfilePicture", sender: nil)
            
        }
        else if settingTypes[row] == "Change Username"{
        
            performSegue(withIdentifier: "accountToUsername", sender: nil)
            
        }
        else if settingTypes[row] == "Change Password"{
        
            performSegue(withIdentifier: "accountToPassword", sender: nil)
            
        }
        else if settingTypes[row] == "Delete Account"{
        
            performSegue(withIdentifier: "accountSettingToDelete", sender: nil)
            
        }
        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if segue.identifier == "AccountToProfilePicture", let nextVC = segue.destination as? ChangeProfilePictureViewController {
            
            nextVC.comingFrom = "Settings"
            nextVC.delegate = self
        }
        
        if segue.identifier == "accountToPassword", let nextVC = segue.destination as? FindAccountViewController {
            
            nextVC.comingFrom = "Settings"
            nextVC.delegate = self
        }
        
        
    }

}
