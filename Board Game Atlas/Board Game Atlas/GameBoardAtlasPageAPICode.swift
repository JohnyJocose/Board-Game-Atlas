//
//  GameBoardAtlasAPICode.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 3/22/23.
//

import Foundation



/*
 This file mainly for the board Game atlas API code
 
 
 here we're gonna find a lot of Aysnc function
 to get data as structs to put the
 json information called from the API
 into data that we can use to populate other pages
*/


// class to call categories json from website async
class CateJson{
    private static let defaultSession = URLSession(configuration: .default)
    
    static func getCateDataAsync(urlString:String) async throws -> CateStruct{
        
        guard let url = URL(string: urlString) else{
            throw APIError.invalidUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw APIError.invalidServerResponse
        }
        guard let task = try? JSONDecoder().decode(CateStruct.self, from: data) else{
            throw APIError.invalidData
        }
        return task
    }
}

// class object so we can make a list of them
public class CateClass{
    var id: String
    var name: String

    init(id: String, name: String){
        self.id = id
        self.name = name
    }
}
// this is the struct system for a specific category object
struct CateStruct: Codable {
    let categories: [CateResults]
}


struct CateResults: Codable {
    let id: String!
    let name: String!
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
    }
}





// mechanics object code

// mechanics object class that will hold json data of a requested url; url must abide the struct (can be found lower of this page)
class MechJson{
    private static let defaultSession = URLSession(configuration: .default)
    
    static func getMechDataAsync(urlString:String) async throws -> MechStruct{
        
        guard let url = URL(string: urlString) else{
            throw APIError.invalidUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw APIError.invalidServerResponse
            
        }
        guard let task = try? JSONDecoder().decode(MechStruct.self, from: data) else{
            throw APIError.invalidData
        }
        
        return task
    }
}

public class MechClass{
    var id: String
    var name: String

    init(id: String, name: String){
        self.id = id
        self.name = name
    }
}

// this is the struct system for a specific mechanic object
struct MechStruct: Codable {
    let mechanics: [MechResults]
}


struct MechResults: Codable {
    let id: String!
    let name: String!
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
    }
}




// image object code

// image id object class that will hold json data of a requested url; url must abide the struct (can be found lower of this page)
class ImageJson{
    private static let defaultSession = URLSession(configuration: .default)
    
    static func getImageDataAsync(urlString:String) async throws -> ImageStruct{
        
        guard let url = URL(string: urlString) else{
            throw APIError.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw APIError.invalidServerResponse
            
        }
        guard let task = try? JSONDecoder().decode(ImageStruct.self, from: data) else{
            throw APIError.invalidData
        }

        return task
    }
}

// class object for api json image object

public class ImageClass{

    var id: String
    var url: String
    var uploaded_by: String
    var created_at: String
    

    init(id: String, url: String, uploaded_by: String, created_at: String){
        self.id = id
        self.url = url
        self.uploaded_by = uploaded_by
        self.created_at = created_at
    }

}

// this is the struct system for a specific image object
struct ImageStruct: Codable {
    let count: Int
    let images: [ImageResults]
}


struct ImageResults: Codable {
    let id: String!
    let url: String!
    let uploaded_by: String!
    let created_at: String!
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        uploaded_by = try container.decodeIfPresent(String.self, forKey: .uploaded_by)
        created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        
        
    }
}




// price object code

// price object class that will hold json data of a requested url; url must abide the struct (can be found lower of this page)
class PriceJson{
    private static let defaultSession = URLSession(configuration: .default)
    
    static func getPriceDataAsync(urlString:String) async throws -> PriceStruct{
        
        guard let url = URL(string: urlString) else{
            throw APIError.invalidUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw APIError.invalidServerResponse
            
        }
        guard let task = try? JSONDecoder().decode(PriceStruct.self, from: data) else{
            throw APIError.invalidData
        }
        return task
    }
}

// class object for api json United States object

public class USClass{

    var id: String
    var currency: String
    var url: String
    var store_name: String
    var updated_at: String
    var updated_at_ago: String
    var price_text: String
    var free_shipping_text: String
    var in_stock: Bool
    

    init(id: String, currency: String, url: String, store_name: String, updated_at: String, updated_at_ago: String, price_text: String, free_shipping_text: String, in_stock: Bool){
        self.id = id
        self.currency = currency
        self.url = url
        self.store_name = store_name
        self.updated_at = updated_at
        self.updated_at_ago = updated_at_ago
        self.price_text = price_text
        self.free_shipping_text = free_shipping_text
        self.in_stock = in_stock
    }

}

// class object for api json Used object

public class UsedClass{

    var id: String
    var currency: String
    var url: String
    var store_name: String
    var updated_at: String
    var updated_at_ago: String
    var price_text: String
    var free_shipping_text: String
    var in_stock: Bool
    

    init(id: String, currency: String, url: String, store_name: String, updated_at: String, updated_at_ago: String, price_text: String, free_shipping_text: String, in_stock: Bool){
        self.id = id
        self.currency = currency
        self.url = url
        self.store_name = store_name
        self.updated_at = updated_at
        self.updated_at_ago = updated_at_ago
        self.price_text = price_text
        self.free_shipping_text = free_shipping_text
        self.in_stock = in_stock
    }

}

// this is the struct system for a specific price object
struct PriceStruct: Codable {
    let gameWithPrices: CountryStruct!
}


struct CountryStruct: Codable {
    let canada: [StoreStruct]!
    let uk: [StoreStruct]!
    let au: [StoreStruct]!
    let us: [StoreStruct]!
    let used: [StoreStruct]!
}



struct StoreStruct: Codable {
    let id: String!
    let currency: String!
    let url: String!
    let store_name: String!
    let updated_at: String!
    let updated_at_ago: String!
    let price_text: String!
    let free_shipping_text: String!
    let in_stock: Bool!
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        store_name = try container.decodeIfPresent(String.self, forKey: .store_name)
        updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
        updated_at_ago = try container.decodeIfPresent(String.self, forKey: .updated_at_ago)
        price_text = try container.decodeIfPresent(String.self, forKey: .price_text)
        free_shipping_text = try container.decodeIfPresent(String.self, forKey: .free_shipping_text)
        in_stock = try container.decodeIfPresent(Bool.self, forKey: .in_stock)
        
        
    }
    
    
    
}







// board game object code

// board game object class that will hold json data of a requested url; url must abide the struct (can be found lower of this page)
class HomeJson{
    private static let defaultSession = URLSession(configuration: .default)
    
    static func getHomeDataAsync(urlString:String) async throws -> GamePageStruct{
        
        guard let url = URL(string: urlString) else{
            throw APIError.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw APIError.invalidServerResponse
        }
        
        guard let task = try? JSONDecoder().decode(GamePageStruct.self, from: data) else{
            throw APIError.invalidData
        }
        
        return task
    }
}

// class object for api json game object

public class BoardGameItems{
    
    var id: String
    var name: String
    var price: String
    var msrp: Float
    var discount: String
    var year_published: Int
    var min_players: Int
    var max_players: Int
    var min_playtime: Int
    var max_playtime: Int
    var min_age: Int
    var image_url: String
    var mechanics: [String]
    var categories: [String]
    var primary_publisher: [String]
    var primary_designer: [String]
    var artists: [String]
    var rules_url: String
    var official_url: String
    var weight_amount: Float
    var weight_units: String
    var size_height: Float
    var size_depth: Float
    var size_units: String
    var num_distributors: Int
    var players: String
    var playtime: String
    var msrp_text: String
    var price_text: String
    var description_preview: String

    init(id: String, name: String, price: String, msrp: Float, discount: String, year_published: Int, min_players: Int, max_players: Int, min_playtime: Int, max_playtime: Int, min_age: Int, image_url: String, mechanics: [String], categories: [String], primary_publisher: [String], primary_designer: [String], artists: [String], rules_url: String, official_url: String, weight_amount: Float, weight_units: String, size_height: Float, size_depth: Float, size_units: String, num_distributors: Int, players: String, playtime: String, msrp_text: String, price_text: String, description_preview: String) {
        self.id = id
        self.name = name
        self.price = price
        self.msrp = msrp
        self.discount = discount
        self.year_published = year_published
        self.min_players = min_players
        self.max_players = max_players
        self.min_playtime = min_playtime
        self.max_playtime = max_playtime
        self.min_age = min_age
        self.image_url = image_url
        self.mechanics = mechanics
        self.categories = categories
        self.primary_publisher = primary_publisher
        self.primary_designer = primary_designer
        self.artists = artists
        self.rules_url = rules_url
        self.official_url = official_url
        self.weight_amount = weight_amount
        self.weight_units = weight_units
        self.size_height = size_height
        self.size_depth = size_depth
        self.size_units = size_units
        self.num_distributors = num_distributors
        self.players = players
        self.playtime = playtime
        self.msrp_text = msrp_text
        self.price_text = price_text
        self.description_preview = description_preview
    }

}

// this is the struct system for a specific game object
struct GamePageStruct: Codable {
    let games: [GamePageResults]
    let count: Int
}


struct GamePageResults: Codable {
    let id: String! // ID that lets me search needed info for page NEEDED!
    let name: String! // Name of the board Game NEEDED!
    let price: String! // cheapest price NEEDED!
    let msrp: Float! // Base Price NEEDED!
    let discount: String! //percentage of discount NEEDED!
    let year_published: Int! // year published NEEDED!
    let min_players: Int! // min players NEEDED!
    let max_players: Int! // max players NEEDED!
    let min_playtime: Int! // min play time NEEDED!
    let max_playtime: Int! // max play time NEEDED!
    let min_age: Int! // min age to play NEEDED!
    let image_url: String! // primary image url NEEDED!
    let mechanics: [MyMechanics]! // Nested Array of mechanics this game belong to NEEDED!
    let categories: [MyCategories]! // Nested Array of categories this game belong to NEEDED!
    let primary_publisher: MyPrimaryPublisher! // Dictionary of Primary publisher info NEEDED!
    let primary_designer: MyPrimaryDesigner! // Dictionary of Primary Designer info NEEDED!
    let artists: [String]! // Array of artist names NEEDED!
    let rules_url: String! // rules url NEEDED!
    let official_url: String! // official rules URL NEEDED!
    let weight_amount: Float! // weight of board game NEEDED!
    var weight_units: String! // unit of weight NEEDED!
    var size_height: Float! // height of board game NEEDED!
    var size_depth: Float! // depth of board game NEEDED!
    var size_units: String! // unit of measurment NEEDED!
    let num_distributors: Int! // number of websites selling item NEEDED!
    let players: String! // players in string form NEEDED!
    let playtime: String! // playtime in string form NEEDED!
    var msrp_text: String! // all the time base price in string form NEEDED!
    let price_text: String! // lowest price found in string form NEEDED!
    let description_preview: String! // not html desription NEEDED!
    
    // this section is just in case we some how find a a different type of variable
    // it should be the same but some are not
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        price = try container.decodeIfPresent(String.self, forKey: .price)
        do {
            msrp = try container.decodeIfPresent(Float.self, forKey: .msrp)
        } catch DecodingError.typeMismatch {
            msrp = try Float(container.decode(String.self, forKey: .msrp))
        }
        discount = try container.decodeIfPresent(String.self, forKey: .discount)
        year_published = try container.decodeIfPresent(Int.self, forKey: .year_published)
        min_players = try container.decodeIfPresent(Int.self, forKey: .min_players)
        max_players = try container.decodeIfPresent(Int.self, forKey: .max_players)
        min_playtime = try container.decodeIfPresent(Int.self, forKey: .min_playtime)
        max_playtime = try container.decodeIfPresent(Int.self, forKey: .max_playtime)
        min_age = try container.decodeIfPresent(Int.self, forKey: .min_age)
        image_url = try container.decodeIfPresent(String.self, forKey: .image_url)
        mechanics = try container.decodeIfPresent([MyMechanics].self, forKey: .mechanics)
        categories = try container.decodeIfPresent([MyCategories].self, forKey: .categories)
        primary_publisher = try container.decodeIfPresent(MyPrimaryPublisher.self, forKey: .primary_publisher)
        primary_designer = try container.decodeIfPresent(MyPrimaryDesigner.self, forKey: .primary_designer)
        artists = try container.decodeIfPresent([String].self, forKey: .artists)
        rules_url = try container.decodeIfPresent(String.self, forKey: .rules_url)
        official_url = try container.decodeIfPresent(String.self, forKey: .official_url)
        weight_amount = try container.decodeIfPresent(Float.self, forKey: .weight_amount)
        weight_units = try container.decodeIfPresent(String.self, forKey: .weight_units)
        size_height = try container.decodeIfPresent(Float.self, forKey: .size_height)
        size_depth = try container.decodeIfPresent(Float.self, forKey: .size_depth)
        size_units = try container.decodeIfPresent(String.self, forKey: .size_units)
        num_distributors = try container.decodeIfPresent(Int.self, forKey: .num_distributors)
        players = try container.decodeIfPresent(String.self, forKey: .players)
        playtime = try container.decodeIfPresent(String.self, forKey: .playtime)
        msrp_text = try container.decodeIfPresent(String.self, forKey: .msrp_text)
        price_text = try container.decodeIfPresent(String.self, forKey: .price_text)
        description_preview = try container.decodeIfPresent(String.self, forKey: .description_preview)
    }
}

struct MyMechanics: Codable {
    let id: String! // ID that lets me search mechanics Ids needed info for filter game page NEEDED!
}

struct MyCategories: Codable {
    let id: String! // ID that lets me search category Ids needed info for filter game page NEEDED!
    
}

struct MyPrimaryPublisher: Codable {
    let id: String! // ID that lets me search primary publisher's Id needed info for filter game page NEEDED!
    let name: String! // name of the primary publisher NEEDED!
    
}

struct MyPrimaryDesigner: Codable {
    let id: String! // ID that lets me search primary designer's Id needed info for filter game page NEEDED!
    let name: String! // name of the primary designer NEEDED!
    
}
