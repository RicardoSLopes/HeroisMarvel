//
//  MarvelAPI.swift
//  HeroisMarvel
//
//  Created by Ricardo Santana on 20/01/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import Foundation
import SwiftHash
import Alamofire

class MarvelAPI {
    
    static private let basePath = "https://gateway.marvel.com/v1/public/characters?"
    static private let limit = 50
    
    class func loadHeroes(name: String?, page: Int = 0, onComplete: @escaping (MarvelInfo?) -> Void) {
        let offset = page * limit
        let startsWith: String
        if let name = name, !name.isEmpty {
            startsWith = "nameStartsWith=\(name.replacingOccurrences(of: " ", with: ""))&"
        }else {
            startsWith = ""
        }
        
        let url = basePath + "offset=\(offset)&limit=\(limit)&" + startsWith + getCredentials()
        print(url)
        Alamofire.request(url).responseJSON { (response) in
            guard let data = response.data,
                  let marvelInfo = try? JSONDecoder().decode(MarvelInfo.self, from: data),
                  marvelInfo.code == 200 else {
                onComplete(nil)
                return
            }
            onComplete(marvelInfo)
        }
    }
    
    private class func getCredentials() -> String {
        let ts = String(Date().timeIntervalSince1970)
        let hash = MD5(ts+getKey("privateKey")+getKey("publicKey")).lowercased()
        return "ts=\(ts)&apikey=\(getKey("publicKey"))&hash=\(hash)"
    }
    
    private class func getKey(_ getkey: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "key", ofType: "plist") else {
            return ""
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        let key = plist?.object(forKey: getkey.uppercased()) as? String ?? ""
        return key
    }
}
