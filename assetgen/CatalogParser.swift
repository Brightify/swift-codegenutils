//
//  CatalogParser.swift
//  codegenutils
//
//  Created by Tadeas Kriz on 05/01/15.
//  Copyright (c) 2015 Brightify. All rights reserved.
//

import Foundation

class CatalogParser : CodeGenTool {
    
    var imageSetURLs: [NSURL?] = []
    var returnType: String = "UIImage?"
    
    override func startWithCompletionHandler(completionClosure: () -> ()) {
        if(implicitUnwrapping) {
            returnType = "UIImage!"
        }
        let dispatchGroup = dispatch_group_create()
        let dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(dispatchQueue) {
            self.findImageSetURLs()
            let classNameWithPossibleSpaces = "\(self.classPrefix)\(self.inputURL.lastPathComponent!.stringByDeletingPathExtension)Catalog"
            self.className = classNameWithPossibleSpaces.stringByReplacingOccurrencesOfString(" ", withString: "", options:NSStringCompareOptions.allZeros, range: Range<String.Index>(start: classNameWithPossibleSpaces.startIndex, end: classNameWithPossibleSpaces.endIndex))
            for imageSetURL in self.imageSetURLs {
                if let imageSetURL = imageSetURL {
                    dispatch_group_async(dispatchGroup, dispatchQueue) {
                        self.parseImageSetAtURL(imageSetURL)
                    }
                }
            }
            
            dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
            
            self.writeOutputFiles()
            
            completionClosure()
        }
    }
    
    func findImageSetURLs() {
        imageSetURLs = []
        let enumerator = NSFileManager().enumeratorAtURL(inputURL,
            includingPropertiesForKeys: [String(NSURLNameKey)],
            options: NSDirectoryEnumerationOptions.allZeros,
            errorHandler: nil)
        while let url = enumerator?.nextObject() as? NSURL {
            if(url.pathExtension == "imageset") {
                imageSetURLs.append(url)
            }
        }
        
    }
    
    func parseImageSetAtURL(url: NSURL) {
        let imageSetName = url.lastPathComponent?.stringByDeletingPathExtension
        let methodName = methodNameForKey(imageSetName!)
        let contentsURL = url.URLByAppendingPathComponent("Contents.json")
        let contentsData: NSData! = NSData(contentsOfURL: contentsURL, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)
        if (contentsData == nil) {
            return
        }
        
        let contents = NSJSONSerialization.JSONObjectWithData(contentsData!, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
        if (contents == nil) {
            return
        }
        
        let variants = contents!["images"]?.sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
            let obj1 = obj1 as NSDictionary
            let obj2 = obj2 as NSDictionary
            
            if (obj1["subtype"] as String? != obj2["subtype"] as String?) {
                if (obj1["subtype"] != nil) {
                    return NSComparisonResult.OrderedDescending;
                }
                if (obj2["subtype"] != nil) {
                    return NSComparisonResult.OrderedAscending;
                }
            }
            
            if (obj1["idiom"] as String != obj2["idiom"] as String) {
                if (obj1["idiom"] as String == "universal") {
                    return NSComparisonResult.OrderedDescending;
                }
                if (obj2["idiom"] as String == "universal") {
                    return NSComparisonResult.OrderedAscending;
                }
            }
            
            if(obj1["scale"] as String > obj2["scale"] as String) {
                return NSComparisonResult.OrderedAscending
            } else {
                return NSComparisonResult.OrderedDescending
            }
        })
        
        var implementation = "class func \(methodName)Image() -> \(returnType) {\n"
        implementation += "    return UIImage(named: \"\(imageSetName!)\")\n"
        implementation += "}\n\n"
        
        synchronized(self) {
            self.contents.append(implementation)
        }
    }
    
    override class func inputFileExtension() -> String {
        return "xcassets"
    }
    
}