//
//  StoryboardDumper.swift
//  codegenutils
//
//  Created by Tadeas Kriz on 06/01/15.
//  Copyright (c) 2015 Brightify. All rights reserved.
//

import Foundation

class StoryboardDumper : CodeGenTool {
    
    
    override func startWithCompletionHandler(completionClosure: () -> ()) {
        skipClassDeclaration = true
        
        var error: NSErrorPointer = NSErrorPointer()
        
        let storyboardFilename = inputURL.lastPathComponent?.stringByDeletingPathExtension
        let storyboardName = storyboardFilename?.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.allZeros, range: wholeStringRange(storyboardFilename!))
        
        className = "\(classPrefix)\(storyboardName!)"
        let document = NSXMLDocument(contentsOfURL: inputURL, options: 0, error: error)
        
        let storyboardIdentifiers = document?.nodesForXPath("//@storyboardIdentifier", error: error)?.map { (value) -> String? in
            let value = value as NSXMLNode
            return value.stringValue
        }
        let reuseIdentifiers = document?.nodesForXPath("//@reuseIdentifier", error: error)?.map { (value) -> String? in
            let value = value as NSXMLNode
            return value.stringValue
        }
        let segueIdentifiers = document?.nodesForXPath("//segue/@identifier", error: error)?.map { (value) -> String? in
            let value = value as NSXMLNode
            return value.stringValue
        }
     
        var identifiers: [String?] = []
        if let storyboardIdentifiers = storyboardIdentifiers {
            identifiers.extend(storyboardIdentifiers)
        }
        if let reuseIdentifiers = reuseIdentifiers {
            identifiers.extend(reuseIdentifiers)
        }
        if let segueIdentifiers = segueIdentifiers {
            identifiers.extend(segueIdentifiers)
        }
        
        contents = []
        
        var uniqueKeys: NSMutableDictionary = NSMutableDictionary()
        uniqueKeys.setValue(storyboardFilename!, forKey: "\(classPrefix)\(storyboardName!)StoryboardName")
        
        for identifier in identifiers {
            if let identifier = identifier {
                uniqueKeys.setValue(identifier, forKey: "\(classPrefix)\(storyboardName!)Storyboard\(titlecaseString(identifier))Identifier")
            }
        }
        
        // TODO sort by case insenstive comparation
        for (key, value) in uniqueKeys {
            contents.append("let \(key): String = \"\(value)\"\n")
        }
        
        writeOutputFiles()
        
        completionClosure()

    }
    
    override class func inputFileExtension() -> String {
        return "storyboard"
    }
    
    private func titlecaseString(string: String) -> String {
        let words = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        var output = ""
        for word in words {
            output += "\(word.substringToIndex(advance(word.startIndex, 1)))\(word.substringFromIndex(advance(word.startIndex, 1)))"
        }
        return output
    }
    
}