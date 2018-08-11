//
//  CoreDataService.swift
//  SehajBani
//
//  Created by Jasmeet on 04/02/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//


import Foundation
import CoreData
import SwiftyJSON

class CoreDataService {
    
    private init() {}
    
    private static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    
    private static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SehajBani")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    static func updateLoginSource(_ source: String) {
        if let userEntity = getLogin() {
            userEntity.loginSource = source
            saveContext()
        }
    }
    
    static func updatePersonalInfo(firstName: String, lastName: String, accountId: String, username: String, loginSource: String) {
    
        if let userEntity = getLogin() {
            userEntity.firstName = firstName
            userEntity.lastName = lastName
            userEntity.accountId = accountId
            userEntity.username = username
            userEntity.loginSource = loginSource
            saveContext()
        }
    }
    
  
    
    static func deleteLogin() {
        
        let loginFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        deleteAll(loginFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
    }
    
    static func saveLogin(_ username: String, loginSource: String) {
        
        // Deleting previous record:
        deleteLogin()
        let userEntity = UserEntity(context: context)
        userEntity.username = username
        saveContext()
        
        if let _ = getLogin() {
            updateLoginSource(loginSource)
        }
        
    }
    static func isGuestUser() -> Bool {
        if let _ = getLogin() {
            return false
        }
        return true
    }
  
    static func getLogin() -> UserEntity? {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let loginEntities = try CoreDataService.context.fetch(fetchRequest)
            if loginEntities.count > 0 {
            return loginEntities.first!
            }
            return nil
        } catch {
            print("Core Data reading login error: \(error)")
        }
        return nil
    }
    
    
    static func getStringArrayFromLoginObject(_ result: JSON,_ objectAttribute: String) -> [String] {
        if let arr = result["object"][objectAttribute].array {
            if arr.count > 0 {
                return arr.map { $0.stringValue }
            }
        }
        return [String]()
    }
    
    static func getURLArrayFromLoginObject(_ result: JSON,_ objectAttribute: String) -> [URL] {
        if let arr = result["object"][objectAttribute].array {
            if arr.count > 0 {
                return arr.map { $0.url! }
            }
        }
        return [URL]()
    }
    
    static func getStringFromLoginObject(_ result: JSON,_ objectAttribute: String) -> String {
        return result["user"][objectAttribute].string ?? ""
    }
    
    static func getInt64FromLoginObject(_ result: JSON,_ objectAttribute: String) -> Int64 {
        return result["object"][objectAttribute].int64 ?? 0
    }
    
    static func getFloatFromLoginObject(_ result: JSON,_ objectAttribute: String) -> Float {
        return result["object"][objectAttribute].float ?? 0
    }
    
    static func getBoolFromLoginObject(_ result: JSON,_ objectAttribute: String) -> Bool {
        return result["object"][objectAttribute].bool ?? false
    }
    
    static func deleteAll(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            print("Core Data batch delete error: \(error) in req: \(fetchRequest)")
        }
    }
    
    static func accountId() -> String? {
        if let loginEntity = getLogin() {
            return loginEntity.accountId
        }
        return ""
    }
}



