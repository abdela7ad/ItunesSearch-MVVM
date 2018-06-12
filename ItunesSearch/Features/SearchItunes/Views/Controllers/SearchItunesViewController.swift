//
//  SearchItunesViewController.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/10/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import UIKit

class SearchItunesViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var hintLabel : UILabel!

    internal  var searchViewModel = SearchResultsViewModel()
    
    let searchController = UISearchController(searchResultsController: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSubviews()
 
        self.bindViewModel()
    }
    
    
    //MARK:- Inital SubViews
    func initSubviews(){

        self.tableView.alpha = 0
        self.hintLabel.text = "Welcome to Itunes Music Search"
        self.navigationItem.title = "Itunes Music"
        searchController.searchBar.placeholder = "Search Itunes Music"
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, we place the search bar in the navigation bar.
            navigationController?.navigationBar.prefersLargeTitles = true
            
            navigationItem.searchController = searchController
            
            // We want the search bar visible all the time.
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // For iOS 10 and earlier, we place the search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar
        }
        
        searchController.dimsBackgroundDuringPresentation = false // default is YES
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        /*
         Search is now just presenting a view controller. As such, normal view controller
         presentation semantics apply. Namely that presentation will walk up the view controller
         hierarchy until it finds the root view controller or one that defines a presentation context.
         */
        definesPresentationContext = false
        
        // Register Cell and and Automatic Height
        self.tableView.register(UINib(nibName: MusicItemViewCell.nibName, bundle: nil), forCellReuseIdentifier: MusicItemViewCell.cellIdentifier)
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    
    //MARK:- BindViewModel
    
    func bindViewModel(){
        
        searchViewModel.didFetchResult = { [weak self]  (result)  in
            DispatchQueue.main.async {
                guard let strongSelf = self else {return}
                strongSelf.searchViewModel.searhResults = result
                strongSelf.tableView.alpha = 1
                strongSelf.hintLabel.text = ""
                strongSelf.tableView.reloadData()
            }  
        }
        
        searchViewModel.didStartFetch = { [weak self] in
            DispatchQueue.main.async {
                guard let strongSelf = self else {return}
                strongSelf.tableView.alpha = 0
                strongSelf.hintLabel.text = "Fetch Itunes Music...."
            }
        }
        
        searchViewModel.searchFetchError = { [weak self] (error)in
            DispatchQueue.main.async {
                guard let strongSelf = self else {return}
                guard let error = error else {return}
                strongSelf.tableView.alpha = 0
                strongSelf.hintLabel.text = error.localizedDescription
            }
        }
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? PreviewAudioViewcontroller,
          let musicItem = sender as? MusicItemRepresentable  {
            // Prepare Audio View Model
            let previewViewModel = PreviewAudioViewModel(musicItem: musicItem, searchResult: self.searchViewModel.searhResults)
            
            destination.previewAudioViewModel = previewViewModel
    
        }
    }
   
}

  //MARK:- TableView Delegate
extension SearchItunesViewController : UITableViewDelegate,UITableViewDataSource{
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchViewModel.searhResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let musicItem = self.searchViewModel.searhResults[indexPath.row]
        
        self.performSegue(withIdentifier: "PreviewMusic_Identifier", sender: musicItem)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MusicItemViewCell.cellIdentifier, for: indexPath) as!  MusicItemViewCell
        cell.musicItem = self.searchViewModel.searhResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

