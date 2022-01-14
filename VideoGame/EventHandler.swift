//
//  EventHandler.swift
//  VideoGame
//
//  Created by Roman Bobelyuk on 11.01.2022.
//

import Foundation
import CoreLocation
import CoreMotion
import UIKit

protocol EventHandlerDelegate: AnyObject {
    func didChangeLocation()
    func didRotateDeviceByX(acceleration: Float)
    func didRotateDeviceByZ(acceleration: Float)
}

// This class doing a lot of things, in real life project CLLocationManager and CMMotionManager will be separate classes which will trigger callback results here
class EventHandler: UIResponder {
    var locationManager: CLLocationManager
    var motionManager: CMMotionManager
    var previousLocation: CLLocation?

    weak var delegate: EventHandlerDelegate?

    init(locationManager: CLLocationManager, motionManager: CMMotionManager) {
        self.locationManager = locationManager
        self.motionManager = motionManager
        super.init()
    }
    func startTracking() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .other
        locationManager.requestWhenInUseAuthorization()
        startGyros()
    }

    func startGyros() {
        guard motionManager.isGyroAvailable else { return }
        let accelerationThreshold = 0.3

        motionManager.gyroUpdateInterval = 1.0 / 60.0
        motionManager.startGyroUpdates(to: OperationQueue()) { gyroData, error in
            guard let gyroData = gyroData else { return }
            let x = gyroData.rotationRate.x
            let y = gyroData.rotationRate.y
            let z = gyroData.rotationRate.z
            if fabs(z) > accelerationThreshold && fabs(x) < accelerationThreshold {
                print("CMMotionManager found .z rotation \(z)")
                self.delegate?.didRotateDeviceByZ(acceleration: Float(z))
            }
            if fabs(x) > accelerationThreshold && fabs(z) < accelerationThreshold {
                print("CMMotionManager found .x rotation \(x)")
                self.delegate?.didRotateDeviceByX(acceleration: Float(x))
            }
            if fabs(y) > accelerationThreshold {
                print("CMMotionManager found .y rotation \(y)")
            }
        }
    }

    deinit {
        motionManager.stopGyroUpdates()
        locationManager.stopUpdatingLocation()
    }

}

extension EventHandler: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        if previousLocation == nil {
            let region = CLCircularRegion(center: newLocation.coordinate, radius: 10, identifier: "10MetersRegion")
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
            previousLocation = newLocation
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.didChangeLocation()
        previousLocation = nil
    }

}
