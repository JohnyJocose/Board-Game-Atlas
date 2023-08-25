//
//  ProfileViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 3/20/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

// class of collection view cell with picture for game and name of game
class ProfileBoardGameViewCell: UICollectionViewCell {
    
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
    
    
    @IBOutlet weak var boardGameImageView: UIImageView!
    
    
    @IBOutlet weak var gameNameLabel: UILabel!
    
}

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: UIViewController!
    
    // storyboard references
    @IBOutlet weak var boardGameCollection: UICollectionView!
    
    @IBOutlet weak var authView: UIView!
    
    @IBOutlet weak var firebaseSegment: UISegmentedControl!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    @IBOutlet weak var settingButton: UIBarButtonItem!
    
    // arrays so we can populate the collection view;
    // with which of the segemnt controls is currently selected
    var gameObjectList : Array<BoardGameItems> = []
    
    var bookamrkGameObjectList : Array<BoardGameItems> = []
    var wishListGameObjectList : Array<BoardGameItems> = []
    var ownGameObjectList : Array<BoardGameItems> = []
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // calls a function that will put image and text in one of the spots for the segment control
        loadSegment()
        
        // if the global variable needsfirebase from FirebaseAPICode file
        // is not true we dont have to double load the page and have double cells
        // because thats what happens when you interact with viewWillAppear
        if !needsFirebaseUpdate{
            boardGameCollection.delegate = self
            boardGameCollection.dataSource = self
            gameObjectList.removeAll()
            bookamrkGameObjectList.removeAll()
            wishListGameObjectList.removeAll()
            ownGameObjectList.removeAll()
            boardGameCollection.reloadData()
            authenticateUseraAndConfigure()
        }
        // make the profile picture rounded borders
        profilePictureImageView.roundedImage()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // everytime we go to this page we want to check
        // if anything firebase related on any page was changed
        // if so then we have to update it
        // it also doesnt conflict with viewdidload because it's impossible
        // they go off at the same time
        if needsFirebaseUpdate{
            boardGameCollection.delegate = self
            boardGameCollection.dataSource = self
            gameObjectList.removeAll()
            bookamrkGameObjectList.removeAll()
            wishListGameObjectList.removeAll()
            ownGameObjectList.removeAll()
            boardGameCollection.reloadData()
            authenticateUseraAndConfigure()
        }
    }
    
    // calls textEmbededImage func from extension at bottom of page;
    // this lets us put images and text in a segment
    
    func loadSegment(){
        firebaseSegment.setImage(
            UIImage.textEmbededImage(
                image: UIImage(systemName: "bookmark.fill")!,
                string: "Bookmarks",
                color: .black
            ),
            forSegmentAt: 0
        )
        firebaseSegment.setImage(
            UIImage.textEmbededImage(
                image: UIImage(systemName: "star.fill")!,
                string: "Wishlist",
                color: .black
            ),
            forSegmentAt: 1
        )
        firebaseSegment.setImage(
            UIImage.textEmbededImage(
                image: UIImage(systemName: "case.fill")!,
                string: "Own",
                color: .black
            ),
            forSegmentAt: 2
        )
    }
    
    // loads profile picture and username by callin these functions
    func loadProfileInfo(){
        loadProfilePicture()
        loadUsername()
    }
    
    //get image url for profile from firebase func
    func loadProfilePicture(){
        self.showSpinnerProfile(onView: self.view)
        
        let userID = Auth.auth().currentUser?.uid
        let database = Database.database().reference()
        
        let databaseRef = database.child("users").child(userID!).child("profilePictureID")
        
        databaseRef.observeSingleEvent(of: .value) { (snapshot) in
            let data = snapshot.value as? String
            
            let url = URL(string: data!)
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.profilePictureImageView.image = UIImage(data: imageData)
                    self.removeSpinnerProfile()
                }
            }.resume()
        }
    }
    
    //get username for profile from firebase func
    func loadUsername(){
        
        let userID = Auth.auth().currentUser?.uid
        let database = Database.database().reference()
        
        let databaseRef = database.child("users").child(userID!).child("username")
        
        databaseRef.observeSingleEvent(of: .value) { (snapshot) in
            let data = snapshot.value as? String
            
            self.navigationItem.title = String(data!)
        }
    }
    
    // change game objectlist to match which segment is selected and reload data
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            
            gameObjectList = bookamrkGameObjectList
            boardGameCollection.reloadData()
        }
        
        else if sender.selectedSegmentIndex == 1{
            gameObjectList = wishListGameObjectList
            boardGameCollection.reloadData()
            
        }
        else if sender.selectedSegmentIndex == 2{
            gameObjectList = ownGameObjectList
            boardGameCollection.reloadData()
            
        }
    }
    
    // async task to populate colleciton view based on users firebase database
    func populateCollection(){
        
        // game object
        gameObjectList = []
        
        // bookmark task
        _Concurrency.Task {
            
            do {
                
                bookamrkGameObjectList = []
                let database = Database.database().reference()
                let userID = Auth.auth().currentUser?.uid
                
                let bookmarkDatabaseRef = database.child("users").child(userID!).child("Bookmarks")
                let bookmarkSnapshot : DataSnapshot = try await bookmarkDatabaseRef.getData()
                
                if let data = bookmarkSnapshot.value as? [String:[String:Any]]{
                    for gameID in data.keys{
                        // give a deafult value incase nothing is there that way we dont crash
                        let id = (data[gameID]!["id"]) as? String ?? "N/A"
                        let name = (data[gameID]!["name"]) as? String ?? "N/A"
                        let price = (data[gameID]!["price"]) as? String ?? "N/A"
                        let msrp = (data[gameID]!["msrp"]) as? Float ?? 0.0
                        let discount = (data[gameID]!["discount"]) as? String ?? "N/A"
                        let year_published = (data[gameID]!["year_published"]) as? Int ?? 0
                        let min_players = (data[gameID]!["min_players"]) as? Int ?? 0
                        let max_players = (data[gameID]!["max_players"]) as? Int ?? 0
                        let min_playtime = (data[gameID]!["min_playtime"]) as? Int ?? 0
                        let max_playtime = (data[gameID]!["max_playtime"]) as? Int ?? 0
                        let min_age = (data[gameID]!["min_age"]) as? Int ?? 0
                        let image_url = (data[gameID]!["image_url"]) as? String ?? "N/A"
                        let mechanics = (data[gameID]!["mechanics"]) as? [String] ?? []
                        let categories = (data[gameID]!["categories"]) as? [String] ?? []
                        let primary_publisher = (data[gameID]!["primary_publisher"]) as? [String] ?? []
                        let primary_designer = (data[gameID]!["primary_designer"]) as? [String] ?? []
                        let artists = (data[gameID]!["artists"]) as? [String] ?? []
                        let rules_url = (data[gameID]!["rules_url"]) as? String ?? "N/A"
                        let official_url = (data[gameID]!["official_url"]) as? String ?? "N/A"
                        let weight_amount = (data[gameID]!["weight_amount"]) as? Float ?? 0.0
                        let weight_units = (data[gameID]!["weight_units"]) as? String ?? "N/A"
                        let size_height = (data[gameID]!["size_height"]) as? Float ?? 0.0
                        let size_depth = (data[gameID]!["size_depth"]) as? Float ?? 0.0
                        let size_units = (data[gameID]!["size_units"]) as? String ?? "N/A"
                        let num_distributors = (data[gameID]!["num_distributors"]) as? Int ?? 0
                        let players = (data[gameID]!["players"]) as? String ?? "N/A"
                        let playtime = (data[gameID]!["playtime"]) as? String ?? "N/A"
                        let msrp_text = (data[gameID]!["msrp_text"]) as? String ?? "N/A"
                        let price_text = (data[gameID]!["price_text"]) as? String ?? "N/A"
                        let description_preview = (data[gameID]!["description_preview"]) as? String ?? "N/A"

                        bookamrkGameObjectList.append(BoardGameItems(id: id,
                                                                     name: name,
                                                                     price: price,
                                                                     msrp: msrp,
                                                                     discount: discount,
                                                                     year_published: year_published,
                                                                     min_players: min_players,
                                                                     max_players: max_players,
                                                                     min_playtime: min_playtime,
                                                                     max_playtime: max_playtime,
                                                                     min_age: min_age,
                                                                     image_url: image_url,
                                                                     mechanics: mechanics,
                                                                     categories: categories,
                                                                     primary_publisher: primary_publisher,
                                                                     primary_designer: primary_designer,
                                                                     artists: artists,
                                                                     rules_url: rules_url,
                                                                     official_url: official_url,
                                                                     weight_amount: weight_amount,
                                                                     weight_units: weight_units,
                                                                     size_height: size_height,
                                                                     size_depth: size_depth,
                                                                     size_units: size_units,
                                                                     num_distributors: num_distributors,
                                                                     players: players,
                                                                     playtime: playtime,
                                                                     msrp_text: msrp_text,
                                                                     price_text: price_text,
                                                                     description_preview: description_preview))
                        
                    }
                    bookamrkGameObjectList.sort { $0.name < $1.name }
                    if firebaseSegment.selectedSegmentIndex == 0{
                        gameObjectList = bookamrkGameObjectList
                        boardGameCollection.reloadData()
                    }
                }
                
                else{
                    // no data exist
                    if firebaseSegment.selectedSegmentIndex == 0{
                        gameObjectList = bookamrkGameObjectList
                        boardGameCollection.reloadData()
                    }
                }
                
            } catch {
                //Something went wrong with firebase data
                if firebaseSegment.selectedSegmentIndex == 0{
                    gameObjectList = bookamrkGameObjectList
                    boardGameCollection.reloadData()
                }
                
            }
            
        }
        
        //wishlist task
        // most comments are same as above
        _Concurrency.Task {
            
            do {
                
                wishListGameObjectList = []

                let database = Database.database().reference()
                let userID = Auth.auth().currentUser?.uid

                let wishListDatabaseRef = database.child("users").child(userID!).child("Wishlist")
                let wishlistSnapshot : DataSnapshot = try await wishListDatabaseRef.getData()
                
                if let data = wishlistSnapshot.value as? [String:[String:Any]]{
                    
                    for gameID in data.keys{
                        
                        let id = (data[gameID]!["id"]) as? String ?? "N/A"
                        let name = (data[gameID]!["name"]) as? String ?? "N/A"
                        let price = (data[gameID]!["price"]) as? String ?? "N/A"
                        let msrp = (data[gameID]!["msrp"]) as? Float ?? 0.0
                        let discount = (data[gameID]!["discount"]) as? String ?? "N/A"
                        let year_published = (data[gameID]!["year_published"]) as? Int ?? 0
                        let min_players = (data[gameID]!["min_players"]) as? Int ?? 0
                        let max_players = (data[gameID]!["max_players"]) as? Int ?? 0
                        let min_playtime = (data[gameID]!["min_playtime"]) as? Int ?? 0
                        let max_playtime = (data[gameID]!["max_playtime"]) as? Int ?? 0
                        let min_age = (data[gameID]!["min_age"]) as? Int ?? 0
                        let image_url = (data[gameID]!["image_url"]) as? String ?? "N/A"
                        let mechanics = (data[gameID]!["mechanics"]) as? [String] ?? []
                        let categories = (data[gameID]!["categories"]) as? [String] ?? []
                        let primary_publisher = (data[gameID]!["primary_publisher"]) as? [String] ?? []
                        let primary_designer = (data[gameID]!["primary_designer"]) as? [String] ?? []
                        let artists = (data[gameID]!["artists"]) as? [String] ?? []
                        let rules_url = (data[gameID]!["rules_url"]) as? String ?? "N/A"
                        let official_url = (data[gameID]!["official_url"]) as? String ?? "N/A"
                        let weight_amount = (data[gameID]!["weight_amount"]) as? Float ?? 0.0
                        let weight_units = (data[gameID]!["weight_units"]) as? String ?? "N/A"
                        let size_height = (data[gameID]!["size_height"]) as? Float ?? 0.0
                        let size_depth = (data[gameID]!["size_depth"]) as? Float ?? 0.0
                        let size_units = (data[gameID]!["size_units"]) as? String ?? "N/A"
                        let num_distributors = (data[gameID]!["num_distributors"]) as? Int ?? 0
                        let players = (data[gameID]!["players"]) as? String ?? "N/A"
                        let playtime = (data[gameID]!["playtime"]) as? String ?? "N/A"
                        let msrp_text = (data[gameID]!["msrp_text"]) as? String ?? "N/A"
                        let price_text = (data[gameID]!["price_text"]) as? String ?? "N/A"
                        let description_preview = (data[gameID]!["description_preview"]) as? String ?? "N/A"
                        
                        wishListGameObjectList.append(BoardGameItems(id: id,
                                                                     name: name,
                                                                     price: price,
                                                                     msrp: msrp,
                                                                     discount: discount,
                                                                     year_published: year_published,
                                                                     min_players: min_players,
                                                                     max_players: max_players,
                                                                     min_playtime: min_playtime,
                                                                     max_playtime: max_playtime,
                                                                     min_age: min_age,
                                                                     image_url: image_url,
                                                                     mechanics: mechanics,
                                                                     categories: categories,
                                                                     primary_publisher: primary_publisher,
                                                                     primary_designer: primary_designer,
                                                                     artists: artists,
                                                                     rules_url: rules_url,
                                                                     official_url: official_url,
                                                                     weight_amount: weight_amount,
                                                                     weight_units: weight_units,
                                                                     size_height: size_height,
                                                                     size_depth: size_depth,
                                                                     size_units: size_units,
                                                                     num_distributors: num_distributors,
                                                                     players: players,
                                                                     playtime: playtime,
                                                                     msrp_text: msrp_text,
                                                                     price_text: price_text,
                                                                     description_preview: description_preview))
                        
                    }
                    
                    
                    wishListGameObjectList.sort { $0.name < $1.name }
                    
                    if firebaseSegment.selectedSegmentIndex == 1{
                        gameObjectList = wishListGameObjectList
                        boardGameCollection.reloadData()
                    }
                    
                    
                }

                else{
                    //no data exist
                    if firebaseSegment.selectedSegmentIndex == 1{
                        gameObjectList = wishListGameObjectList
                        boardGameCollection.reloadData()
                    }
                }
                
            } catch {
                //Something went wrong with firebase data
                if firebaseSegment.selectedSegmentIndex == 1{
                    gameObjectList = wishListGameObjectList
                    boardGameCollection.reloadData()
                }
            }
        }
        
        //own task
        _Concurrency.Task {
            
            do {
                
                ownGameObjectList = []
                
                let database = Database.database().reference()
                let userID = Auth.auth().currentUser?.uid

                let ownDatabaseRef = database.child("users").child(userID!).child("Own")
                let ownSnapshot : DataSnapshot = try await ownDatabaseRef.getData()
                
                if let data = ownSnapshot.value as? [String:[String:Any]]{
                    
                    for gameID in data.keys{
                        
                        let id = (data[gameID]!["id"]) as? String ?? "N/A"
                        let name = (data[gameID]!["name"]) as? String ?? "N/A"
                        let price = (data[gameID]!["price"]) as? String ?? "N/A"
                        let msrp = (data[gameID]!["msrp"]) as? Float ?? 0.0
                        let discount = (data[gameID]!["discount"]) as? String ?? "N/A"
                        let year_published = (data[gameID]!["year_published"]) as? Int ?? 0
                        let min_players = (data[gameID]!["min_players"]) as? Int ?? 0
                        let max_players = (data[gameID]!["max_players"]) as? Int ?? 0
                        let min_playtime = (data[gameID]!["min_playtime"]) as? Int ?? 0
                        let max_playtime = (data[gameID]!["max_playtime"]) as? Int ?? 0
                        let min_age = (data[gameID]!["min_age"]) as? Int ?? 0
                        let image_url = (data[gameID]!["image_url"]) as? String ?? "N/A"
                        let mechanics = (data[gameID]!["mechanics"]) as? [String] ?? []
                        let categories = (data[gameID]!["categories"]) as? [String] ?? []
                        let primary_publisher = (data[gameID]!["primary_publisher"]) as? [String] ?? []
                        let primary_designer = (data[gameID]!["primary_designer"]) as? [String] ?? []
                        let artists = (data[gameID]!["artists"]) as? [String] ?? []
                        let rules_url = (data[gameID]!["rules_url"]) as? String ?? "N/A"
                        let official_url = (data[gameID]!["official_url"]) as? String ?? "N/A"
                        let weight_amount = (data[gameID]!["weight_amount"]) as? Float ?? 0.0
                        let weight_units = (data[gameID]!["weight_units"]) as? String ?? "N/A"
                        let size_height = (data[gameID]!["size_height"]) as? Float ?? 0.0
                        let size_depth = (data[gameID]!["size_depth"]) as? Float ?? 0.0
                        let size_units = (data[gameID]!["size_units"]) as? String ?? "N/A"
                        let num_distributors = (data[gameID]!["num_distributors"]) as? Int ?? 0
                        let players = (data[gameID]!["players"]) as? String ?? "N/A"
                        let playtime = (data[gameID]!["playtime"]) as? String ?? "N/A"
                        let msrp_text = (data[gameID]!["msrp_text"]) as? String ?? "N/A"
                        let price_text = (data[gameID]!["price_text"]) as? String ?? "N/A"
                        let description_preview = (data[gameID]!["description_preview"]) as? String ?? "N/A"
                        
                        ownGameObjectList.append(BoardGameItems(id: id,
                                                                     name: name,
                                                                     price: price,
                                                                     msrp: msrp,
                                                                     discount: discount,
                                                                     year_published: year_published,
                                                                     min_players: min_players,
                                                                     max_players: max_players,
                                                                     min_playtime: min_playtime,
                                                                     max_playtime: max_playtime,
                                                                     min_age: min_age,
                                                                     image_url: image_url,
                                                                     mechanics: mechanics,
                                                                     categories: categories,
                                                                     primary_publisher: primary_publisher,
                                                                     primary_designer: primary_designer,
                                                                     artists: artists,
                                                                     rules_url: rules_url,
                                                                     official_url: official_url,
                                                                     weight_amount: weight_amount,
                                                                     weight_units: weight_units,
                                                                     size_height: size_height,
                                                                     size_depth: size_depth,
                                                                     size_units: size_units,
                                                                     num_distributors: num_distributors,
                                                                     players: players,
                                                                     playtime: playtime,
                                                                     msrp_text: msrp_text,
                                                                     price_text: price_text,
                                                                     description_preview: description_preview))
                        
                    }

                    ownGameObjectList.sort { $0.name < $1.name }
                    
                    if firebaseSegment.selectedSegmentIndex == 2{
                        gameObjectList = ownGameObjectList
                        boardGameCollection.reloadData()
                    }
                    
                }
                else{
                    //no data exist
                    if firebaseSegment.selectedSegmentIndex == 2{
                        gameObjectList = ownGameObjectList
                        boardGameCollection.reloadData()
                    }
                }
                
            } catch {
                //Something went wrong with firebase data
                if firebaseSegment.selectedSegmentIndex == 2{
                    gameObjectList = ownGameObjectList
                    boardGameCollection.reloadData()
                }
                
            }
            
        }
        
    }
    
    
    // unwind segue
    // a lot of the other pages in this tab will lead to here so i want it to immediatly come here and close other contorllers
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        authView.isHidden = true
        authenticateUseraAndConfigure()
    }
    
    
    //Firebase API Code
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            navigationItem.title = "Profile"
        }
        catch _{
            print("failed to sign out")
        }
    }
    
    
    func authenticateUseraAndConfigure(){
        
        if Auth.auth().currentUser == nil {
            //user needs to log in
            navigationItem.title = "Profile"
            settingButton.isEnabled = false
            authView.isHidden = false

        }
        else{
            //user is logged in
            populateCollection()
            loadProfileInfo()
            authView.isHidden = true
            needsFirebaseUpdate = false
            settingButton.isEnabled = true
        }
        
    }
    
    //collectionview stuff
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameObjectList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardGameCell", for: indexPath) as! ProfileBoardGameViewCell
        
        // Change Game Label text; check to see if name is N/A first
        if gameObjectList[row].name == "N/A"{
            cell.gameNameLabel.text = "N/A"
        }
        else{
            cell.gameNameLabel.text = gameObjectList[row].name
        }
        
        // Change discount game image; check to see if name is N/A first
        if gameObjectList[row].image_url == "N/A"{
            cell.boardGameImageView.image = UIImage(named: "NA")
        }
        else{
            let url = URL(string: gameObjectList[row].image_url)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    cell.boardGameImageView.image = UIImage(data: imageData)
                    if cell.boardGameImageView.image == nil{
                        cell.boardGameImageView.image = UIImage(named: "NA")
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
        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileBoardGameViewCell {
            cell.backgroundColor = UIColor(red: (220/255.0), green: (180/255.0), blue: (131/255.0), alpha: 1.0)
            performSegue(withIdentifier: "profileToGamepage", sender: indexPath[1])
        }

    }
    
    // if board game cell is highlighted but it will change into a darker color so it can show to the user that its currently being selected
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileBoardGameViewCell {
            cell.backgroundColor = hexStringToUIColor(hex: "AA8C67")
        }
    }
    
    
    // if highlighted but not selected then we change the color back to the original color
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileBoardGameViewCell {
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
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        
        let senderList = [bookamrkGameObjectList, wishListGameObjectList, ownGameObjectList]
        performSegue(withIdentifier: "profileToSetting", sender: senderList)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "profileToSetting", let nextVC = segue.destination as? SettingTableViewController {
            let gameLists = sender as? Array<Array<BoardGameItems>>
            nextVC.gameObjectLists = gameLists ?? [[],[],[]]
            nextVC.delegate = self
        }
        //profileToGamepage
        if segue.identifier == "profileToGamepage", let nextVC = segue.destination as? BoardGamePageViewController {
            let indexNum = sender as? Int
            nextVC.gameObject = [gameObjectList[indexNum!]]
            nextVC.delegate = self
        }
        
    }
}

extension UIImage {
    
    class func textEmbededImage(image: UIImage, string: String, color:UIColor, imageAlignment: Int = 0, segFont: UIFont? = nil) -> UIImage {
        let font = segFont ?? UIFont.systemFont(ofSize: 16.0)
        let expectedTextSize: CGSize = (string as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
        let width: CGFloat = expectedTextSize.width + image.size.width + 5.0
        let height: CGFloat = max(expectedTextSize.height, image.size.width)
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        let fontTopPosition: CGFloat = (height - expectedTextSize.height) / 2.0
        let textOrigin: CGFloat = (imageAlignment == 0) ? image.size.width + 5 : 0
        let textPoint: CGPoint = CGPoint.init(x: textOrigin, y: fontTopPosition)
        string.draw(at: textPoint, withAttributes: [NSAttributedString.Key.font: font])
        let flipVertical: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        context.concatenate(flipVertical)
        let alignment: CGFloat =  (imageAlignment == 0) ? 0.0 : expectedTextSize.width + 5.0
        context.draw(image.cgImage!, in: CGRect.init(x: alignment, y: ((height - image.size.height) / 2.0), width: image.size.width, height: image.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
