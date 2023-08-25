//
//  HomePageViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 2/27/23.
//

import UIKit
import Firebase
import FirebaseAuth

class BoardGameViewCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        // cell rounded section
        self.layer.cornerRadius = 22.0
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
        // cell shadow section
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
    
    //MARK:- Home Board game reference
    
    @IBOutlet weak var boardGameImage: UIImageView!
    
    @IBOutlet weak var timeImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var groupImage: UIImageView!
    
    @IBOutlet weak var playerLabel: UILabel!
    
    @IBOutlet weak var gameNameLabel: UILabel!
    
    @IBOutlet weak var basePriceLabel: UILabel!
    
    @IBOutlet weak var discountPriceLabel: UILabel!
    
    @IBOutlet weak var discountPercentLabel: UILabel!
    
}


class HomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {

    
    var delegate: UIViewController!
    
    //MARK:- STORYBOARD REFERENCE
    
    @IBOutlet weak var boardGameCollection: UICollectionView!
    
    @IBOutlet weak var opaqueView: UIView!
    
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var topPopupView: UIView!
    
    @IBOutlet weak var filterTable: UITableView!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    // sort by buttons storyboard reference
    @IBOutlet weak var discountButton: UIButton!
    
    @IBOutlet weak var low2HighButton: UIButton!
    
    @IBOutlet weak var high2LowButton: UIButton!
    
    @IBOutlet weak var AZButton: UIButton!
    
    @IBOutlet weak var ZAButton: UIButton!
    
    @IBOutlet weak var newButton: UIButton!
    
    @IBOutlet weak var oldButton: UIButton!
    
    @IBOutlet weak var onePlayerButton: UIButton!
    
    @IBOutlet weak var twoPlayerButton: UIButton!
    
    @IBOutlet weak var threePlayerButton: UIButton!
    
    @IBOutlet weak var fourPlayerButton: UIButton!
    
    @IBOutlet weak var fivePlayerButton: UIButton!
    
    @IBOutlet weak var sixPlayerButton: UIButton!
    
    @IBOutlet weak var sevenPlayerButton: UIButton!
    
    @IBOutlet weak var eightPlayerButton: UIButton!
    
    @IBOutlet weak var nineUpPlayerButton: UIButton!
    
    
    
    
    var menuActive = false
    
    // used for table creation
    let identifier = "filterCell"
    
    // list of what will be on side menu table
    let filterTypes = ["Most Popular", "Trending Now", "New Low Prices", "Under $20", "Clearance", "Over 50% Off", "Best Sellers", "Mechanics", "Categories"]
    
    
    // object list that will be used to populate collection view
    var gameObjectList : Array<BoardGameItems> = []
    
    
    var normalGameObjectList : Array<BoardGameItems> = []
    var discountGameObjectList : Array<BoardGameItems> = []
    var lowHighGameObjectList : Array<BoardGameItems> = []
    var highLowGameObjectList : Array<BoardGameItems> = []
    var AZGameObjectList : Array<BoardGameItems> = []
    var ZAGameObjectList : Array<BoardGameItems> = []
    var newGameObjectList : Array<BoardGameItems> = []
    var oldGameObjectList : Array<BoardGameItems> = []
    var oneGameObjectList : Array<BoardGameItems> = []
    var twoGameObjectList : Array<BoardGameItems> = []
    var threeGameObjectList : Array<BoardGameItems> = []
    var fourGameObjectList : Array<BoardGameItems> = []
    var fiveGameObjectList : Array<BoardGameItems> = []
    var sixGameObjectList : Array<BoardGameItems> = []
    var sevenGameObjectList : Array<BoardGameItems> = []
    var eightGameObjectList : Array<BoardGameItems> = []
    var ninePlusGameObjectList : Array<BoardGameItems> = []
    
    // detect what button from scroll view of sort buttons is currently pressed
    var sortStatus = "Normal"
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets delegates and clears variables
        boardGameCollection.delegate = self
        boardGameCollection.dataSource = self
        filterTable.delegate = self
        filterTable.dataSource = self
        
        //hide side menu components and set it to false
        popupView.isHidden = true
        opaqueView.isHidden = true
        topPopupView.isHidden = true
        filterTable.isHidden = true
        menuActive = false
        // change all buttons to normal unpressed state
        changeSortButtonsNormal()
        
        // call home load function in line 179
        homeLoad()

        
    }
    

    // async function that will call most popular as the default and loads collection view
    // a loading spinner bar also shows while it's happening
    func homeLoad(){
        Task {
            
            self.showSpinnerHome(onView: self.view)
            
            let result = try await HomeJson.getHomeDataAsync(urlString: "https://api.boardgameatlas.com/api/search?limit=100&client_id=PTMfSPtwDh")
            
            getHomeList(json: result)
            
            self.boardGameCollection.reloadData()
            self.removeSpinnerHome()
        }
    }
    
    // change all buttons to normal unpressed state
    func changeSortButtonsNormal(){
        discountButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        discountButton.backgroundColor = UIColor.clear
        
        low2HighButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        low2HighButton.backgroundColor = UIColor.clear
        
        high2LowButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        high2LowButton.backgroundColor = UIColor.clear
        
        AZButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        AZButton.backgroundColor = UIColor.clear
        
        ZAButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        ZAButton.backgroundColor = UIColor.clear
        
        newButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        newButton.backgroundColor = UIColor.clear
        
        oldButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        oldButton.backgroundColor = UIColor.clear
        
        onePlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        onePlayerButton.backgroundColor = UIColor.clear
        
        twoPlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        twoPlayerButton.backgroundColor = UIColor.clear
        
        threePlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        threePlayerButton.backgroundColor = UIColor.clear
        
        fourPlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        fourPlayerButton.backgroundColor = UIColor.clear
        
        fivePlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        fivePlayerButton.backgroundColor = UIColor.clear
        
        sixPlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        sixPlayerButton.backgroundColor = UIColor.clear
        
        sevenPlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        sevenPlayerButton.backgroundColor = UIColor.clear
        
        eightPlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        eightPlayerButton.backgroundColor = UIColor.clear
        
        nineUpPlayerButton.configuration?.baseForegroundColor = hexStringToUIColor(hex: "#0075E3")
        nineUpPlayerButton.backgroundColor = UIColor.clear
    }
    
    // These buttons fucntions if pressed will put change object list to the sorted type pressed
    // collection view will be reloaded to associated button pressed
    
    // if button is currently the same state as pressed;
    // we go back to original unfiltered colleciton view
    @IBAction func discountButtonPressed(_ sender: Any) {

        if sortStatus == "Discount"{
            // change all buttons to normal; since original unfiltered list will be shown
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            // change color to show it's pressed
            discountButton.configuration?.baseForegroundColor = UIColor.orange
            discountButton.backgroundColor = UIColor.orange
            sortStatus = "Discount"
            gameObjectList = discountGameObjectList
            self.boardGameCollection.reloadData()
            
        }
        
    }
    
    @IBAction func low2HighPressed(_ sender: Any) {
        if sortStatus == "Low To High"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            low2HighButton.configuration?.baseForegroundColor = UIColor.orange
            low2HighButton.backgroundColor = UIColor.orange
            sortStatus = "Low To High"
            gameObjectList = lowHighGameObjectList
            self.boardGameCollection.reloadData()
            
        }
    }
    
    @IBAction func high2LowPressed(_ sender: Any) {
        if sortStatus == "High To Low"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
            
        }
        else{
            changeSortButtonsNormal()
            high2LowButton.configuration?.baseForegroundColor = UIColor.orange
            high2LowButton.backgroundColor = UIColor.orange
            sortStatus = "High To Low"
            gameObjectList = highLowGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func AZPressed(_ sender: Any) {
        if sortStatus == "A To Z"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
            
        }
        else{
            changeSortButtonsNormal()
            AZButton.configuration?.baseForegroundColor = UIColor.orange
            AZButton.backgroundColor = UIColor.orange
            sortStatus = "A To Z"
            gameObjectList = AZGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func ZAPressed(_ sender: Any) {
        if sortStatus == "Z To A"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            ZAButton.configuration?.baseForegroundColor = UIColor.orange
            ZAButton.backgroundColor = UIColor.orange
            sortStatus = "Z To A"
            gameObjectList = ZAGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func newButtonPressed(_ sender: Any) {
        if sortStatus == "New"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
            
        }
        else{
            changeSortButtonsNormal()
            newButton.configuration?.baseForegroundColor = UIColor.orange
            newButton.backgroundColor = UIColor.orange
            sortStatus = "New"
            gameObjectList = newGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func oldButtonPressed(_ sender: Any) {
        if sortStatus == "Old"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
            
        }
        else{
            changeSortButtonsNormal()
            oldButton.configuration?.baseForegroundColor = UIColor.orange
            oldButton.backgroundColor = UIColor.orange
            sortStatus = "Old"
            gameObjectList = oldGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func onePlayerPressed(_ sender: Any) {
        if sortStatus == "One Player"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            onePlayerButton.configuration?.baseForegroundColor = UIColor.orange
            onePlayerButton.backgroundColor = UIColor.orange
            sortStatus = "One Player"
            gameObjectList = oneGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func twoPlayerPressed(_ sender: Any) {
        if sortStatus == "Two Players"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            twoPlayerButton.configuration?.baseForegroundColor = UIColor.orange
            twoPlayerButton.backgroundColor = UIColor.orange
            sortStatus = "Two Players"
            gameObjectList = twoGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func threePlayerPressed(_ sender: Any) {
        if sortStatus == "Three Players"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            threePlayerButton.configuration?.baseForegroundColor = UIColor.orange
            threePlayerButton.backgroundColor = UIColor.orange
            sortStatus = "Three Players"
            gameObjectList = threeGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func fourPlayerPressed(_ sender: Any) {
        if sortStatus == "Four Players"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            fourPlayerButton.configuration?.baseForegroundColor = UIColor.orange
            fourPlayerButton.backgroundColor = UIColor.orange
            sortStatus = "Four Players"
            gameObjectList = fourGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func fivePlayerPressed(_ sender: Any) {
        if sortStatus == "Five Players"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            fivePlayerButton.configuration?.baseForegroundColor = UIColor.orange
            fivePlayerButton.backgroundColor = UIColor.orange
            sortStatus = "Five Players"
            gameObjectList = fiveGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func sixPlayerPressed(_ sender: Any) {
        if sortStatus == "Six Players"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            sixPlayerButton.configuration?.baseForegroundColor = UIColor.orange
            sixPlayerButton.backgroundColor = UIColor.orange
            sortStatus = "Six Players"
            gameObjectList = sixGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func sevenPlayerPressed(_ sender: Any) {
        if sortStatus == "Seven Players"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            sevenPlayerButton.configuration?.baseForegroundColor = UIColor.orange
            sevenPlayerButton.backgroundColor = UIColor.orange
            sortStatus = "Seven Players"
            gameObjectList = sevenGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func eightPlayerPressed(_ sender: Any) {
        if sortStatus == "Eight Players"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            eightPlayerButton.configuration?.baseForegroundColor = UIColor.orange
            eightPlayerButton.backgroundColor = UIColor.orange
            sortStatus = "Eight Players"
            gameObjectList = eightGameObjectList
            self.boardGameCollection.reloadData()
        }
    }
    
    @IBAction func nineUpPressed(_ sender: Any) {
        if sortStatus == "Nine & Up Players"{
            changeSortButtonsNormal()
            gameObjectList = normalGameObjectList
            self.boardGameCollection.reloadData()
            sortStatus = "Normal"
        }
        else{
            changeSortButtonsNormal()
            nineUpPlayerButton.configuration?.baseForegroundColor = UIColor.orange
            nineUpPlayerButton.backgroundColor = UIColor.orange
            sortStatus = "Nine & Up Players"
            gameObjectList = ninePlusGameObjectList
            self.boardGameCollection.reloadData()
        }
    }

    // Board Game Atlas API related Code
    
    
    func getHomeList(json:GamePageStruct) {
        
        
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
            
            // we create a class using the information and
            // append that class object into a list that will then be populating out collection view table
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
        
        // create list of every sort filter for the sort by scroll view
        normalGameObjectList = gameObjectList
        discountGameObjectList = gameObjectList
        lowHighGameObjectList = gameObjectList
        highLowGameObjectList = gameObjectList
        AZGameObjectList = gameObjectList
        ZAGameObjectList = gameObjectList
        newGameObjectList = gameObjectList
        oldGameObjectList = gameObjectList
        oneGameObjectList = gameObjectList
        twoGameObjectList = gameObjectList
        threeGameObjectList = gameObjectList
        fourGameObjectList = gameObjectList
        fiveGameObjectList = gameObjectList
        sixGameObjectList = gameObjectList
        sevenGameObjectList = gameObjectList
        eightGameObjectList = gameObjectList
        ninePlusGameObjectList = gameObjectList
        
        
        discountGameObjectList = discountGameObjectList.filter { Float($0.discount)! >= 0 }
        discountGameObjectList.sort { Float($0.discount)! > Float($1.discount)! }
        
        
        lowHighGameObjectList = lowHighGameObjectList.filter { Float($0.price)! >= 0 }
        lowHighGameObjectList.sort { Float($0.price)! < Float($1.price)! }
        
        highLowGameObjectList = highLowGameObjectList.filter { Float($0.price)! >= 0 }
        highLowGameObjectList.sort { Float($0.price)! > Float($1.price)! }
        
        AZGameObjectList = AZGameObjectList.filter { $0.price != "N/A" }
        AZGameObjectList.sort { $0.name < $1.name }
        
        ZAGameObjectList = ZAGameObjectList.filter { $0.price != "N/A" }
        ZAGameObjectList.sort { $0.name > $1.name }
        
        newGameObjectList = newGameObjectList.filter { Int($0.year_published) != 0 }
        newGameObjectList.sort { Int($0.year_published) > Int($1.year_published) }
        
        oldGameObjectList = oldGameObjectList.filter { Int($0.year_published) != 0 }
        oldGameObjectList.sort { Int($0.year_published) < Int($1.year_published) }
        
        
        oneGameObjectList = oneGameObjectList.filter { Int($0.min_players) != 0}
        oneGameObjectList = oneGameObjectList.filter { Int($0.max_players) != 0}
        oneGameObjectList = oneGameObjectList.filter { Int($0.min_players) <= 1 && Int($0.max_players) >= 1}
        oneGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
        
        twoGameObjectList = twoGameObjectList.filter { Int($0.min_players) != 0}
        twoGameObjectList = twoGameObjectList.filter { Int($0.max_players) != 0}
        twoGameObjectList = twoGameObjectList.filter { Int($0.min_players) <= 2 && Int($0.max_players) >= 2}
        twoGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
        
        
        threeGameObjectList = threeGameObjectList.filter { Int($0.min_players) != 0}
        threeGameObjectList = threeGameObjectList.filter { Int($0.max_players) != 0}
        threeGameObjectList = threeGameObjectList.filter { Int($0.min_players) <= 3 && Int($0.max_players) >= 3}
        threeGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
        
        
        fourGameObjectList = fourGameObjectList.filter { Int($0.min_players) != 0}
        fourGameObjectList = fourGameObjectList.filter { Int($0.max_players) != 0}
        fourGameObjectList = fourGameObjectList.filter { Int($0.min_players) <= 4 && Int($0.max_players) >= 4}
        fourGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
        
        
        fiveGameObjectList = fiveGameObjectList.filter { Int($0.min_players) != 0}
        fiveGameObjectList = fiveGameObjectList.filter { Int($0.max_players) != 0}
        fiveGameObjectList = fiveGameObjectList.filter { Int($0.min_players) <= 5 && Int($0.max_players) >= 5}
        fiveGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
        
        
        sixGameObjectList = sixGameObjectList.filter { Int($0.min_players) != 0}
        sixGameObjectList = sixGameObjectList.filter { Int($0.max_players) != 0}
        sixGameObjectList = sixGameObjectList.filter { Int($0.min_players) <= 6 && Int($0.max_players) >= 6}
        sixGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
        
        
        sevenGameObjectList = sevenGameObjectList.filter { Int($0.min_players) != 0}
        sevenGameObjectList = sevenGameObjectList.filter { Int($0.max_players) != 0}
        sevenGameObjectList = sevenGameObjectList.filter { Int($0.min_players) <= 7 && Int($0.max_players) >= 7}
        sevenGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
        

        eightGameObjectList = eightGameObjectList.filter { Int($0.min_players) != 0}
        eightGameObjectList = eightGameObjectList.filter { Int($0.max_players) != 0}
        eightGameObjectList = eightGameObjectList.filter { Int($0.min_players) <= 8 && Int($0.max_players) >= 8}
        eightGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
        
        
        ninePlusGameObjectList = ninePlusGameObjectList.filter { Int($0.min_players) != 0}
        ninePlusGameObjectList = ninePlusGameObjectList.filter { Int($0.max_players) != 0}
        ninePlusGameObjectList = ninePlusGameObjectList.filter { Int($0.max_players) >= 9}
        ninePlusGameObjectList.sort { Int($0.min_players) > Int($1.min_players) }
    }
    
    //collectionview stuff code
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameObjectList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardGameCell", for: indexPath) as! BoardGameViewCell
        
        // Change Game Label text; check to see if name is N/A first
        if gameObjectList[row].name == "N/A"{
            cell.gameNameLabel.text = "N/A"
        }
        else{
            cell.gameNameLabel.text = gameObjectList[row].name
        }
        
        // Change player number Label text; check to see if name is N/A first
        if gameObjectList[row].players == "N/A"{
            cell.playerLabel.text = "N/A"
        }
        else{
            cell.playerLabel.text = gameObjectList[row].players
        }
        
        // Change gameplay time Label text; check to see if name is N/A first
        if gameObjectList[row].playtime == "N/A"{
            cell.timeLabel.text = "N/A"
        }
        else{
            cell.timeLabel.text = gameObjectList[row].playtime
        }
        
        // Change base price Label text; check to see if name is N/A first
        if gameObjectList[row].msrp_text == "N/A"{
            cell.basePriceLabel.text = "N/A"
        }
        else{
            cell.basePriceLabel.text = gameObjectList[row].msrp_text
            
        }
        
        

        // Change discount price Label text; check to see if name is N/A first
        if gameObjectList[row].price_text == "N/A" || gameObjectList[row].price_text == "Price: N/A" {
            cell.basePriceLabel.textColor = UIColor.black
            let attributedText = NSAttributedString(
                string: gameObjectList[row].price_text,
                attributes: [.strikethroughStyle: []]
            )
            cell.basePriceLabel.attributedText = attributedText
            cell.discountPriceLabel.text = ""
        }
        else{
            cell.basePriceLabel.textColor = UIColor.red
            let attributedText = NSAttributedString(
                string: gameObjectList[row].msrp_text,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            cell.basePriceLabel.attributedText = attributedText
            cell.discountPriceLabel.text = gameObjectList[row].price_text
        }

        // Change discount percent Label text; check to see if name is N/A first
        if gameObjectList[row].discount == "N/A" || Float(gameObjectList[row].discount)! <= 0.00{
            cell.discountPercentLabel.text = ""
        }
        else{
            let discountFloat = Float(gameObjectList[row].discount)!*100
            let discountInt = Int(discountFloat)
            
            cell.discountPercentLabel.text = String(discountInt) + "% off"
        }
        
        // Change discount game image; check to see if name is N/A first
        if gameObjectList[row].image_url == "N/A"{
            cell.boardGameImage.image = UIImage(named: "NA")
        }
        else{
            let url = URL(string: gameObjectList[row].image_url)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    cell.boardGameImage.image = UIImage(data: imageData)
                    if cell.boardGameImage.image == nil{
                        cell.boardGameImage.image = UIImage(named: "NA")
                    }
                }
            }.resume()
        }
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: view.frame.size.width/12, bottom: 1, right: view.frame.size.width/12)
    }
    
    // if board game cell is selected we segue to board game page and change highlighted color back to original color
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BoardGameViewCell {
            cell.backgroundColor = UIColor(red: (220/255.0), green: (180/255.0), blue: (131/255.0), alpha: 1.0)
            performSegue(withIdentifier: "gamePageSegue", sender: indexPath[1])
            
            
        }

    }
    
    // if board game cell is highlighted but it will change into a darker color so it can show to the user that its currently being selected
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BoardGameViewCell {
            cell.backgroundColor = hexStringToUIColor(hex: "AA8C67")
        }
    }
    
    
    // if highlighted but not selected then we change the color back to the original color
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BoardGameViewCell {
            cell.backgroundColor = UIColor(red: (220/255.0), green: (180/255.0), blue: (131/255.0), alpha: 1.0)
        }
    }
    
    // get rgb colors from hex code function
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Table code here
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath)
        let row = indexPath.row
        
        var content = cell.defaultContentConfiguration()
        content.text = filterTypes[row]
        content.textProperties.color = UIColor.black
        cell.contentConfiguration = content
        
        return cell
    }
    
    // function that determines what to do depending on which cell was selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        // Most popular selected in the table side menu
        if filterTypes[row] == "Most Popular"{
            
            gameObjectList.removeAll()
            self.boardGameCollection.reloadData()
            self.navigationItem.title = "Most Popular"
            if menuActive{
                closeMenuBar()
            }
            changeSortButtonsNormal()
            Task {
                
                self.showSpinnerHome(onView: self.view)
                
                let result = try await HomeJson.getHomeDataAsync(urlString: "https://api.boardgameatlas.com/api/search?limit=100&client_id=PTMfSPtwDh")
                
                getHomeList(json: result)
                
                self.boardGameCollection.reloadData()
                self.removeSpinnerHome()
            }
            
        }
        // Trending Now selected in the table side menu
        else if filterTypes[row] == "Trending Now"{
            
            gameObjectList.removeAll()
            self.boardGameCollection.reloadData()
            self.navigationItem.title = "Trending Now"
            if menuActive{
                closeMenuBar()
            }
            changeSortButtonsNormal()
            Task {
                
                self.showSpinnerHome(onView: self.view)
                
                let result = try await HomeJson.getHomeDataAsync(urlString: "https://api.boardgameatlas.com/api/search?order_by=trending&limit=100&client_id=PTMfSPtwDh")
                getHomeList(json: result)
                self.boardGameCollection.reloadData()
                self.removeSpinnerHome()
            }
        }
        // New Low Prices selected in the table side menu
        else if filterTypes[row] == "New Low Prices"{
            
            gameObjectList.removeAll()
            self.boardGameCollection.reloadData()
            self.navigationItem.title = "New Low Prices"
            
            if menuActive{
                closeMenuBar()
            }
            changeSortButtonsNormal()
            Task {
                self.showSpinnerHome(onView: self.view)
                
                let result = try await HomeJson.getHomeDataAsync(urlString: "https://api.boardgameatlas.com/api/search?recent_low=true&limit=100&client_id=PTMfSPtwDh")
                
                getHomeList(json: result)
                self.boardGameCollection.reloadData()
                self.removeSpinnerHome()
            }
            
        }
        // Under $20 selected in the table side menu
        else if filterTypes[row] == "Under $20"{
            
            gameObjectList.removeAll()
            self.boardGameCollection.reloadData()
            self.navigationItem.title = "Under $20"
            if menuActive{
                closeMenuBar()
            }
            changeSortButtonsNormal()
            Task {
                self.showSpinnerHome(onView: self.view)
                
                let result = try await HomeJson.getHomeDataAsync(urlString: "https://api.boardgameatlas.com/api/search?lt_price=20.01&limit=100&client_id=PTMfSPtwDh")
                
                getHomeList(json: result)
                self.boardGameCollection.reloadData()
                self.removeSpinnerHome()
            }
        }
        // Clearance selected in the table side menu
        else if filterTypes[row] == "Clearance"{
            
            gameObjectList.removeAll()
            self.boardGameCollection.reloadData()
            self.navigationItem.title = "Clearance"
            if menuActive{
                closeMenuBar()
            }
            changeSortButtonsNormal()
            Task {
                self.showSpinnerHome(onView: self.view)
                
                let result = try await HomeJson.getHomeDataAsync(urlString: "https://api.boardgameatlas.com/api/search?gt_discount=0.39&limit=100&client_id=PTMfSPtwDh")
                
                getHomeList(json: result)
                self.boardGameCollection.reloadData()
                self.removeSpinnerHome()
            }
        }
        // Over 50% Off selected in the table side menu
        else if filterTypes[row] == "Over 50% Off"{
            
            gameObjectList.removeAll()
            self.boardGameCollection.reloadData()
            self.navigationItem.title = "Over 50% Off"
            if menuActive{
                closeMenuBar()
            }
            changeSortButtonsNormal()
            Task {
                self.showSpinnerHome(onView: self.view)
                
                let result = try await HomeJson.getHomeDataAsync(urlString: "https://api.boardgameatlas.com/api/search?gt_discount=0.5&limit=100&client_id=PTMfSPtwDh")
                getHomeList(json: result)
                self.boardGameCollection.reloadData()
                self.removeSpinnerHome()
            }
        }
        // Best Sellers selected in the table side menu
        else if filterTypes[row] == "Best Sellers"{
            
            gameObjectList.removeAll()
            self.boardGameCollection.reloadData()
            self.navigationItem.title = "Best Sellers"
            
            if menuActive{
                closeMenuBar()
            }
            changeSortButtonsNormal()
            Task {
                
                self.showSpinnerHome(onView: self.view)
                
                let result = try await HomeJson.getHomeDataAsync(urlString: "https://api.boardgameatlas.com/api/search?order_by=listing_clicks&limit=100&client_id=PTMfSPtwDh")
                
                getHomeList(json: result)
                self.boardGameCollection.reloadData()
                self.removeSpinnerHome()
            }
            
        }
        //same thing - these two share the same layout so they are sent to the same screen with minor label changes
        else if filterTypes[row] == "Mechanics" {
            performSegue(withIdentifier: "popupToMechanic", sender: filterTypes[row])
        }
        else if filterTypes[row] == "Categories" {
            performSegue(withIdentifier: "popupToCategory", sender: filterTypes[row])
        }
    }
    
    
    // sends information to other vc using segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gamePageSegue", let nextVC = segue.destination as? BoardGamePageViewController, let indexNum = sender as? Int {
            nextVC.gameObject = [gameObjectList[indexNum]]
            nextVC.delegate = self

            
        }

        if segue.identifier == "homeToSearch", let nextVC = segue.destination as? SearchTableViewController {
            // make back button not show words
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    // code for if menu is pressed we make the side menu appear or not
    @IBAction func menuButtonPressed(_ sender: Any) {
        if menuActive{
            closeMenuBar()
        }
        else if !menuActive{
            openMenuBar()
        }
    }
    
    @IBAction func opaquePressed(_ sender: Any) {
        if menuActive{
            closeMenuBar()
        }
    }
    
    // functions to close and open menu bar
    
    func openMenuBar(){
        let safeFrame = self.view.safeAreaLayoutGuide.layoutFrame
        opaqueView.isHidden = true
        popupView.isHidden = true
        topPopupView.isHidden = true
        filterTable.isHidden = true
        opaqueView.frame = CGRect(x: 0, y: 0, width: 0, height: safeFrame.height)
        popupView.frame = CGRect(x: 0, y: 0, width: 0, height: safeFrame.height)
        topPopupView.frame = CGRect(x: 0, y: 0, width: 0, height: 200)
        filterTable.frame = CGRect(x: 0, y: 0, width: 0, height: 470)
        
        opaqueView.frame = CGRect(x: 0, y: 0, width: safeFrame.width, height: safeFrame.height)
        UIView.animate(withDuration: 0.5, animations: {
            self.opaqueView.isHidden = false
            self.popupView.isHidden = false
            self.topPopupView.isHidden = false
            self.filterTable.isHidden = false
            
            self.popupView.frame = CGRect(x: 0, y: 0, width: 220, height: safeFrame.height)
            self.topPopupView.frame = CGRect(x: 0, y: 0, width: 220, height: 200)
            self.filterTable.frame = CGRect(x: 0, y: 0, width: 220, height: 470)
            self.searchButton.isEnabled  = false
            self.menuActive = true
            
            }, completion: { finished in
                
                
        })
        
    }
    
    
    func closeMenuBar() {
        let safeFrame = self.view.safeAreaLayoutGuide.layoutFrame
        opaqueView.isHidden = false
        popupView.isHidden = false
        topPopupView.isHidden = false
        filterTable.isHidden = false
        
        opaqueView.frame = CGRect(x: 0, y: 0, width: safeFrame.width, height: safeFrame.height)
        popupView.frame = CGRect(x: 0, y: 0, width: 220, height: safeFrame.height)
        topPopupView.frame = CGRect(x: 0, y: 0, width: 220, height: 200)
        filterTable.frame = CGRect(x: 0, y: 0, width: 220, height: 470)
        
        
        opaqueView.frame = CGRect(x: 0, y: 0, width: 0, height: safeFrame.height)
        popupView.frame = CGRect(x: 0, y: 0, width: 0, height: safeFrame.height)
        topPopupView.frame = CGRect(x: 0, y: 0, width: 0, height: 200)
        filterTable.frame = CGRect(x: 0, y: 0, width: 0, height: 470)

        opaqueView.isHidden = true
        popupView.isHidden = true
        topPopupView.isHidden = true
        filterTable.isHidden = true
        searchButton.isEnabled  = true
        menuActive = false
            
        
        
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


