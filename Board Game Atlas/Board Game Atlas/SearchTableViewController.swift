//
//  SearchTableViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 3/20/23.
//

import UIKit

// class with table view storyboard references
class SearchBoardGameCell: UITableViewCell {
    
    override func layoutSubviews() {
        // cell rounded section
        self.layer.cornerRadius = 22.0
        self.layer.borderWidth = 8.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
        
//        cell shadow section
        self.contentView.layer.cornerRadius = 22.0
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.6
        self.layer.cornerRadius = 22.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    @IBOutlet weak var searchImageView: UIImageView!
    
    @IBOutlet weak var searchGameTitleLabel: UILabel!
    
    
}
class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    var gameObjectList : Array<BoardGameItems> = []

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var searchTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchTable.delegate = self
        searchTable.dataSource = self
        
        // move search bar to the navigation bar and have it be the first thing pressed when we go to the screen
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let verticalPadding: CGFloat = 6
        let HorizontalPadding: CGFloat = 8
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 10    //if you want round edges
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: HorizontalPadding/2, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gameObjectList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchBoardGameCell
        let row = indexPath.row
        if gameObjectList[row].name == "N/A"{
            cell.searchGameTitleLabel.text = "N/A"
        }
        else{
            cell.searchGameTitleLabel.text = gameObjectList[row].name
        }
        // Change discount game image; check to see if name is N/A first
        if gameObjectList[row].image_url == "N/A"{
            cell.searchImageView.image = UIImage(named: "NA")
        }
        else{
            let url = URL(string: gameObjectList[row].image_url)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    cell.searchImageView.image = UIImage(data: imageData)
                    if cell.searchImageView.image == nil{
                        cell.searchImageView.image = UIImage(named: "NA")
                    }
                }
            }.resume()
        }
        return cell
    }
    
    
    //search bar code
    
    // if search bar is pressed we search for website link based on what is typed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchText = searchBar.text
        if searchText == ""{
            gameObjectList = []
            self.searchTable.reloadData()
        }
        else{
            gameObjectList = []
            self.searchTable.reloadData()
            let searchText = searchBar.text
            Task {
                self.showSpinnerHome(onView: self.view)
                let urlString = ("https://api.boardgameatlas.com/api/search?name=" + searchText! + "&exact=true&limit=100&client_id=PTMfSPtwDh").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                let result = try await HomeJson.getHomeDataAsync(urlString: urlString!)
                getSearchList(json: result)
                self.searchTable.reloadData()
                self.removeSpinnerHome()
                 
            }
        }
        self.searchTable.reloadData()
        // make keyboard go away
        self.searchBar.endEditing(true)
    }
   
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    // API Code
    
    func getSearchList(json:GamePageStruct) {
        // variable for the number of titles that I have called for the url request
        let titleNum = json.count
        
        // this shouldnt happend but if for some reaosn the homelimit (being the number of request I asked for)
        // is more than the url request; than i should make sure they are equal numbers so i dont break my for loop
        var homeLimit = json.games.count
        if homeLimit > titleNum{
            homeLimit = titleNum
        }
        if homeLimit == 0{
            return
        }
        // for loop going through every game object that was brought by the url request
        for title in 0...homeLimit-1{
            // a bunch of variables of list that will be put into my gameObject class
            var mechanicsArray : [String] = []
            var catgegoriesArray : [String] = []
            var primaryPublisherList : [String] = []
            var primaryDesignerList : [String] = []

            // appending each item in certain structs that have an unknown amount in them
            for mech in json.games[title].mechanics{
                mechanicsArray.append(mech.id ?? "N/A")
            }
            for cate in json.games[title].categories{
                catgegoriesArray.append(cate.id ?? "N/A")
            }
            
            // these check for nil and if not nil then we append primary publisher
            if json.games[title].primary_publisher == nil{
                primaryPublisherList.append("N/A")
                primaryPublisherList.append("N/A")
                
            }
            else{
                primaryPublisherList.append(json.games[title].primary_publisher.id ?? "N/A")
                primaryPublisherList.append(json.games[title].primary_publisher.name ?? "N/A")
            }
            
            // these check for nil and if not nil then we append primary designer
            if json.games[title].primary_designer == nil{
                primaryDesignerList.append("N/A")
                primaryDesignerList.append("N/A")
                
            }
            else{
                primaryDesignerList.append(json.games[title].primary_designer.id ?? "N/A")
                primaryDesignerList.append(json.games[title].primary_designer.name ?? "N/A")
            }
            // artist list
            let artistList : [String] = json.games[title].artists ?? ["N/A"]
            
            // we create a class using the information and append that class object into a list that will then be populating out collection view table
            gameObjectList.append(BoardGameItems(
                id: json.games[title].id ?? "N/A",
                name: json.games[title].name ?? "N/A",
                price: json.games[title].price ?? "N/A",
                msrp: json.games[title].msrp ?? 0.0,
                discount: json.games[title].discount ?? "N/A",
                year_published: json.games[title].year_published ?? 0,
                min_players: json.games[title].min_players ?? 0,
                max_players: json.games[title].max_players ?? 0,
                min_playtime: json.games[title].min_playtime ?? 0,
                max_playtime: json.games[title].max_playtime ?? 0,
                min_age:  json.games[title].min_age ?? 0,
                image_url: json.games[title].image_url ?? "N/A",
                mechanics: mechanicsArray,
                categories: catgegoriesArray,
                primary_publisher: primaryPublisherList,
                primary_designer: primaryDesignerList,
                artists: artistList,
                rules_url: json.games[title].rules_url ?? "N/A",
                official_url: json.games[title].official_url ?? "N/A",
                weight_amount: json.games[title].weight_amount ?? 0.0,
                weight_units: json.games[title].weight_units ?? "N/A",
                size_height: json.games[title].size_height ?? 0.0,
                size_depth: json.games[title].size_depth ?? 0.0,
                size_units: json.games[title].size_units ?? "N/A",
                num_distributors: json.games[title].num_distributors ?? 0,
                players: json.games[title].players ?? "N/A",
                playtime: json.games[title].playtime ?? "N/A",
                msrp_text: json.games[title].msrp_text ?? "N/A",
                price_text: json.games[title].price_text ?? "N/A",
                description_preview: json.games[title].description_preview ?? "N/A"
            ))
        }
    }
    
    // sends information to other vc
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToGamepage", let nextVC = segue.destination as? BoardGamePageViewController {
            
            let selectedRow = searchTable.indexPathForSelectedRow!.row
            nextVC.gameObject = [gameObjectList[selectedRow]]
            nextVC.delegate = self
            
        }

    }

}


