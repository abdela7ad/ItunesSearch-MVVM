//
//  PreviewViewModel.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/12/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import Foundation


class PreviewAudioViewModel {
    // Audioplayer injection
    private var audioPlayer = ISAudioPlayer.shared
   
    // search result
    private var searchResults = [MusicItemRepresentable]()

    // curren player items
    private var musicItem : MusicItemRepresentable{
        didSet{
             self.configurePlayer()
        }
    }
    
    // track name
    public var trackName:String{
        return self.musicItem.trackName
    }
    // art work
    public var artWork:URL?{
        return self.musicItem.artworkUrl
    }
    
     // Volume Slider Observer
    
    var playSliderValue:Float = 0.0 {
        didSet{
            let seconds : Int64 = Int64(playSliderValue)
            self.audioPlayer.seekTimeSecoond = seconds
        }
    }
    
    // Volume Slider Observer
    var volumeSliderValue:Float = 0.0 {
        didSet{
            self.audioPlayer.volume = volumeSliderValue
        }
    }
    
    // Player State Notifier
    var didChangePlayerState: (_ state :AudioPlayerState) -> (Void) = { _ in }
    
    // Time Notifier
    var didChangePlayingTime: (_ sliderValue:Double , _ startTime:String,_ endTime:String) -> (Void) = { _,_,_  in }
    // Duration Notifier
    var didUpdateDuration: (_ duartion:Float) -> (Void) = { _ in }

    // track name and image Notifer
    var didUpdateMetaData: (_ trackName:String, _ artwork:URL?) -> (Void) = { _,_  in }
    
    init(musicItem item:MusicItemRepresentable ,  searchResult musicSearchList:[MusicItemRepresentable]) {
        self.musicItem = item
        self.searchResults =  musicSearchList
        self.configurePlayer()
    }
    
    fileprivate func configurePlayer(){
        guard let musicItemUrl =  self.musicItem.previewUrl else {return}
        audioPlayer.currentItem = musicItemUrl
        audioPlayer.delegate = self
        didUpdateMetaData(self.musicItem.trackName,self.musicItem.artworkUrl)
    }
    

    
    func playNextItem(){
        

      // get current item index
         let currentIndex = self.searchResults.index { (item) -> Bool in
            return self.musicItem.trackID == item.trackID
        }
        
        // Play current Index
        if let currentIndex = currentIndex,  currentIndex+1 < searchResults.count {
            self.musicItem = searchResults[ currentIndex+1]
        }
    }
    
    func playPreviousItem(){
        // get current item index
        let currentIndex = self.searchResults.index { (item) -> Bool in
            return self.musicItem.trackID == item.trackID
        }
        
        // Play current Index
        if let currentIndex = currentIndex,  currentIndex-1 >= 0 {
            self.musicItem = searchResults[ currentIndex-1]
        }
    }
    
    func controlPlayStatus(){
        self.audioPlayer.play()
    }
    
    func startSliding(){
        self.audioPlayer.startSliding()
    }
    
    
    fileprivate func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
}

extension PreviewAudioViewModel : ISAudioPlayerDelegate{
    func audioPlayer(_ audioPlayer: ISAudioPlayer, didSetDuration duration: Float) {
        self.controlPlayStatus()
        didUpdateDuration(duration)
    }
    func audioPlayer(_ audioPlayer: ISAudioPlayer, didUpdateProgressionTo time: TimeInterval, endTime: TimeInterval) {
      didChangePlayingTime(time,formatSecondsToString(time),formatSecondsToString(TimeInterval(endTime)))
        
    }
    func audioPlayer(_ audioPlayer: ISAudioPlayer, didChangeState state: AudioPlayerState) {
        didChangePlayerState(state)
    }
    
  
}
