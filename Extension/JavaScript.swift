//
//  JavaScript.swift
//  Extension
//
//  Created by Yulian Gyuroff on 2.11.23.
//

import UIKit

class JavaScript: NSObject, NSCoding {
    
    var javaScript: String
    
    init(javaScript: String) {
        self.javaScript = javaScript
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(javaScript, forKey: "javaScript")
    }
    
    required init?(coder aDecoder: NSCoder) {
        javaScript = aDecoder.decodeObject(forKey: "javaScript") as? String ?? ""
    }
}
