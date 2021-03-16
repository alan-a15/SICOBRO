//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import GoogleMaps

class FindStoreViewController: ZorroAbstracUIViewController, CLLocationManagerDelegate {
    
    private let geoUrl = "geolocalizacion"
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private var mapView: GMSMapView = GMSMapView()
    
    private var locationTimesRequested: Int = 0
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton(backButton)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        let camera = GMSCameraPosition.camera(withLatitude: 19.432870, longitude: -99.133338, zoom: 10.0)
        
        let frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        
        mapView = GMSMapView.map(withFrame: frame, camera: camera)
        contentView.addSubview(mapView)
        
        mapView.isMyLocationEnabled = true;
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        } else {
            loadGeolocalizaciones()
        }
    }
    
    func loadGeolocalizaciones(location: CLLocation? = nil) {
        let url = location == nil ? geoUrl : "\(geoUrl)/\(location!.coordinate.latitude)/\(location!.coordinate.longitude)/"
        print(url)
        HttpRequest.httpGet(url, success: { (response) -> Void in
            self.mapView.clear()
            
            let geolocalizaciones = try! JSONDecoder().decode([Geolocalizacion].self, from: Data(response.utf8))
            
            print(geolocalizaciones)
            
            geolocalizaciones.forEach {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: $0.latitud, longitude: $0.longitud)
                marker.title = $0.nombre
                // marker.snippet = "Zorro"
                marker.map = self.mapView
            }
        }, failure: { (code, response) -> Void in
            // TODO: implement
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        print("Location request: \(locationTimesRequested)")
        
        locationTimesRequested += 1
        
        if locationTimesRequested >= 2 {
            loadGeolocalizaciones(location: userLocation)
            manager.stopUpdatingLocation()
        }
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let camera = GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 13.0))
        
        mapView.moveCamera(camera)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location Error: \(error)")
    }
}
