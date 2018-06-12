//
//  SearchResultsViewModel.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/10/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import Foundation

class SearchResultsViewModel {

    // dependency injection
    private let apiManager = APIManager.shared
    
    // search result Data source for TableView Display
    
    var searhResults = [MusicItemRepresentable]()

    var searchInput: String = "" {
        didSet{
            // start fetch after 3 character
            if searchInput.count > 2{
                self.performSearch()
            }
        }
    }

    var didFetchResult: (_ result:[MusicItemRepresentable]) -> (Void) = { _  in }
    
    var didStartFetch: () -> (Void) = {   }

    var searchFetchError: ( _ error:Error?) -> (Void) = { _ in  }

    
    //MARK: API Search
    func performSearch(){
        didStartFetch()
        apiManager.request(ItunesAPI.search(query: self.searchInput, media: "music", limit: 10), succes: { (data) in
           if let music = try? ItunesSearch.init(data: data),
            let items = music.results {
            let cellReprecentable = items.map({MusicItemCellViewModel($0)})
            self.searhResults = cellReprecentable
            self.didFetchResult(cellReprecentable)
            }
        }) { (result, error) in
            self.searchFetchError(error)
        }
        
    }
}
