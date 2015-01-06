//
//  functions.swift
//  codegenutils
//
//  Created by Tadeas Kriz on 06/01/15.
//  Copyright (c) 2015 Brightify. All rights reserved.
//

import Foundation

func synchronized(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

func wholeStringRange(string: String) -> Range<String.Index> {
    return Range<String.Index>(start: string.startIndex, end: string.endIndex)
}
