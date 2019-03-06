//
// AudioSpectrum01
// A demo project for blog: https://juejin.im/post/5c1bbec66fb9a049cb18b64c
// Created by: potato04 on 2019/1/13
//

import UIKit

protocol TrackCellDelegate: AnyObject {
    func playTapped(_ cell: TrackCell)
    func stopTapped(_ cell: TrackCell)
}

class TrackCell: UITableViewCell {
    
    weak var delegate: TrackCellDelegate?
    @IBOutlet weak var playOrStopButton: UIButton!
    @IBOutlet weak var trackNameLabel: UILabel!
    
    func configure(trackName: String, playing: Bool) {
        trackNameLabel.text = trackName
        if playing {
            playOrStopButton.setTitle("Stop", for: .normal)
        } else {
            playOrStopButton.setTitle("Play", for: .normal)
        }
    }
    
    @IBAction func playOrStopTapped(_ sender: Any) {
        if playOrStopButton.titleLabel?.text == "Stop" {
            playOrStopButton.setTitle("Play", for: .normal)
            self.delegate?.stopTapped(self)
        } else if playOrStopButton.titleLabel?.text == "Play" {
            playOrStopButton.setTitle("Stop", for: .normal)
            self.delegate?.playTapped(self)
        }
    }
}
