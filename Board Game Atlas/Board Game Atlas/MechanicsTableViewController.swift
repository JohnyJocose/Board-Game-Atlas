//
//  MechanicsTableViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 4/10/23.
//

import UIKit

class MechanicsTableViewController: UITableViewController {
    
    // array so we can populate the table
    var mechTypes : Array<MechClass> = []
    
    // storyboard reference
    @IBOutlet var mechTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // async function to call different types of mechanics
        // spinner is performed during it
        Task {
            
            self.showSpinnerHome(onView: self.view)
            
            let result = try await MechJson.getMechDataAsync(urlString: "https://api.boardgameatlas.com/api/game/mechanics?pretty=true&client_id=PTMfSPtwDh")
            
            getMechList(json: result)
            self.mechTable.reloadData()
            self.removeSpinnerHome()
             
        }
    }
    
    // API Code
    
    func getMechList(json:MechStruct) {

        let mechLimit = json.mechanics.count
        if mechLimit == 0{
            return
        }
        // for loop going through every mech object that was brought by the url request
        for title in 0...mechLimit-1{
            
            mechTypes.append(MechClass(
                id: json.mechanics[title].id ?? "N/A",
                name: json.mechanics[title].name ?? "N/A"
            ))
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mechTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mechCell", for: indexPath)
        let row = indexPath.row
        
        var content = cell.defaultContentConfiguration()
        content.text = mechTypes[row].name
        content.textProperties.color = UIColor.black
        cell.contentConfiguration = content

        return cell
    }
    
    // function that determines what to do depending on which cell was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        performSegue(withIdentifier: "mechToPsuedo", sender: mechTypes[row])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // send user to psuedo home page with information such as what to search for and
        // where we just came from because that page has a lot of ways to enter
        if segue.identifier == "mechToPsuedo", let nextVC = segue.destination as? PsuedoHomeViewController, let gameInfo = sender as? MechClass {
            nextVC.comingFrom = "Mechanic"
            nextVC.mechName = gameInfo.name
            nextVC.mechID = gameInfo.id
            nextVC.delegate = self
        }
    }
}
