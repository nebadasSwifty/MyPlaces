//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Кирилл on 09.05.2022.
//

import Foundation
import UIKit


struct Place {
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    
    static let restarauntNames = ["NEBAR", "New Bar", "Alibi",
                        "Бла бла бар", "AIR", "Гастроли",
                           "А ты где?", "Свой бар", "Негодяи"]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        for place in restarauntNames {
            places.append(Place(name: place, location: "Екатеринбург", type: "Бар", image: nil, restaurantImage: place))
        }
        
        return places
    }
}
