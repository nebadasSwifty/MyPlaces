//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Кирилл on 10.05.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}


class MapViewController: UIViewController {
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var incomeSegueIdentifier = ""
    var place = Place()
    let annotationIdentifier = "Annotation"
    let locationManager = CLLocationManager()
    var placeCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var distanceToPlace: UILabel!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var currentAddressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentAddressLabel.text = "Уточняем.."
        setupMapView()
        checkLocationServices()
    }
    @IBAction func centerViewForUserLocation() {
        showUserLocation()
    }
    @IBAction func closeMap(_ sender: UIButton) {
        dismiss(animated: true)
    }
    private func setupMapView() {
        goButton.isHidden = true
        distanceToPlace.isHidden = true
        if incomeSegueIdentifier == "showPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            currentAddressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            distanceToPlace.isHidden = false
        }
    }
    @IBAction func goButtonPressed() {
        getDirections()
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        mapViewControllerDelegate?.getAddress(currentAddressLabel.text)
        dismiss(animated: true)
    }
    
    private func getDirections() {
        guard let location = locationManager.location?.coordinate else { return alertLocationDisabled() }
        guard let request = createDirectionsRequest(from: location) else { return alertLocationDisabled() }
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error { print(error) }
            guard let response = response else { self.alertLocationDisabled()
                return
            }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 3600)
                
                self.distanceToPlace.text = "Расстояние до места: \(distance) км\nВремя в пути составит: \(timeInterval) ч"
                
                print("Расстояние до места: \(distance) км")
                print("Время в пути составит: \(timeInterval) сек")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func setupPlaceMark() {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuth()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocationDisabled()
            }
        }
    }
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    private func checkLocationAuth() {
        let authorizationStatus = locationManager.authorizationStatus
        switch authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocationDisabled()
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocationDisabled()
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    private func alertLocationDisabled() {
        let alert = UIAlertController(title: "Предупреждение", message: "Необходимо включить службы геолокации", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showUserLocation() {
        let latitudinalMeters = 1000.00
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: latitudinalMeters, longitudinalMeters: latitudinalMeters)
            mapView.setRegion(region, animated: true)
        }
    }
}


//MARK: - Map view delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                self.currentAddressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.currentAddressLabel.text = "\(streetName!)"
                } else {
                    self.currentAddressLabel.text = "Уточняем.."
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
}
