//
//  APIError.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 3/28/23.
//

import Foundation

// call strings for errors in Firebase Api

enum APIError: Error {
    case invalidUrl
    case invalidServerResponse
    case invalidData
}

extension APIError: CustomStringConvertible{
    public var description: String{
        switch self {
        case .invalidUrl:
            return "Bad URL"
        case .invalidServerResponse:
            return "The server did not return 200"
        case .invalidData:
            return "The server returned bad data"
        }
    }
}
