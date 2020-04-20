//
//  ManagerPogody.swift
//  pogoda
//
//  Created by Michał Massloch on 14/04/2020.
//  Copyright © 2020 Michał Massloch. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol ManagerPogodyDelegate {
    func didUpdateWeather(_ weatherManager: ManagerPogody, weather: ModelPogody)
    func didFailedWithError(error: Error)
}

struct ManagerPogody {
    
    var pogoda: ModelPogody?
    
    let weatherURL = linkDoApi.adres
    /* 
     class LinkDoAPI {
     var adres:String
     init(adres:String) {
     self.adres = adres
     }
     }
     
     var linkDoApi = LinkDoAPI(adres:"{ADRES}")
     
     */
    var delegate: ManagerPogodyDelegate?
    func formatZapytania(nazwaMiasta: String) {
        let urlString = "\(weatherURL)&q=\(nazwaMiasta)"
        pobierzPogodeAF(urlString: urlString)
    }
    
    func pobierzPogodeAF(urlString: String) {
        AF.request(urlString, method: .get).responseJSON {
            response in
            print("Operacja zakończona sukcesem!")
            switch response.result {
            case let .success(value):
                let json = JSON(value)
                print("JSON: \(json)")
                let pogoda = self.aktualizacjaDanychAF(json: json)
                self.delegate?.didUpdateWeather(self, weather: pogoda ?? ModelPogody(temperatura: 0.0, warunki: 0, nazwaMiasta: "Błąd", opis: "Błąd"))
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func aktualizacjaDanychAF(json: JSON) -> ModelPogody? {
        if let name = json["name"].string {
            let temp =  json["main"]["temp"].double
            let id = json["weather"][0]["id"].int ?? 1
            let desc = json["weather"][0]["description"].string
            print("Temperatura w \(name) to \(temp!), warunki: \(desc ?? "no description") ")
            let pogoda = ModelPogody(temperatura: temp ?? 0.0, warunki: id, nazwaMiasta: name, opis: desc ?? "")
            print(pogoda)
            return pogoda
        }
        else {
            self.delegate?.didFailedWithError(error: Error.self as! Error)
            return nil
        }
    }
    
    func getWeatherData(url: String, parameters : [String:String]){
        AF.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            //if response {
            print("Operacja zakończona sukcesem!")
            switch response.result {
            case let .success(value):
                print("VALUE Z LOKALIZACJI TELEFONU")
                print(value)
                
            case let .failure(error):
                print(error)
            }
        }
    }
}
