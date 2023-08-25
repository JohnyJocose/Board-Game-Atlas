//
//  DetailTableViewController.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 4/9/23.
//

import UIKit

// different types of content tell with there own classes of labels
class DetailHeaderContentCell: UITableViewCell {
    override func layoutSubviews() {
        
        // cell rounded section
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true

    }
    
    @IBOutlet weak var detailTitleLabel: UILabel!
    
    
}

class DetailContentCell: UITableViewCell {
    override func layoutSubviews() {
        
        // cell rounded section
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.masksToBounds = true

    }
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!
    
}

class CategoryHeaderContentCell: UITableViewCell {
    
    override func layoutSubviews() {
        
        // cell rounded section
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true

    }
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    
}

class CategoryContentCell: UITableViewCell {
    
    override func layoutSubviews() {
        
        // cell rounded section
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.masksToBounds = true

    }
    
    
    @IBOutlet weak var categoryTypeLabel: UILabel!
    
}
class MechanicHeaderContentCell: UITableViewCell {
    
    override func layoutSubviews() {
        
        // cell rounded section
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true

    }
    
    @IBOutlet weak var mechanicTitleLabel: UILabel!
    
}
class MechanicContentCell: UITableViewCell {
    
    override func layoutSubviews() {
        
        // cell rounded section
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.masksToBounds = true

    }
    
    
    @IBOutlet weak var mechanicTypeLabel: UILabel!
    
}
class CreditHeaderContentCell: UITableViewCell {
    
    override func layoutSubviews() {
        
        // cell rounded section
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true

    }
    
    @IBOutlet weak var creditTitleLabel: UILabel!
    
}
class CreditContentCell: UITableViewCell {
    
    override func layoutSubviews() {
        
        // cell rounded section
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.masksToBounds = true

    }
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var creditTypeLabel: UILabel!
    
}


class DetailTableViewController: UITableViewController {
    
    @IBOutlet var detailTable: UITableView!
    
    var delegate: UIViewController!
    var gameObject : [BoardGameItems] = []
    
    // titles for headers
    var sectionTitles : [String] = ["Details", "Mechanics", "Categories", "Credits"]
    
    var detailInfo : [[String]] = []
    var mechanicInfo : [[String]] = []
    var categoryInfo : [[String]] = []
    var creditInfo : [[String]] = []
    
    var sectionData : [Int : [Any]] = [:]
    var mechTypes : Array<MechClass> = []
    var mechsUsed : [[String]] = []
    var cateTypes : Array<CateClass> = []
    var catesUsed : [[String]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTable.delegate = self
        detailTable.dataSource = self
        
        detailTable.sectionHeaderTopPadding = 2
        sectionData = [0 : detailInfo, 1 : mechanicInfo, 2 : categoryInfo, 3 : creditInfo]
        detailTable.reloadData()
        
        // get a list of mechechanics and categories from boardgame api
        // async and shows load bar
        Task {
            
            self.showSpinnerHome(onView: self.view)
            let mechResult = try await MechJson.getMechDataAsync(urlString: "https://api.boardgameatlas.com/api/game/mechanics?pretty=true&client_id=PTMfSPtwDh")
            let cateResult = try await CateJson.getCateDataAsync(urlString: "https://api.boardgameatlas.com/api/game/categories?pretty=true&client_id=PTMfSPtwDh")
            
            getCateList(json: cateResult)
            getMechList(json: mechResult)
            
            for mechItem in gameObject[0].mechanics{
                if let mech = mechTypes.first(where: {$0.id == mechItem}) {
                    mechsUsed.append([mech.id, mech.name])
                } else {
                }
            }
            
            for cateItem in gameObject[0].categories{
                if let cate = cateTypes.first(where: {$0.id == cateItem}) {
                    catesUsed.append([cate.id, cate.name])
                    
                } else {
                }
            }
            
            // put data called form api into there own section to populate the table sections
            createsectionInfo()
            sectionData = [0 : detailInfo, 1 : mechanicInfo, 2 : categoryInfo, 3 : creditInfo]
            detailTable.reloadData()
            self.removeSpinnerHome()
             
        }
    }
    
    func getCateList(json:CateStruct) {

        let cateLimit = json.categories.count
        if cateLimit == 0{
            return
        }
        // for loop going through every game object that was brought by the url request
        for title in 0...cateLimit-1{
            cateTypes.append(CateClass(
                id: json.categories[title].id ?? "N/A",
                name: json.categories[title].name ?? "N/A"
            ))
        }
    }
    
    
    func getMechList(json:MechStruct) {

        let mechLimit = json.mechanics.count
        if mechLimit == 0{
            return
        }
        // for loop going through every game object that was brought by the url request
        for title in 0...mechLimit-1{
            mechTypes.append(MechClass(
                id: json.mechanics[title].id ?? "N/A",
                name: json.mechanics[title].name ?? "N/A"
            ))
        }
    }
    
    func createsectionInfo(){

        // detail section
        if gameObject[0].year_published != 0{
            detailInfo.append(["Year Published", String(gameObject[0].year_published)])
        }
        if gameObject[0].min_players != 0{
            detailInfo.append(["Minimum Players", String(gameObject[0].min_players)])
        }
        if gameObject[0].max_players != 0{
            detailInfo.append(["Maximum Players", String(gameObject[0].min_players)])
        }
        if gameObject[0].min_playtime != 0{
            detailInfo.append(["Minimum Playtime", String(gameObject[0].min_playtime)])
        }
        if gameObject[0].max_playtime != 0{
            detailInfo.append(["Maximum Playtime", String(gameObject[0].max_playtime)])
        }
        if gameObject[0].min_age != 0{
            detailInfo.append(["Minimum Age To Play", String(gameObject[0].min_age)])
        }
        if gameObject[0].weight_amount != 0 && gameObject[0].weight_units != "N/A"{
            detailInfo.append(["Weight", String(gameObject[0].weight_amount) + String(gameObject[0].weight_units)])
        }
        if gameObject[0].size_depth != 0 && gameObject[0].size_units != "N/A"{
            detailInfo.append(["Depth", String(gameObject[0].size_depth) + " " + String(gameObject[0].size_units)])
        }
        if gameObject[0].size_height != 0 && gameObject[0].size_units != "N/A"{
            detailInfo.append(["Height", String(gameObject[0].size_height) + " " + String(gameObject[0].size_units)])
        }
        
        if gameObject[0].official_url != "N/A"{
            detailInfo.append(["Official Site", String(gameObject[0].official_url)])
        }
        if gameObject[0].rules_url != "N/A"{
            detailInfo.append(["Rule URL", String(gameObject[0].rules_url)])
        }
        
        //mech section
        for mech in mechsUsed{
            mechanicInfo.append(["Mechanic", mech[1], mech[0]])
        }

        // cate section
        for cate in catesUsed{
            categoryInfo.append(["Category", cate[1], cate[0]])
        }
        
        // credit info section
        if gameObject[0].primary_designer[1] != "N/A" && gameObject[0].primary_designer[0] != "N/A"{
            creditInfo.append(["Designer", String(gameObject[0].primary_designer[1]), String(gameObject[0].primary_designer[0])])
        }

        if gameObject[0].primary_publisher[1] != "N/A" && gameObject[0].primary_publisher[0] != "N/A"{
            creditInfo.append(["Publisher", String(gameObject[0].primary_publisher[1]), String(gameObject[0].primary_publisher[0])])
        }
        if gameObject[0].artists.isEmpty == false{
            for artist in gameObject[0].artists{
                creditInfo.append(["Artist", artist, artist])
            }
        }
        
        


    }
    
    // populate headsers with their own cell class above; dending on cellidentifier
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionTitles[section] + "HeaderCell" == "DetailsHeaderCell"{
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[section] + "HeaderCell") as! DetailHeaderContentCell
            return cell
            
        }
        else if sectionTitles[section] + "HeaderCell" == "MechanicsHeaderCell"{
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[section] + "HeaderCell") as! MechanicHeaderContentCell
            return cell
            
        }
        else if sectionTitles[section] + "HeaderCell" == "CategoriesHeaderCell"{
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[section] + "HeaderCell") as! CategoryHeaderContentCell
            return cell
            
        }
        else if sectionTitles[section] + "HeaderCell" == "CreditsHeaderCell"{
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[section] + "HeaderCell") as! CreditHeaderContentCell
            return cell
            
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[section] + "HeaderCell") as! DetailHeaderContentCell
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    // MARK: - Table view data source
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return (sectionData[section]?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // for section in details we see if its official site or rule url
        // this way so we can change the color
        
        // this section is usually shown as dark that way people are gonna press it;
        // and the white ones are the clickable ones
        if sectionTitles[indexPath.section] + "Cell" == "DetailsCell"{
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[indexPath.section] + "Cell") as! DetailContentCell
            let cellArrayInfo = sectionData[indexPath.section]![indexPath.row] as! [String]
            
            cell.leftLabel.text = cellArrayInfo[0]
            cell.rightLabel.text = cellArrayInfo[1]
            
            if cellArrayInfo[0] == "Official Site"{
                cell.backgroundColor = UIColor.white
                cell.rightLabel.text = "Official Website"
                cell.rightLabel.textColor = hexStringToUIColor(hex: "#3E89F9")
                
            }
            if cellArrayInfo[0] == "Rule URL"{
                cell.backgroundColor = UIColor.white
                cell.rightLabel.text = "Official Rules"
                cell.rightLabel.textColor = hexStringToUIColor(hex: "#3E89F9")
            }
            return cell
            
        }
        
        // populate mechanics section
        else if sectionTitles[indexPath.section] + "Cell" == "MechanicsCell"{
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[indexPath.section] + "Cell") as! MechanicContentCell
            let cellArrayInfo = sectionData[indexPath.section]![indexPath.row] as! [String]
            cell.mechanicTypeLabel.text = cellArrayInfo[1]
            return cell
            
        }
        // populate categories section
        else if sectionTitles[indexPath.section] + "Cell" == "CategoriesCell"{
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[indexPath.section] + "Cell") as! CategoryContentCell
            let cellArrayInfo = sectionData[indexPath.section]![indexPath.row] as! [String]
            
            cell.categoryTypeLabel.text = cellArrayInfo[1]
            return cell
            
        }
        // populate credits section
        else if sectionTitles[indexPath.section] + "Cell" == "CreditsCell"{
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionTitles[indexPath.section] + "Cell") as! CreditContentCell
            let cellArrayInfo = sectionData[indexPath.section]![indexPath.row] as! [String]
            
            cell.creditTypeLabel.text = cellArrayInfo[1]
            cell.nameLabel.text = cellArrayInfo[0]
            return cell
            
        }
        
        // shouldnt go here but we return a cell to satify function
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailContentCell
        return cell
        
        
    }
    
    // function that determines what to do depending on which cell was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // send the user to the link it's associated with if its official site or rule url
        if sectionTitles[indexPath.section] + "Cell" == "DetailsCell"{
            let cellArrayInfo = sectionData[indexPath.section]![indexPath.row] as! [String]
            if cellArrayInfo[0] == "Official Site" || cellArrayInfo[0] == "Rule URL"{
                UIApplication.shared.open(URL(string: cellArrayInfo[1])!)
            }
        }
        // these rest will perform segue to psuedo home page to search other stuff
        // of this topic
        else if sectionTitles[indexPath.section] + "Cell" == "MechanicsCell"{
            let cellArrayInfo = sectionData[indexPath.section]![indexPath.row] as! [String]
            performSegue(withIdentifier: "detailToPsuedo", sender: cellArrayInfo)
        }
        else if sectionTitles[indexPath.section] + "Cell" == "CategoriesCell"{
            
            let cellArrayInfo = sectionData[indexPath.section]![indexPath.row] as! [String]
            performSegue(withIdentifier: "detailToPsuedo", sender: cellArrayInfo)
        }
        else if sectionTitles[indexPath.section] + "Cell" == "CreditsCell"{
            
            let cellArrayInfo = sectionData[indexPath.section]![indexPath.row] as! [String]
            performSegue(withIdentifier: "detailToPsuedo", sender: cellArrayInfo)
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
    
    // send where we are coming from so psuedo view controller knows how to correctly load that page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToPsuedo", let nextVC = segue.destination as? PsuedoHomeViewController, let typeOfArray = sender as? [String] {
            
            if typeOfArray[0] == "Mechanic"{
                nextVC.comingFrom = "Mechanic"
                
                nextVC.mechName = typeOfArray[1]
                nextVC.mechID = typeOfArray[2]
                nextVC.delegate = self
                
            }
            else if typeOfArray[0] == "Category"{
                nextVC.comingFrom = "Category"
                
                nextVC.cateName = typeOfArray[1]
                nextVC.cateID = typeOfArray[2]
                nextVC.delegate = self
                
            }
            else if typeOfArray[0] == "Designer"{
                nextVC.comingFrom = "Designer"
                
                nextVC.designerName = typeOfArray[1]
                nextVC.designerID = typeOfArray[2]
                nextVC.delegate = self
                
            }
            else if typeOfArray[0] == "Publisher"{
                nextVC.comingFrom = "Publisher"
                
                nextVC.publisherName = typeOfArray[1]
                nextVC.publisherID = typeOfArray[2]
                nextVC.delegate = self
                
            }
            else if typeOfArray[0] == "Artist"{
                nextVC.comingFrom = "Artist"
                
                nextVC.artistName = typeOfArray[1]
                nextVC.artistID = typeOfArray[2]
                nextVC.delegate = self
                
            }
        }
    }
}
