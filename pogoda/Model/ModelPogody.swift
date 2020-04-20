//
//  ModelPogody.swift
//  pogoda
//
//  Created by Michał Massloch on 08/04/2020.
//  Copyright © 2020 Michał Massloch. All rights reserved.
//

import Foundation

struct ModelPogody {
    
    var temperatura: Double
    var warunki: Int
    var nazwaMiasta: String
    var opis: String
    
    var nazwaWarunkow: String {
        
        switch warunki {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "sun.haze"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud"
        default:
            return "cloud"
        }
    }
    
    
}
