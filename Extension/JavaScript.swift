//
//  JavaScript.swift
//  Extension
//
//  Created by Yulian Gyuroff on 2.11.23.
//

import UIKit

class JavaScript: NSObject, NSCoding {
    
    var jsTitle: String
    var javaScript: String
    
    init(javaScript: String, jsTitle: String) {
        self.jsTitle = jsTitle
        self.javaScript = javaScript
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(jsTitle, forKey: "jsTitle")
        aCoder.encode(javaScript, forKey: "javaScript")
     }
    
    required init?(coder aDecoder: NSCoder) {
        jsTitle = aDecoder.decodeObject(forKey: "jsTitle") as? String ?? ""
        javaScript = aDecoder.decodeObject(forKey: "javaScript") as? String ?? ""
    }
}
