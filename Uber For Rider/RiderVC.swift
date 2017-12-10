//
//  RiderVC.swift
//  Uber For Rider
//
//  Created by Shreyash Kawalkar on 09/12/17.
//  Copyright © 2017 Sk. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
    
    
    @IBOutlet weak var myMap: MKMapView!
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    private var timer = Timer()
    
    private var canCallUber = true
    private var riderCanceledRequest = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UberHandler.instance.delegate = self
        UberHandler.instance.observerMessagesForRider()
        initializeLocationManager()
    }
    
    
    @IBOutlet weak var callUberBtn: UIButton!
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled{
        callUberBtn.setTitle("Cancel Uber", for: UIControlState.normal)
        canCallUber = false
        }else{
        callUberBtn.setTitle("Call Uber", for: UIControlState.normal)
        canCallUber = true
        }
    }
    private func initializeLocationManager(){
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region =  MKCoordinateRegionMake(userLocation!, MKCoordinateSpanMake(0.01, 0.01))
            myMap.setRegion(region, animated: true)
            myMap.removeAnnotations(myMap.annotations)
            
            if driverLocation != nil{
                let annotation = MKPointAnnotation();
                annotation.coordinate = driverLocation!
                annotation.title = "Driver Location"
                myMap.addAnnotation(annotation)
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!
            annotation.title = "Rider Location"
            myMap.addAnnotation(annotation)
        
        }
        
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func updateRidersLocation(lat: Double, long: Double){
        UberHandler.instance.updateRidersLocation(lat: (userLocation?.latitude)!, long: (userLocation?.longitude)!)
        
    }
    
    
    @IBAction func logout(_ sender: Any) {
        if AuthProviders.instance.logOut(){
            if !canCallUber{
            timer.invalidate()
                UberHandler.instance.cancelUber()
            }
            dismiss(animated: true, completion: nil)
        }
        else{
         alertTheUser(title: "Could Not LogOut", message: "Account didn't logout try again!!!")
        }
    }
    
    
    @IBAction func callUber(_ sender: Any) {
        if userLocation != nil{
            if canCallUber{
                
                self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(RiderVC.updateRidersLocation),userInfo: nil ,repeats: true)
        UberHandler.instance.requestUber(latitude: (userLocation?.latitude)!, longitude: (userLocation?.longitude)!)
            }
            else {
            riderCanceledRequest = true
                timer.invalidate()
            UberHandler.instance.cancelUber()
            }
        }
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        if !riderCanceledRequest{
            if requestAccepted{
            alertTheUser(title: "Uber Accepted", message: "\(driverName) accepted your Uber request")
            }
            else{
                timer.invalidate()
                UberHandler.instance.cancelUber()
                alertTheUser(title: "Uber Canceled", message: "\(driverName) cancled Uber request")
            }
        }
    }
    
    func alertTheUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title : "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
