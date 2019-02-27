//
// AudioSpectrum01
// A demo project for blog: https://juejin.im/timeline
// Created by: potato04 on 2019/1/13
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var trackTableView: UITableView!
    
    var player: AudioSpectrumPlayer!
    
    private lazy var trackPaths: [String] = {
        var paths = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
        paths.sort()
        return paths.map { $0.components(separatedBy: "/").last! }
    }()
    
    private var currentPlayingRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        trackTableView.dataSource = self
        player = AudioSpectrumPlayer()
        player.delegate = self
    }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackPaths.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        cell.configure(trackName: "\(trackPaths[indexPath.row])", playing: currentPlayingRow == indexPath.row)
        cell.delegate = self
        return cell
    }
}

// MARK: TrackCellDelegate
extension ViewController: TrackCellDelegate {
    func playTapped(_ cell: TrackCell) {
        if let indexPath = trackTableView.indexPath(for: cell) {
            let previousPlayingRow = currentPlayingRow
            self.currentPlayingRow = indexPath.row
            if indexPath.row != previousPlayingRow && previousPlayingRow != nil  {
                trackTableView.reloadRows(at: [IndexPath(row: previousPlayingRow!, section: 0)], with: .none)
            }
            player.play(withFileName: trackPaths[indexPath.row])
        }
    }
    func stopTapped(_ cell: TrackCell) {
        self.currentPlayingRow = nil
        player.stop()
    }
}

// MARK: SpectrumPlayerDelegate
extension ViewController: AudioSpectrumPlayerDelegate {
    func player(_ player: AudioSpectrumPlayer, didGenerateSpectrum spectrum: [[Float]]) {
        DispatchQueue.main.async {
            print(spectrum)
        }
    }
}
