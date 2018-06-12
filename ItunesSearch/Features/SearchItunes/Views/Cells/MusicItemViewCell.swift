//
//  MusicItemViewCell.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/10/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import UIKit
import Kingfisher
class MusicItemViewCell: UITableViewCell {

    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artWork: UIImageView!

    // MARK: - Types
    static let nibName = "MusicItemViewCell"
    static let cellIdentifier = "MusicItemViewCell"
    
    
    var musicItem: MusicItemRepresentable? {
        didSet{
                self.artistNameLabel.text = musicItem?.artistName
                self.trackNameLabel.text = musicItem?.trackName
            if let url = musicItem?.artworkUrl {
                artWork.kf.indicatorType = .activity
               artWork.kf.setImage(with: url)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
