//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Кирилл on 09.05.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write{
            realm.add(place)
        }
    }
    static func removeObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
