//
//  ViewController.swift
//  VideoGame
//
//  Created by Roman Bobelyuk on 10.01.2022.
//

import UIKit
import AVKit
import AVFoundation
import CoreLocation
import CoreMotion

class ViewController: UIViewController {
    private var player: AVPlayer?
    private var paused = false
    
    // ViewModel should be created/property injected in Coordinator class
    let viewModel = ViewModel(eventHandler: EventHandler(locationManager: CLLocationManager(), motionManager: CMMotionManager()))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4") else { return }

        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player?.play()
        viewModel.delegate = self
    }

    // Shake motion can't be tracked outsied view controller, ideally it should be in EventHandler with other events
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake {
            print("Shake gesture detected")
            paused.toggle()
            paused ? player?.pause() : player?.play()
        }
    }
}

extension ViewController: ViewModelDelegate {
    func didReceive(event: MoveEvent) {
        guard let player = player else { return }
        switch event {
        case .videoStateChange(let convertedAcceleration):
            print("before CMTime - \(player.currentTime())")
            let timetoAdd = CMTimeMakeWithSeconds(Float64(convertedAcceleration), preferredTimescale: 24000)
            let finalTime = CMTimeAdd((player.currentTime()), timetoAdd)
            print("final CMTime - \(finalTime)")
            player.seek(to: finalTime)
        case .volumeChange(let convertedAcceleration):
            let newVolume = Float(convertedAcceleration)
            print("volume before - \(player.volume)")
            player.volume += newVolume
            print("volume after - \(player.volume)")
        case .locationChanged:
            print("locationChanged")
            player.seek(to: .zero)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
