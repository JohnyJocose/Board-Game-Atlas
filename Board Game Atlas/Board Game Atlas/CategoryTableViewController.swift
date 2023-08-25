//
//  CategoryTableViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 4/10/23.
//

import UIKit

// comments same as mechanics file but in terms of categories
class CategoryTableViewController: UITableViewController {
    
    var cateTypes : Array<CateClass> = []
    @IBOutlet var cateTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            self.showSpinnerHome(onView: self.view)
            let result = try await CateJson.getCateDataAsync(urlString: "https://api.boardgameatlas.com/api/game/categories?pretty=true&client_id=PTMfSPtwDh")
            getCateList(json: result)
            self.cateTable.reloadData()
            self.removeSpinnerHome()
             
        }
    }
    
    // API Code
    
    func getCateList(json:CateStruct) {

        let cateLimit = json.categories.count
        if cateLimit == 0{
            return
        }
        for title in 0...cateLimit-1{
            
            cateTypes.append(CateClass(
                id: json.categories[title].id ?? "N/A",
                name: json.categories[title].name ?? "N/A"
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
        return cateTypes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cateCell", for: indexPath)
        let row = indexPath.row
        var content = cell.defaultContentConfiguration()
        content.text = cateTypes[row].name
        content.textProperties.color = UIColor.black
        cell.contentConfiguration = content
        return cell
    }
    
    // function that determines what to do depending on which cell was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        performSegue(withIdentifier: "cateToPsuedo", sender: cateTypes[row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cateToPsuedo", let nextVC = segue.destination as? PsuedoHomeViewController, let gameInfo = sender as? CateClass {
            nextVC.comingFrom = "Category"
            nextVC.cateName = gameInfo.name
            nextVC.cateID = gameInfo.id
            nextVC.delegate = self
        }
    }
}
