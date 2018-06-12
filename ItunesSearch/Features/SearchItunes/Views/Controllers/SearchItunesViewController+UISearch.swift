//
//  SearchItunesViewController+UISearch.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/10/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import Foundation
import UIKit

extension SearchItunesViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchViewModel.searchInput = searchText
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchViewModel.performSearch()
    }
}

extension SearchItunesViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
     
    }
}

