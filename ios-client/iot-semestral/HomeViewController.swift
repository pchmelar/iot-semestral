//
//  HomeViewController.swift
//  iot-semestral
//
//  Created by filletzz on 07/05/16.
//  Copyright © 2016 pchmelar. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import Starscream
import SwiftyJSON
import CoreLocation

class HomeViewController: UIViewController {
  
  let img = UIImageView()
  let button = UIButton(type: UIButtonType.System)
  let indicator = UILabel()
  
  var locationManager = CLLocationManager()
  var beaconRegion = CLBeaconRegion()
  
  //init WebSocket
  let lightSocket = LightSocket(socket: WebSocket(url: NSURL(string: "ws://192.168.2.100:8888")!))

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Light Switch"
    
    //listen for notification
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateView), name:"websocketUpdate", object: nil)
    
    //-------------iBeacon-------------
    
    //init location manager and set ourselves as the delegate
    locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    
    //create a NSUUID with the same UUID as the broadcasting beacon
    let uuid = NSUUID(UUIDString: "e20a39f4-73f5-4bc4-a12f-17d1ad07a961")
    
    //setup a new region with that UUID and same identifier as the broadcasting beacon
    beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "Apple")
    
    //tell location manager to start monitoring for the beacon region
    locationManager.startMonitoringForRegion(beaconRegion)
    
    //---------------------------------
    
    //add background
    let bg = UIImageView()
    bg.image = UIImage(named: "bg.png")
    bg.contentMode = .ScaleAspectFill
    self.view.addSubview(bg)
    bg.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self.view)
    }
    
    //add iBeacon proximity indicator
    indicator.backgroundColor = UIColor.whiteColor()
    indicator.textColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
    indicator.layer.cornerRadius = 5
    indicator.layer.masksToBounds = true
    indicator.textAlignment = .Center
    indicator.text = "iBeacon proximity: unknown"
    self.view.addSubview(indicator)
    indicator.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(self.view.snp_right).offset(-20)
      make.bottom.equalTo(self.view.snp_bottom).offset(-50)
      make.left.equalTo(self.view.snp_left).offset(20)
      make.height.equalTo(50)
    }
    
    //add button
    button.backgroundColor = UIColor.whiteColor()
    button.layer.cornerRadius = 5
    button.layer.masksToBounds = true
    button.setTitle("Turn on", forState: UIControlState.Normal)
    button.addTarget(self, action: #selector(HomeViewController.buttonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(button)
    button.snp_makeConstraints { (make) -> Void in
      make.right.equalTo(self.view.snp_right).offset(-20)
      make.bottom.equalTo(indicator.snp_top).offset(-10)
      make.left.equalTo(self.view.snp_left).offset(20)
      make.height.equalTo(50)
    }
    
    //add image
    img.image = UIImage(named: "off.png")
    img.contentMode = .ScaleAspectFit
    self.view.addSubview(img)
    img.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(self.view.snp_top).offset(80)
      make.right.equalTo(self.view.snp_right).offset(-20)
      make.bottom.equalTo(button.snp_top).offset(-20)
      make.left.equalTo(self.view.snp_left).offset(20)
    }
  }
  
  func updateView(){
    if lightSocket.light == false {
      img.image = UIImage(named: "off.png")
      button.setTitle("Turn on", forState: UIControlState.Normal)
    } else {
      img.image = UIImage(named: "on.png")
      button.setTitle("Turn off", forState: UIControlState.Normal)
    }
  }
  
  func buttonAction(sender:UIButton!) {
    if lightSocket.light == false {
      lightSocket.light = true
    } else {
      lightSocket.light = false
    }
    sendData()
  }
  
  func sendData() {
    let headers = [
      "Content-Type": "application/json;charset=UTF-8"
    ]
    let data = [
      "val": lightSocket.light
    ]
    Alamofire.request(.PUT, "http://192.168.2.100:8080/light", headers: headers, parameters: data, encoding: .JSON)
  }

}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
  
  func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
    locationManager.startRangingBeaconsInRegion(beaconRegion)
  }
  
  func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
    locationManager.stopRangingBeaconsInRegion(beaconRegion)
  }
  
  func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
    // If we wake up and find we’re already in a region, start ranging
    if region.isEqual(beaconRegion) && state == .Inside {
      locationManager.startRangingBeaconsInRegion((region as! CLBeaconRegion))
    }
  }
  
  func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
    if (beacons.count > 0){
      let closestBeacon: CLBeacon = beacons[0]
      print("Beacon found! UUID: \(closestBeacon.proximityUUID.UUIDString), major: \(closestBeacon.major), minor: \(closestBeacon.minor)")
      
      if closestBeacon.proximity == .Unknown {
        print("Proximity: unknown \(round(1000*closestBeacon.accuracy)/1000)")
        indicator.text = "iBeacon proximity: unknown (\(round(1000*closestBeacon.accuracy)/1000)m)"
      } else if closestBeacon.proximity == .Immediate {
        print("Proximity: immediate \(round(1000*closestBeacon.accuracy)/1000)")
        indicator.text = "iBeacon proximity: immediate (\(round(1000*closestBeacon.accuracy)/1000)m)"
        if lightSocket.light == false && lightSocket.ibeacon == false {
          lightSocket.light = true
          lightSocket.ibeacon = true
          sendData()
        }
      } else if closestBeacon.proximity == .Near {
        print("Proximity: near \(round(1000*closestBeacon.accuracy)/1000)")
        indicator.text = "iBeacon proximity: near (\(round(1000*closestBeacon.accuracy)/1000)m)"
        if lightSocket.light == true && lightSocket.ibeacon == true {
          lightSocket.light = false
          lightSocket.ibeacon = false
          sendData()
        }
      } else if closestBeacon.proximity == .Far {
        print("Proximity: far \(round(1000*closestBeacon.accuracy)/1000)")
        indicator.text = "iBeacon proximity: far (\(round(1000*closestBeacon.accuracy)/1000)m)"
        if lightSocket.light == true && lightSocket.ibeacon == true {
          lightSocket.light = false
          lightSocket.ibeacon = false
          sendData()
        }
      }
    }
  }
  
  func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
    print("Failed monitoring region: \(error)")
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Location manager failed: \(error)")
  }
  
}
