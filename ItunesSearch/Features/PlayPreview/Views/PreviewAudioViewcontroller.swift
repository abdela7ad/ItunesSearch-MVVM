//
//  Previewcontroller.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/10/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewAudioViewcontroller: UIViewController{

    @IBOutlet weak var   startTime : UILabel!
    @IBOutlet weak var   endTime : UILabel!
    @IBOutlet weak var   preViewImageView : UIImageView!
    @IBOutlet weak var   titleLabel : UILabel!
    @IBOutlet weak var   playButton : UIButton!
    @IBOutlet weak var   playbackSlider:UISlider!
    @IBOutlet weak var   bufferIndicator:UIActivityIndicatorView!

     var previewAudioViewModel : PreviewAudioViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }


        self.initSubviews()
        
        self.bindViewModel()
        
    }
    
    func initSubviews(){
        
        //  buffer Indicator
        self.bufferIndicator.alpha = 1
        self.bufferIndicator.startAnimating()
        self.playButton.alpha = 0

        // slider setup
        playbackSlider.minimumValue = 0
        playbackSlider.maximumValue = 1 // inital value until we read duration
        playbackSlider.isContinuous = true
    }
    
    func bindViewModel() {
        
        
        // Meta data at initalizaton
        if let previewUrl = self.previewAudioViewModel.artWork {
            self.preViewImageView.kf.indicatorType = .activity
            self.preViewImageView.kf.setImage(with: previewUrl)
        }
        self.titleLabel.text = self.previewAudioViewModel.trackName

 
        self.previewAudioViewModel.didUpdateMetaData =  { [weak self] (trackName,artworkUrl)  in
            DispatchQueue.main.async {
                guard let strongSelf = self else {return}
                strongSelf.titleLabel.text = trackName
                if let previewUrl = artworkUrl {
                    strongSelf.preViewImageView.kf.indicatorType = .activity
                    strongSelf.preViewImageView.kf.setImage(with: previewUrl)
                }
            }
        }
        
        self.previewAudioViewModel.didChangePlayerState = {state in
            
            DispatchQueue.main.async {
                self.bufferIndicator.alpha = 0
                self.bufferIndicator.stopAnimating()
                self.playButton.alpha = 1
                
                switch state {
                case .playing:
                    self.playButton.setImage(UIImage(named: "controls_pause"), for: .normal)
                    
                case .paused:
                    self.playButton.setImage(UIImage(named: "controls_play"), for: .normal)
                    
                case .stopped:
                    self.playButton.setImage(UIImage(named: "controls_play"), for: .normal)
                    
                case .buffering:
                    self.bufferIndicator.alpha = 1
                    self.bufferIndicator.startAnimating()
                    self.playButton.alpha = 0

                }
            }
         
        }
        
        
        self.previewAudioViewModel.didChangePlayingTime = { [weak self] (sliderValue,start,end)  in
            guard let strongSelf = self else {return}
            strongSelf.playbackSlider.value = Float(sliderValue)
            strongSelf.startTime.text = start
            strongSelf.endTime.text = end
        }
        
        self.previewAudioViewModel.didUpdateDuration = { [weak self] (duartion)  in
            guard let strongSelf = self else {return}
            strongSelf.playbackSlider.maximumValue = duartion
        }
        
    }


    
    
    @IBAction func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        self.previewAudioViewModel.playSliderValue = playbackSlider.value
    }
    
    @IBAction func didStartSlidingSlider(_ sender: UISlider) {
        self.previewAudioViewModel.startSliding()
    }
    
    @IBAction func didFinishSlidingSlider(_ sender: UISlider) {
        self.previewAudioViewModel.controlPlayStatus()
    }
    
    @IBAction func volumeSliderValueChanged(_ volumeSlider:UISlider)
    {
        self.previewAudioViewModel.volumeSliderValue = volumeSlider.value

    }
    
    
    @IBAction func playButtonTapped(_ sender:UIButton)
    {
        self.previewAudioViewModel.controlPlayStatus()
    }
    
    @IBAction func playNextItem(_ sender:UIButton)
    {
        self.previewAudioViewModel.playNextItem()
    }
    @IBAction func playPreviousItem(_ sender:UIButton)
    {
        self.previewAudioViewModel.playPreviousItem()
    }
}
