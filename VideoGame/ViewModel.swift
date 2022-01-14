//
//  ViewModel.swift
//  VideoGame
//
//  Created by Roman Bobelyuk on 11.01.2022.
//

import Foundation

protocol ViewModelDelegate: AnyObject {
    func didReceive(event: MoveEvent)
}

enum MoveEvent {
    case volumeChange(Float)
    case videoStateChange(Float)
    case locationChanged
}

class ViewModel {
    var eventHandler: EventHandler
    weak var delegate: ViewModelDelegate?
    init(eventHandler: EventHandler) {
        self.eventHandler = eventHandler
        self.eventHandler.delegate = self
        self.eventHandler.startTracking()
    }
}

extension ViewModel: EventHandlerDelegate {
    func didChangeLocation() {
        delegate?.didReceive(event: .locationChanged)
    }
    
    func didRotateDeviceByZ(acceleration: Float) {
        let moveThreshold: Float = 0.06
        if abs(acceleration) > moveThreshold {
            let seekIncreaceValue: Float = 0.10
            let convertedAcceleration = acceleration.sign == .minus ? acceleration - seekIncreaceValue : acceleration + seekIncreaceValue
            delegate?.didReceive(event: .videoStateChange(convertedAcceleration))
        }
    }

    func didRotateDeviceByX(acceleration: Float) {
        let convertedAcceleration = acceleration/10
        delegate?.didReceive(event: .volumeChange(convertedAcceleration))
    }

}


