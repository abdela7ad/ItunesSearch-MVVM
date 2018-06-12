//
//  ISAudioPlayer.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/12/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


protocol ISAudioPlayerDelegate:class {
    
    
    /// Manage start and end time labels
    ///
    /// - Parameters:
    ///   - audioPlayer: Audio player
    ///   - time: startTime of slider
    ///   - endTime: end time of slider - start time
    func audioPlayer(_ audioPlayer: ISAudioPlayer, didUpdateProgressionTo time: TimeInterval, endTime: TimeInterval)
    
    
    /// Manage state of player playing,  puase ...etc
    ///
    /// - Parameters:
    ///   - audioPlayer: Audio player
    ///   - state: state Enum
    func audioPlayer(_ audioPlayer: ISAudioPlayer, didChangeState  state: AudioPlayerState)
    
    
    /// Duration deetction after read time
    ///
    /// - Parameters:
    ///   - audioPlayer: Audio player
    ///   - duration: Duration
    func audioPlayer(_ audioPlayer: ISAudioPlayer, didSetDuration duration:Float)

    
}
public enum AudioPlayerState {
    case buffering
    case playing
    case paused
    case stopped
}



class ISAudioPlayer :NSObject{
    
    // Singlition Player to only play one track at time
    
    static let  shared = ISAudioPlayer()
    
    
    // create player object
    private var player:AVPlayer?{
        didSet {
            player?.volume = volume
        }
    }
    
    // timaer to manage progress
    var updateTimer: Timer?

    
    /// The delegate that will be called upon events.
    public weak var delegate: ISAudioPlayerDelegate?
    

    // Music item duration only
    var duartion: TimeInterval {
        get {
            if let playerItem = self.player?.currentItem {
                let duration : CMTime = playerItem.asset.duration
                let seconds : Float64 = CMTimeGetSeconds(duration)
               return seconds
            }
            return 0.0
        }
    }
    
    
    // observer for slider of player
    public var seekTimeSecoond :Int64 = 0{
        didSet{
            // convert to CMTime and change seek
             let targetTime:CMTime = CMTimeMake(seekTimeSecoond, 1)
             self.player?.seek(to: targetTime)
            
            guard let player = self.player else { return }
            let seconds : Float64 = CMTimeGetSeconds( player.currentTime())
            // notify Delegate
            delegate?.audioPlayer(self, didUpdateProgressionTo: seconds, endTime: self.duartion)
        }
    }
   
    // current item  is url that will change
    public internal(set) var currentItem: URL? {
        didSet{
             if let currentItem = currentItem {
                //Stops the current player
                self.stop()
                player?.rate = 0
                player = nil
                //Ensures the audio session got started
                setAudioSession(active: true)
                
                DispatchQueue.global(qos: .background).async {
                    //Create new AVPlayerItem
                    
                    let playerItem = AVPlayerItem(url: currentItem)
                   
                    // observer for AVPlayerItem until it be ready
                    playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
                    
                    //playerItemDidReachEnd notification
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(self.playerItemDidReachEnd(notification:)),
                                                           name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                           object: playerItem)
                    
                  
                     //Creates new player
                    self.player = AVPlayer(playerItem: playerItem)
                    self.state = .buffering
                    
                }
                
             }else{
                // bad url
                stop()
            }
        }
    }

    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        
       DispatchQueue.main.async {
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            // Get the status change from the change dictionary
            if let statusNumber = change?[NSKeyValueChangeKey.kindKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over the status
            switch status {
            case .readyToPlay:
                print("ready")
                
                if let playerItem = self.player?.currentItem {
                    let duration : CMTime = playerItem.asset.duration
                    let seconds : Float64 = CMTimeGetSeconds(duration)
                    self.delegate?.audioPlayer(self, didSetDuration: Float(seconds))
                }
             
               
            // Player item is ready to play.
            case .failed:
                 print("fail")
            // Player item failed. See error.
            case .unknown:
                print("unknown")
                // Player item is not yet ready.
            }
        }
        
    }
}
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
            self.delegate?.audioPlayer(self, didUpdateProgressionTo: 0, endTime: self.duartion)
            self.state = .paused
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
    

    /// The current state of the player.
    public internal(set) var state = AudioPlayerState.stopped {
        didSet {
            if state != oldValue {
                self.delegate?.audioPlayer(self, didChangeState: state)
            }
        }
    }
    
    
    var playList = [MusicItemRepresentable]()
 
    
    /// Defines the volume of the player. `1.0` means 100% and `0.0` is 0%.
    public var volume = Float(0.5) {
        didSet {
            player?.volume = volume
        }
    }
    
    // user start sliding play slider we have to puase player
   public func startSliding(){
       self.pause()
    }
    
   public func play(){
            if player?.rate == 0 {
                player?.play()
                state = .playing
                // create timer
                updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
                    guard let player = self.player else { return }
                    let seconds : Float64 = CMTimeGetSeconds( player.currentTime())
                    
                    self.delegate?.audioPlayer(self, didUpdateProgressionTo: seconds, endTime: self.duartion-seconds)
                    
                }
                
            }else{
               self.pause()
            }

    }

    fileprivate func pause(){
        player?.pause()
        state = .paused
        updateTimer?.invalidate()
        updateTimer = nil
    }
    /// Stops the player and clear the queue.
    fileprivate func stop() {
        
        if let _ = player {
            player?.rate = 0
            player = nil
        }
        if let _ = currentItem {
            currentItem = nil
        }
        updateTimer?.invalidate()
        updateTimer = nil
         setAudioSession(active: false)
         state = .stopped
    }


    /// - Parameter active: A boolean value indicating whether the audio session should be set to active or not.
    func setAudioSession(active: Bool) {
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        _ = try? AVAudioSession.sharedInstance().setActive(active)
    }
    
}
