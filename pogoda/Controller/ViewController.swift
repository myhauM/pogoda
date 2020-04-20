//
//  ViewController.swift
//  pogoda
//
//  Created by Michał Massloch on 07/04/2020.
//  Copyright © 2020 Michał Massloch. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, ManagerPogodyDelegate {
    
    let managerLokalizacji = CLLocationManager()
    var managerPogody = ManagerPogody()
    
    @IBOutlet weak var miastoLabelAlamofire: UILabel!
    @IBOutlet weak var temperaturaAlamofire: UILabel!
    @IBOutlet weak var pogodaImageAlamofire: UIImageView!
    @IBOutlet weak var warunkiLabelAlamofire: UILabel!
    
    @IBOutlet weak var miastoLabelURLSession: UILabel!
    @IBOutlet weak var temperaturaURLSession: UILabel!
    @IBOutlet weak var pogodaImageURLSession: UIImageView!
    @IBOutlet weak var warunkiLabelURLSession: UILabel!
    
    @IBOutlet weak var alamofireView: UIView!
    @IBOutlet weak var urlsessionView: UIView!
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var szukajTextField: UITextField!
    
    @IBAction func szukajPressed(_ sender: UIButton) {
        koniecWpisywania()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        szukajTextField.delegate = self
        managerLokalizacji.delegate = self
        managerPogody.delegate = self
        managerLokalizacji.desiredAccuracy = kCLLocationAccuracyHundredMeters
        managerLokalizacji.requestWhenInUseAuthorization()
        managerLokalizacji.startUpdatingLocation()
        detailsView.layer.cornerRadius = 5
        detailsView.layer.masksToBounds = true
        alamofireView.layer.cornerRadius = 5
        alamofireView.layer.masksToBounds = true
        urlsessionView.layer.cornerRadius = 5
        urlsessionView.layer.masksToBounds = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        szukajTextField.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }
        else {
            textField.placeholder = "Wpisz miasto"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        koniecWpisywania()
        szukajTextField.text = ""
    }
    
    
    
    func didUpdateWeather(_ weatherManager: ManagerPogody, weather: ModelPogody) {
        print("func didUpdateWeather in VC")
        DispatchQueue.main.async {
            print("didUpdateWeather - DispatchQueue")
            self.miastoLabelAlamofire.text = weather.nazwaMiasta
            let temperatura = String(format: "%.1f", weather.temperatura)
            self.temperaturaAlamofire.text = ("\(temperatura)°C")
            print("\(temperatura)°C")
            self.pogodaImageAlamofire.image = UIImage(systemName: weather.nazwaWarunkow)
            self.warunkiLabelAlamofire.text = weather.opis
        }
    }
    
    func didFailedWithError(error: Error) {
        print("error")
    }
    
    func koniecWpisywania() {
        if let miasto = szukajTextField.text {
            let miastoBezZnakow = miasto.folding(options: .diacriticInsensitive, locale: .autoupdatingCurrent)
            let miastoBezl = miastoBezZnakow.replacingOccurrences(of: "ł", with: "l")
            let miastoBezL = miastoBezl.replacingOccurrences(of: "Ł", with: "L")
            managerPogody.formatZapytania(nazwaMiasta: miastoBezL)
            print("textFieldDidEndEditing with \(miastoBezL)")
            
        }
    }
    
    func getWeatherData(urlString: String) {
        print("getWeatherData")
        AF.request(urlString, method: .get).responseJSON {
            response in
            print("Operacja zakończona sukcesem!")
            switch response.result {
            case let .success(owmResponse):
                print(owmResponse)
                self.updateWeatherData(json: JSON(owmResponse))
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func updateWeatherData(json: JSON) {
        if let temperatura =  json["main"]["temp"].double {
            let miasto = json["name"].string
            let description = json ["weather"][0]["description"].string
            print(temperatura)
            miastoLabelURLSession.text = String(miasto ?? "Błąd pobierania miasta")
            warunkiLabelURLSession.text = String(description ?? "Błąd opisu")
            
            let tempZC = String(format: "%.1f", temperatura)
            
            temperaturaURLSession.text = "\(tempZC)°C"
        }
        else {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager")
        let weatherURL = linkDoApi.adres
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            managerLokalizacji.stopUpdatingLocation()
            print("lon = \(location.coordinate.longitude), lat = \(location.coordinate.latitude)")
            let lon = String(location.coordinate.longitude)
            let lat = String(location.coordinate.latitude)
            let urlStringForLocation = ("\(weatherURL)&lat=\(lat)&lon=\(lon)")
            print(urlStringForLocation)
            getWeatherData(urlString: urlStringForLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        miastoLabelURLSession.text = "Błąd lokalizacji"
    }
    
    
    
}

