//
//  SettingTableViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 4/16/23.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingTableViewController: UITableViewController {
    
    var delegate: UIViewController!

    var gameObjectLists : Array<Array<BoardGameItems>> = []
    
    var selectedSetting = ""
    
    
    // list to get titiles of table cell
    let settingTypes = ["Account", "Bookmarks", "Wishlist", "Own", "Sign Out"]

    override func viewDidLoad() {
        super.viewDidLoad()
        authAndAccordingly()
    }
    
    func authAndAccordingly(){
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "settingToProfile", sender: nil)
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)

        let row = indexPath.row
        var content = cell.defaultContentConfiguration()
        
        content.text = settingTypes[row]
        // sign out should be in red text and account should be bolded because i felt
        // like those an important to stand out
        if settingTypes[row] == "Sign Out"{
            content.textProperties.color = UIColor.red
        }
        else if settingTypes[row] == "Account"{
            content.textProperties.font = UIFont.boldSystemFont(ofSize: 18)
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
        
        if settingTypes[row] == "Bookmarks"{
            
            selectedSetting = "Bookmarks"
            
            performSegue(withIdentifier: "settingToPsuedo", sender: gameObjectLists[0])
        }
        else if settingTypes[row] == "Wishlist"{
            selectedSetting = "Wishlist"
            
            performSegue(withIdentifier: "settingToPsuedo", sender: gameObjectLists[1])
        }
        else if settingTypes[row] == "Own"{
            
            selectedSetting = "Own"
            
            performSegue(withIdentifier: "settingToPsuedo", sender: gameObjectLists[2])
        }
        else if settingTypes[row] == "Account"{
            
            performSegue(withIdentifier: "settingToAccount", sender: nil)
        }
        // if sign out is pressed we want to make sure if they want to do this;
        //if they do thn we sign out
        else if settingTypes[row] == "Sign Out"{
            
            let alertContoller = UIAlertController(title: "Sign Out?", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
            alertContoller.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
                self.signOut()
                self.performSegue(withIdentifier: "settingToProfile", sender: nil)

            }))
            alertContoller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertContoller, animated: true, completion: nil)
            
        }
        
    }
    
    //Firebase API Code
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        }
        catch _{
            print("failed to sign out")
        }
    }
    
    // send psuedo that we are coming from either bookmarks,wishlist, or own
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if segue.identifier == "settingToPsuedo", let nextVC = segue.destination as? PsuedoHomeViewController {
            let gameList = sender as? Array<BoardGameItems>
            nextVC.comingFrom = selectedSetting
            nextVC.gameObjectList = gameList!
            nextVC.delegate = self
        }
        
        
    }

}
