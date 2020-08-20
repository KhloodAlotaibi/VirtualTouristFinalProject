//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Khlood on 7/30/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var myMapView: MKMapView!
    
    var dataController:DataController!
    var annotations = [MKPointAnnotation]()
    var annotation = MKPointAnnotation()
    var pins: [Pin] = []
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        myMapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        myMapView.addGestureRecognizer(gestureRecognizer)
        myMapView.removeAnnotations(myMapView.annotations)
        pins = fetch()
        if pins.count > 0 {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                myMapView.addAnnotation(annotation)
            }
        }
    }
    
    @objc func addAnnotation(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == .began {
            let location = gestureReconizer.location(in: myMapView)
            let coords = myMapView.convert(location, toCoordinateFrom: myMapView)
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coords.latitude
            pin.longitude = coords.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            myMapView.addAnnotation(annotation)
            try? dataController.viewContext.save()
            pins.append(pin)
            myMapView.reloadInputViews()
        }
    }
 
    func fetch() -> [Pin] {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            pins = result
        } catch {
             print("error")
        }
        return pins
    }
    
    @IBAction func myDeletePinsButtonClicked(_ sender: Any) {
        for pin in pins  {
            dataController.viewContext.delete(pin)
        }
        let annotations = myMapView.annotations
        myMapView.removeAnnotations(annotations)
        try? dataController.viewContext.save()
        showAlert(title: "Done", message: "All pins have been deleted successfully")
    }
    
    @IBAction func myHelpButtonClicked(_ sender: Any) {
        showAlert(title: "Welcome! Enjoy!", message: "Tap and hold to drop a pin. Then click on that pin to show the pictures")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension TravelLocationsMapViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        myMapView.deselectAnnotation(view.annotation, animated: true)
        let controller = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        let lat = view.annotation?.coordinate.latitude
        let lon = view.annotation?.coordinate.longitude
        controller.lat = view.annotation?.coordinate.latitude ?? 0.0
        controller.lon = view.annotation?.coordinate.longitude ?? 0.0
        for pin in pins {
            if pin.latitude == lat && pin.longitude == lon {
                    controller.pin = pin
            }
        }
        controller.dataController = dataController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
