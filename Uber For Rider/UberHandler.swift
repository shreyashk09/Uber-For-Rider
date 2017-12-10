//
//  UberHandler.swift
//  Uber For Rider
//
//  Created by Shreyash Kawalkar on 09/12/17.
//  Copyright © 2017 Sk. All rights reserved.
//

import Foundation
import FirebaseDatabase
protocol UberController: class{
    func canCallUber(delegateCalled: Bool)
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String)
    func updateDriversLocation(lat: Double, long: Double)
}
class UberHandler{

    private static let inst = UberHandler()
    weak var delegate: UberController?
    var rider = ""
    var driver = ""
    var rider_id = ""
    
    
    static var instance: UberHandler{return inst}
    func observerMessagesForRider(){
        DBProvider.instance.requestRef.observe(DataEventType.childAdded, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                    self.rider_id = snapshot.key
                    self.delegate?.canCallUber(delegateCalled: true)
                    }
                }
            }
        })
        
        DBProvider.instance.requestRef.observe(DataEventType.childRemoved, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                    
                        self.delegate?.canCallUber(delegateCalled: false)
                    }
                }
            }
        })
        
        DBProvider.instance.requestAcceptedRef.observe(DataEventType.childAdded, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if self.driver == ""{
                        self.driver = name
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver)
                    }
                }
            }
        })
        
        DBProvider.instance.requestAcceptedRef.observe(DataEventType.childRemoved, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver {
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                    }
                }
            }
        })

        
        //getting driver's location
        DBProvider.instance.requestAcceptedRef.observe(DataEventType.childChanged, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver {
                        if let lat = data[Constants.LATITUDE] as? Double{
                            if let long = data[Constants.LONGITUDE] as? Double{
                                self.delegate?.updateDriversLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
            }
        })
        
    }
    
    
    func requestUber(latitude: Double, longitude: Double){
        let data: Dictionary<String, Any> = [Constants.NAME: rider, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude]
        DBProvider.instance.requestRef.childByAutoId().setValue(data)
    }
    
    func cancelUber(){
    DBProvider.instance.requestRef.child(rider_id).removeValue()
    }
    
    func updateRidersLocation(lat: Double, long: Double){
        DBProvider.instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])

    }
    
}
