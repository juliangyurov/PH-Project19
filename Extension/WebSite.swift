//
//  WebSite.swift
//  Extension
//
//  Created by Yulian Gyuroff on 2.11.23.
//

import UIKit

class WebSite: NSObject, NSCoding {
    
    var host: String
    var jScripts: [JavaScript]
    
    init(host: String, jScripts: [JavaScript]) {
        self.host = host
        self.jScripts = jScripts
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(host, forKey: "host")
        aCoder.encode(jScripts, forKey: "jScripts")
    }
    
    required init?(coder aDecoder: NSCoder) {
        host = aDecoder.decodeObject(forKey: "host") as? String ?? ""
        jScripts = aDecoder.decodeObject(forKey: "jScripts") as? [JavaScript] ?? [JavaScript]()
    }
}
