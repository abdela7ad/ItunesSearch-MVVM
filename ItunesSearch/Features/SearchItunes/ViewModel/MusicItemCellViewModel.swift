//
//  SearchDisplayCellViewModel.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/10/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import Foundation

protocol MusicItemRepresentable {
    var artistName :String {get}
    var trackName  :String  {get}
    var previewUrl :URL?   {get}
    var artworkUrl :URL?   {get}
    var trackID    :Int  {get}
}


class MusicItemCellViewModel: MusicItemRepresentable {
   
    
    
    private var musicItem:MusicItem
    
    init(_ musicItem:MusicItem) {
        
        self.musicItem = musicItem
    }
    
    var artistName: String {
        return self.musicItem.artistName
    }
    
    var trackName: String {
        return self.musicItem.trackName
    }
    
    var previewUrl: URL? {
        return self.musicItem.previewURL
    }
    
    var artworkUrl: URL?{
        return self.musicItem.artworkUrl100
    }
    
    var trackID: Int {
        return self.musicItem.trackID
    }
   
    
    
    
}
