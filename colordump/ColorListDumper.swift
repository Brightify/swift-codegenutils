//
//  ColorListDumper.swift
//  codegenutils
//
//  Created by Tadeas Kriz on 06/01/15.
//  Copyright (c) 2015 Brightify. All rights reserved.
//

import Cocoa

class ColorListDumper : CodeGenTool {

    override func startWithCompletionHandler(completionClosure: () -> ()) {
        let colorListName = self.inputURL.lastPathComponent?.stringByDeletingPathExtension
        
        className = "\(classPrefix)\(colorListName!)ColorList"
        className = className.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.allZeros, range: wholeStringRange(className))
        
        let colorList: NSColorList! = NSColorList(name: colorListName!, fromFile: inputURL.path)
        
        colorList.writeToFile(nil)
        
        contents = []
        
        for key in colorList.allKeys {
            let key = key as String
            let color: NSColor! = colorList.colorWithKey(key)
        
            if(color.colorSpaceName != NSCalibratedRGBColorSpace) {
                println("Color \(key) isn't generic calibrated RGB. Skipping.")
                continue
            }
            
            let returnColor = String(format: "    return UIColor(red: %.3f, green: %.3f, blue: %.3f, alpha: %.3f)\n", Double(color.redComponent), Double(color.greenComponent), Double(color.blueComponent), Double(color.alphaComponent))
            
            var method = "class func \(methodNameForKey(key))Color() -> UIColor {\n"
            method += "\(returnColor)"
            method += "}\n"
            contents.append(method)
        }
        
        writeOutputFiles()
        completionClosure()
    }
    
    override class func inputFileExtension() -> String {
        return "clr"
    }
    
}