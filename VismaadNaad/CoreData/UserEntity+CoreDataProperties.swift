//
//  UserEntity+CoreDataProperties.swift
//  
//
//  Created by Jasmeet Singh on 06/06/18.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var username: String?
    @NSManaged public var accountId: String?
    @NSManaged public var loginSource: String?

}
