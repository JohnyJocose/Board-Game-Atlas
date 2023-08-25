//
//  BoardGamePageViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 3/19/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class websitePricingInfoCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        // cell rounded section
        self.layer.cornerRadius = 15.0
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true

        // cell shadow section
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.6
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var storePricingLabel: UILabel!
    
    @IBOutlet weak var storeShippingLabel: UILabel!
    
}
class BoardGamePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate: UIViewController!
    
    
    @IBOutlet weak var boardGameImage: UIImageView!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    @IBOutlet weak var wishlistButton: UIButton!
    
    @IBOutlet weak var ownButton: UIButton!
    
    @IBOutlet weak var yearButton: UIButton!
    
    @IBOutlet weak var playersButton: UIButton!
    
    @IBOutlet weak var playtimeButton: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var importantPeopleLabel: UILabel!
    
    @IBOutlet weak var moreDetailsLabel: UILabel!
    
    @IBOutlet weak var PricingCollectionView: UICollectionView!
    
    @IBOutlet weak var images: UIImageView!
    
    @IBOutlet weak var previousButtonOutlet: UIButton!
    
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    @IBOutlet weak var galleryOutOfLabel: UILabel!
    
    @IBOutlet weak var imagesLabel: UILabel!
        
    @IBOutlet var leftSwipeGesture: UISwipeGestureRecognizer!
    
    @IBOutlet var rightSwipeGesture: UISwipeGestureRecognizer!
    
    @IBOutlet weak var firebaseButtonsStack: UIStackView!
    
    
    
    var gameObject : [BoardGameItems] = []
    
    var PriceUSObject : [USClass] = []
    var PriceUsedObject : [UsedClass] = []
    
    var ImageObjects : [ImageClass] = []
    var ImageArray = [UIImage]()
    
    var imageArrayIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = gameObject[0].name
        populatePage(boardGame: gameObject[0])
        
        // delegate and datasource so collection view can be populated
        PricingCollectionView.delegate = self
        PricingCollectionView.dataSource = self
        
        // this function will tell if we are sign in; if we are then
        // bookmark, wishlist, and own will appear
        authenticateUseraAndConfigure()
        
        // This task is so we can get price and populate the collection view (async)
        Task {
            
            self.showSpinnerHome(onView: self.view)
            // use game object id inserted into a url string from brought over game object to search json
            let result = try await PriceJson.getPriceDataAsync(urlString: "https://api.boardgameatlas.com/api/game/prices?game_id=" + gameObject[0].id + "&client_id=PTMfSPtwDh")
            // call function that appends json result to both PriceUSObject and PriceUsedObject Arrays
            getPriceList(json: result)
            
            // reload collection view
            PricingCollectionView.reloadData()
            
            self.removeSpinnerHome()
        }
        // This task is so we can get Image json so we can populate the image gallery (async)
        Task {
            
            //imagesLabel.isHidden = true
            //images.isHidden = true
            previousButtonOutlet.isHidden = true
            nextButtonOutlet.isHidden = true
            galleryOutOfLabel.isHidden = true
            // use game object id inserted into a url string from brought over game object to search json
            let result = try await ImageJson.getImageDataAsync(urlString:"https://api.boardgameatlas.com/api/game/images?game_id=" + gameObject[0].id + "&pretty=true&limit=20&client_id=PTMfSPtwDh")

            // call function that appends json result to both ImageObjects Array
            getImageList(json: result)
            
            // now that we have ImageObjects Array count; if its zero then we want dont show any images at all and hide that section in the page
            if ImageObjects.isEmpty{
                previousButtonOutlet.isHidden = true
                nextButtonOutlet.isHidden = true
                galleryOutOfLabel.isHidden = true
            }
            else{
                
                // if the ImageObjects Array is populated; use another task to put all image url from ImageObjects Array
                // into an array of UiImages
                Task{
                    for item in ImageObjects{
                        let photoResult = try await ImageAsyncClass.getImageListAsync(urlString: item.url)
                        ImageArray.append(photoResult)
                    }
                    // if the ImageArray count is 1 then we want the buttons letting you go to previous and next be hidden
                    if ImageArray.count == 1{
                        previousButtonOutlet.isHidden = true
                        nextButtonOutlet.isHidden = true
                        imageArrayIndex = 0
                        images.image = ImageArray[imageArrayIndex]
                        let textString = String(imageArrayIndex+1) + "/" + String(ImageArray.count)
                        galleryOutOfLabel.text = textString
                        leftSwipeGesture.isEnabled = false
                        rightSwipeGesture.isEnabled = false
                    }
                    else{
                        // allow every buttons and labels and images views to appear and perform their functionality
                        imageArrayIndex = 0
                        images.image = ImageArray[imageArrayIndex]
                        let textString = String(imageArrayIndex+1) + "/" + String(ImageArray.count)
                        galleryOutOfLabel.text = textString
                        imagesLabel.isHidden = false
                        images.isHidden = false
                        previousButtonOutlet.isHidden = false
                        nextButtonOutlet.isHidden = false
                        galleryOutOfLabel.isHidden = false

                    }
                    
                }
            }
        }
    }
    
    // firebase api code
    
    // depending on which color the button is we determine if it needs to be deleted or added onto that users database
    @IBAction func bookmarkButtonPressed(_ sender: Any) {
        needsFirebaseUpdate = true
        if bookmarkButton.configuration?.baseForegroundColor == UIColor.black{
            addGameToDatabase(nameOfButtonPressed: "Bookmarks")
            changeFirebaseButtonColors(nameOfButton: "Bookmarks")
        }
        else{
            deleteGameFromDatabase(nameOfButton: "Bookmarks")
            changeFirebaseButtonColors(nameOfButton: "Bookmarks")
        }
        
    }

    @IBAction func wishlistButtonPressed(_ sender: Any) {
        needsFirebaseUpdate = true
        if wishlistButton.configuration?.baseForegroundColor == UIColor.black{
            addGameToDatabase(nameOfButtonPressed: "Wishlist")
            changeFirebaseButtonColors(nameOfButton: "Wishlist")
        }
        else{
            deleteGameFromDatabase(nameOfButton: "Wishlist")
            changeFirebaseButtonColors(nameOfButton: "Wishlist")
        }
    }

    @IBAction func ownButtonPressed(_ sender: Any) {
        needsFirebaseUpdate = true
        if ownButton.configuration?.baseForegroundColor == UIColor.black{
            addGameToDatabase(nameOfButtonPressed: "Own")
            changeFirebaseButtonColors(nameOfButton: "Own")
        }
        else{
            deleteGameFromDatabase(nameOfButton: "Own")
            changeFirebaseButtonColors(nameOfButton: "Own")
        }
    }
    
    func authenticateUseraAndConfigure(){
        
        if Auth.auth().currentUser == nil {
            firebaseButtonsStack.isHidden = true
        }
        else{
            changeALLFirebaseButtonColors()
            firebaseButtonsStack.isHidden = false

        }
        
    }
    
    func changeALLFirebaseButtonColors(){
        
        let database = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let OwnDatabaseRef = database.child("users").child(userID!).child("Own").child(gameObject[0].id)
        let WishlistDatabaseRef = database.child("users").child(userID!).child("Wishlist").child(gameObject[0].id)
        let BookmarkDatabaseRef = database.child("users").child(userID!).child("Bookmarks").child(gameObject[0].id)

        BookmarkDatabaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                self.bookmarkButton.configuration?.baseForegroundColor = UIColor.systemBlue
                
            }else{
                self.bookmarkButton.configuration?.baseForegroundColor = UIColor.black
                
            }
            
        }
        
        WishlistDatabaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                self.wishlistButton.configuration?.baseForegroundColor = UIColor.systemBlue
                
            }else{
                self.wishlistButton.configuration?.baseForegroundColor = UIColor.black
                
            }
        }
        
        OwnDatabaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                self.ownButton.configuration?.baseForegroundColor = UIColor.systemBlue
                
            }else{
                self.ownButton.configuration?.baseForegroundColor = UIColor.black
                
            }
        }
    }
    
    func changeFirebaseButtonColors(nameOfButton: String){
        
        let database = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let databaseRef = database.child("users").child(userID!).child(nameOfButton).child(gameObject[0].id)
        
        if nameOfButton == "Own"{
            databaseRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(){
                    self.ownButton.configuration?.baseForegroundColor = UIColor.systemBlue
                }else{
                    self.ownButton.configuration?.baseForegroundColor = UIColor.black
                }
            }
        }
        else if nameOfButton == "Bookmarks"{
            databaseRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(){
                    self.bookmarkButton.configuration?.baseForegroundColor = UIColor.systemBlue
                }else{
                    self.bookmarkButton.configuration?.baseForegroundColor = UIColor.black
                }
            }
        }
        else if nameOfButton == "Wishlist"{
            databaseRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(){
                    self.wishlistButton.configuration?.baseForegroundColor = UIColor.systemBlue
                }else{
                    self.wishlistButton.configuration?.baseForegroundColor = UIColor.black
                }
            }
        }
        
    }
    
    // add the game object information into the users database

    func addGameToDatabase(nameOfButtonPressed: String){

        let database = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        
        
        let databaseRef = database.child("users").child(userID!).child(nameOfButtonPressed)

        var mechDict = [String: String]()
        var mechIndex = 0
        for mech in gameObject[0].mechanics{
            mechDict[String(mechIndex)] = String(mech)
            mechIndex += 1
        }

        var cateDict = [String: String]()
        var cateIndex = 0
        for cate in gameObject[0].categories{
            cateDict[String(cateIndex)] = String(cate)
            cateIndex += 1
        }
        var artistDict =  [String: String]()
        var artistIndex = 0
        for artist in gameObject[0].artists{
            artistDict[String(artistIndex)] = String(artist)
            artistIndex += 1
        }
        
        var publDict =  [String: String]()
        var publIndex = 0
        for publ in gameObject[0].primary_publisher{
            publDict[String(publIndex)] = String(publ)
            publIndex += 1
        }
        
        var desiDict =  [String: String]()
        var desiIndex = 0
        for desi in gameObject[0].primary_designer{
            desiDict[String(desiIndex)] = String(desi)
            desiIndex += 1
        }
        
        let values = [ String(gameObject[0].id) : ["id": String(gameObject[0].id),
                      "name": String(gameObject[0].name),
                      "price": String(gameObject[0].price),
                      "msrp": Float(gameObject[0].msrp),
                      "discount": String(gameObject[0].discount),
                      "year_published": Int(gameObject[0].year_published),
                      "min_players": Int(gameObject[0].min_players),
                      "max_players": Int(gameObject[0].max_players),
                      "min_playtime": Int(gameObject[0].min_playtime),
                      "max_playtime": Int(gameObject[0].max_playtime),
                      "min_age": Int(gameObject[0].min_age),
                      "image_url": String(gameObject[0].image_url),
                      "mechanics": mechDict,
                      "categories": cateDict,
                      "primary_publisher": publDict,
                      "primary_designer": desiDict,
                      "artists": artistDict,
                      "rules_url": String(gameObject[0].rules_url),
                      "official_url": String(gameObject[0].official_url),
                      "weight_amount": Float(gameObject[0].weight_amount),
                      "weight_units": String(gameObject[0].weight_units),
                      "size_height": Float(gameObject[0].size_height),
                      "size_depth": Float(gameObject[0].size_depth),
                      "size_units": String(gameObject[0].size_units),
                      "num_distributors": Int(gameObject[0].num_distributors),
                      "players": String(gameObject[0].players),
                      "playtime": String(gameObject[0].playtime),
                      "msrp_text": String(gameObject[0].msrp_text),
                      "price_text": String(gameObject[0].price_text),
                      "description_preview": String(gameObject[0].description_preview) ] as [String : Any] ] as [String : Any]


        databaseRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            guard error == nil else{
                return
            }
        })

    }
    
    // delete game from databse based on what state the button is
    func deleteGameFromDatabase(nameOfButton: String){
        
        let database = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let databaseRef = database.child("users").child(userID!).child(nameOfButton).child(gameObject[0].id)
        databaseRef.removeValue()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "boardGameToDetail", let nextVC = segue.destination as? DetailTableViewController, let gameInfo = sender as? BoardGameItems {
            nextVC.gameObject = [gameInfo]
            nextVC.delegate = self
            
            
        }
        if segue.identifier == "gamePageToSearch", let nextVC = segue.destination as? SearchTableViewController {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    // take us to detail view controller that will show more details of the game such as
    // size; categories, mechancics; artist
    @IBAction func moreDetailsPressed(_ sender: Any) {
        performSegue(withIdentifier: "boardGameToDetail", sender: gameObject[0])
    }

    // this section fo code is fpr the image
    // we have swipe gestures that mimics previous and next buttons
    
    @IBAction func leftSwipePerformed(_ sender: Any) {
        imageArrayIndex += 1
        if imageArrayIndex > ImageArray.count-1{
            imageArrayIndex = 0
        }
        images.image = ImageArray[imageArrayIndex]
        
        let textString = String(imageArrayIndex+1) + "/" + String(ImageArray.count)
        galleryOutOfLabel.text = textString
    }
    
    @IBAction func rightSwipePerformed(_ sender: Any) {
        imageArrayIndex -= 1
        if imageArrayIndex < 0{
            imageArrayIndex = ImageArray.count-1
        }
        images.image = ImageArray[imageArrayIndex]
        
        let textString = String(imageArrayIndex+1) + "/" + String(ImageArray.count)
        galleryOutOfLabel.text = textString
    }
    
    
    
    @IBAction func previousButton(_ sender: Any) {
        imageArrayIndex -= 1
        if imageArrayIndex < 0{
            imageArrayIndex = ImageArray.count-1
        }
        images.image = ImageArray[imageArrayIndex]
        
        let textString = String(imageArrayIndex+1) + "/" + String(ImageArray.count)
        galleryOutOfLabel.text = textString
    }
    
    @IBAction func nextButton(_ sender: Any) {
        imageArrayIndex += 1
        if imageArrayIndex > ImageArray.count-1{
            imageArrayIndex = 0
        }
        images.image = ImageArray[imageArrayIndex]
        
        let textString = String(imageArrayIndex+1) + "/" + String(ImageArray.count)
        galleryOutOfLabel.text = textString
    }
    
    
    
    
    //collectionview stuff
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PriceUSObject.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let row = indexPath.row
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceCell", for: indexPath) as! websitePricingInfoCell
        
        // Change Game Label text; check to see if name is N/A first
        if PriceUSObject[row].store_name == "N/A"{
            cell.storeNameLabel.text = "N/A"
        }
        else{
            cell.storeNameLabel.text = PriceUSObject[row].store_name
        }
        // Change player number Label text; check to see if name is N/A first
        if PriceUSObject[row].price_text == "N/A"{
            cell.storePricingLabel.text = "N/A"
        }
        else{
            cell.storePricingLabel.text = PriceUSObject[row].price_text
        }
        
        // Change gameplay time Label text; check to see if name is N/A first
        if PriceUSObject[row].free_shipping_text == "N/A"{
            cell.storeShippingLabel.text = "N/A"
        }
        else{
            cell.storeShippingLabel.text = PriceUSObject[row].free_shipping_text
        }
        
        return cell
    }
    
    
    // if board game cell is selected we segue to board game page and change highlighted color back to original color
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? websitePricingInfoCell {
            cell.backgroundColor = UIColor(red: (220/255.0), green: (180/255.0), blue: (131/255.0), alpha: 1.0)
            UIApplication.shared.open(URL(string: PriceUSObject[indexPath[1]].url)!)
        }

    }

    // if board game cell is highlighted but it will change into a darker color so it can show to the user that its currently being selected
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? websitePricingInfoCell {
            cell.backgroundColor = hexStringToUIColor(hex: "AA8C67")
        }
    }
    
    
    // if highlighted but not selected then we change the color back to the original color
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? websitePricingInfoCell {
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
    
    // API Code
    
    func getImageList(json:ImageStruct) {
        
        // variable for the number of titles that I have called for the url request
        let ImageNum = json.count
        
        // this shouldnt happend but if for some reaosn the homelimit (being the number of request I asked for)
        // is more than the url request; than i should make sure they are equal numbers so i dont break my for loop
        var ImageLimit = json.images.count
        if ImageLimit > ImageNum{
            ImageLimit = ImageNum
        }
        
        if ImageLimit == 0{
            return
        }
        // for loop going through every game object that was brought by the url request
        for photo in 0...ImageLimit-1{

            // we create a class using the information and append that class object into a list that will then be populating out collection view table
            ImageObjects.append(ImageClass(
                id: json.images[photo].id ?? "N/A",
                url: json.images[photo].url ?? "N/A",
                uploaded_by: json.images[photo].uploaded_by ?? "N/A",
                created_at: json.images[photo].created_at ?? "N/A"
            ))
            
        }
    }
    
    class ImageAsyncClass{
        
        private static let defaultSession = URLSession(configuration: .default)
        
        static func getImageListAsync(urlString:String) async throws -> UIImage{
            
            guard let url = URL(string: urlString) else{
                throw APIError.invalidUrl
            }
            
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                throw APIError.invalidServerResponse
                
            }
            
            guard let imageData = UIImage(data: data) else{
                throw APIError.invalidData
            }
                    
            return imageData
        }
    }
    

    
    func getPriceList(json:PriceStruct) {
        
        let USPriceLimit = json.gameWithPrices.us.count
        let UsedPriceLimit = json.gameWithPrices.used.count
        
        if USPriceLimit == 0 && UsedPriceLimit == 0 {
            return
        }
        else if USPriceLimit == 0 {
            
            for store in 0...UsedPriceLimit-1{
                PriceUsedObject.append(UsedClass(
                    id: json.gameWithPrices.used[store].id ?? "N/A",
                    currency: json.gameWithPrices.used[store].currency ?? "N/A",
                    url: json.gameWithPrices.used[store].url ?? "N/A",
                    store_name: json.gameWithPrices.used[store].store_name ?? "N/A",
                    updated_at: json.gameWithPrices.used[store].updated_at ?? "N/A",
                    updated_at_ago: json.gameWithPrices.used[store].updated_at_ago ?? "N/A",
                    price_text: json.gameWithPrices.used[store].price_text ?? "N/A",
                    free_shipping_text: json.gameWithPrices.used[store].free_shipping_text ?? "N/A",
                    in_stock: json.gameWithPrices.used[store].in_stock ?? false
                ))
            }
            
        }
        else if UsedPriceLimit == 0 {
            
            for store in 0...USPriceLimit-1{
                PriceUSObject.append(USClass(
                    id: json.gameWithPrices.us[store].id ?? "N/A",
                    currency: json.gameWithPrices.us[store].currency ?? "N/A",
                    url: json.gameWithPrices.us[store].url ?? "N/A",
                    store_name: json.gameWithPrices.us[store].store_name ?? "N/A",
                    updated_at: json.gameWithPrices.us[store].updated_at ?? "N/A",
                    updated_at_ago: json.gameWithPrices.us[store].updated_at_ago ?? "N/A",
                    price_text: json.gameWithPrices.us[store].price_text ?? "N/A",
                    free_shipping_text: json.gameWithPrices.us[store].free_shipping_text ?? "N/A",
                    in_stock: json.gameWithPrices.us[store].in_stock ?? false
                ))
            }
            
        }
        else{
            for store in 0...USPriceLimit-1{
                PriceUSObject.append(USClass(
                    id: json.gameWithPrices.us[store].id ?? "N/A",
                    currency: json.gameWithPrices.us[store].currency ?? "N/A",
                    url: json.gameWithPrices.us[store].url ?? "N/A",
                    store_name: json.gameWithPrices.us[store].store_name ?? "N/A",
                    updated_at: json.gameWithPrices.us[store].updated_at ?? "N/A",
                    updated_at_ago: json.gameWithPrices.us[store].updated_at_ago ?? "N/A",
                    price_text: json.gameWithPrices.us[store].price_text ?? "N/A",
                    free_shipping_text: json.gameWithPrices.us[store].free_shipping_text ?? "N/A",
                    in_stock: json.gameWithPrices.us[store].in_stock ?? false
                ))
            }
            for store in 0...UsedPriceLimit-1{
                PriceUsedObject.append(UsedClass(
                    id: json.gameWithPrices.used[store].id ?? "N/A",
                    currency: json.gameWithPrices.used[store].currency ?? "N/A",
                    url: json.gameWithPrices.used[store].url ?? "N/A",
                    store_name: json.gameWithPrices.used[store].store_name ?? "N/A",
                    updated_at: json.gameWithPrices.used[store].updated_at ?? "N/A",
                    updated_at_ago: json.gameWithPrices.used[store].updated_at_ago ?? "N/A",
                    price_text: json.gameWithPrices.used[store].price_text ?? "N/A",
                    free_shipping_text: json.gameWithPrices.used[store].free_shipping_text ?? "N/A",
                    in_stock: json.gameWithPrices.used[store].in_stock ?? false
                ))
            }
        }
                
    }
    
    func populatePage(boardGame : BoardGameItems) {
        
        if boardGame.image_url == "N/A"{
            boardGameImage.image = UIImage(named: "NA")
        }
        else{
            let url = URL(string: boardGame.image_url)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.boardGameImage.image = UIImage(data: imageData)
                    if self.boardGameImage.image == nil{
                        self.boardGameImage.image = UIImage(named: "NA")
                    }
                }
            }.resume()
        }
        
        // set button text
        if boardGame.year_published == 0 {
            yearButton.isHidden = true
        }
        else{
            yearButton.setTitle(String(boardGame.year_published), for: .normal)
        }
        
        if boardGame.players == "N/A" {
            playersButton.isHidden = true
        }
        else{
            playersButton.setTitle(boardGame.players, for: .normal)
        }
        
        if boardGame.playtime == "N/A" {
            playtimeButton.isHidden = true
        }
        else{
            playtimeButton.setTitle(boardGame.playtime, for: .normal)
        }
        
        // populate collection view of pricing here
        
        // set description text
        if boardGame.description_preview == "N/A" {
            descriptionLabel.isHidden = true
        }
        else{
            descriptionLabel.text = boardGame.description_preview
        }
        
        if boardGame.description_preview == "N/A" {
            descriptionLabel.isHidden = true
        }
        else{
            descriptionLabel.text = boardGame.description_preview
        }
        
        let importantPeopleText = createImportantPeople(boardGame: boardGame)
        
        if importantPeopleText == "N/A"{
            importantPeopleLabel.isHidden = true
        }
        else{
            importantPeopleLabel.text = importantPeopleText
        }

        
    }
    
    func createImportantPeople(boardGame : BoardGameItems) -> String{
        
        if boardGame.primary_designer[1] == "N/A" && boardGame.primary_publisher[1] == "N/A"{
            importantPeopleLabel.isHidden = true
            return "N/A"
        }
        else if boardGame.primary_designer[1] == "N/A" {
            return boardGame.primary_publisher[1]
        }
        else if boardGame.primary_publisher[1] == "N/A" {
            return boardGame.primary_designer[1]
        }
        else {
            return boardGame.primary_designer[1] + " - " + boardGame.primary_publisher[1]
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
