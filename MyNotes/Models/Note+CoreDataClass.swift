//
//  Note+CoreDataClass.swift
//  MyNotes
//
//  Created by Employee on 06/05/24.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    var title: String {
        return text?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).first ?? "" // returns the first line of the text
    }
    
    var desc: String {
        var lines = text?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        lines?.removeFirst()
        return "\(lastUpdated?.format()) \(lines?.first ?? "")" // return second line
    }
    
}
