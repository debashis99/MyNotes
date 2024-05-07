//
//  User+CoreDataProperties.swift
//  MyNotes
//
//  Created by Employee on 07/05/24.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userId: String!
    @NSManaged public var userName: String!
    @NSManaged public var key: Data!
    @NSManaged public var token: String!
    

}

extension User : Identifiable {

}
