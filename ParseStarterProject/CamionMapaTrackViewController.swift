//
//  CamionMapaTrackViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Pedro Alonso on 23/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit

class CamionMapaTrackViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapaDeRuta: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var userNow: PFUser!
    

    var manager: CLLocationManager!
    var lastLocationInRoute: CLLocation!
    var startFromBus: CLLocation!
    var locationOfUser: CLLocation!
    
    var timerToUpdateLocationOfBus: NSTimer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("Usuario de mapa \(userNow)")
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //set up map
        mapaDeRuta.delegate = self
        mapaDeRuta.mapType = MKMapType.Standard
        mapaDeRuta.showsUserLocation = true
        
        if #available(iOS 9.0, *) {
            mapaDeRuta.showsTraffic = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            mapaDeRuta.showsScale = true
        } else {
            // Fallback on earlier versions
        }
        mapaDeRuta.showsBuildings = true
        
        timerToUpdateLocationOfBus = NSTimer.scheduledTimerWithTimeInterval(7, target: self, selector: "getDataFromBus:", userInfo: nil, repeats: true)
        
        let busDriveNow = PFQuery(className: "Route")
        
        busDriveNow.getFirstObjectInBackgroundWithBlock {
            
            (object: PFObject?, error: NSError?) -> Void in
            
            if error == nil {
                
                print((object!["start"] as! PFGeoPoint).latitude)
                
                self.startFromBus = CLLocation(latitude: (object!["start"] as! PFGeoPoint).latitude, longitude: (object!["start"] as! PFGeoPoint).longitude)
                print("location \(self.startFromBus)")
                
            } else {
                
                print("function getDataFromBus \(error)")
            }
        }

        
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print(" error en el locationmanager \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("updating...")
        locationOfUser = locations[0]
        
        let spanX = 0.035
        let spanY = 0.035
        let newRegion = MKCoordinateRegion(center: locationOfUser.coordinate , span: MKCoordinateSpanMake(spanX, spanY))
        
        mapaDeRuta.setRegion(newRegion, animated: true)
        
    }

    // MARK: MKMapViewdelegates
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = UIColor.redColor()
            polylineRender.lineWidth = 4
            
            return polylineRender
        }
        
        return MKPolylineRenderer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getDataFromBus(timer: NSTimer) {
        
        print("Executoing timer func")
        
        if lastLocationInRoute != nil || startFromBus != nil {
            
            print("yup lastlocationis not nil or something is nil still")
        } else {
            
            print("Nope last location still is nil")
        }
        
        let lastPointUntilNow = PFQuery(className: "Route")
        
        lastPointUntilNow.orderByDescending("createdAt")
        
        do {
            
            let gettingObject = try lastPointUntilNow.getFirstObject()
            
            lastLocationInRoute = CLLocation(latitude: (gettingObject["start"] as! PFGeoPoint).latitude, longitude: (gettingObject["start"] as! PFGeoPoint).longitude)
            
            
            
        } catch let error {
            
            print(" error in last point in route \(error)")
        }
        
        sleep(2)
        
        showBusRoute()
    }
    
    func showBusRoute() {
    
        
        
        let c1 = startFromBus.coordinate
        let c2 = lastLocationInRoute.coordinate
        
        var a = [c1, c2]
        
        let polyline = MKPolyline(coordinates: &a, count: a.count)
        
        mapaDeRuta.addOverlay(polyline)
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
