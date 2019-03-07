//
// AudioSpectrum02
// A demo project for blog: https://juejin.im/timeline
// Created by: potato04 on 2019/1/13
//

import Foundation
import AVFoundation

protocol AudioSpectrumPlayerDelegate: AnyObject {
    func player(_ player: AudioSpectrumPlayer, didGenerateSpectrum spectra: [[Float]])
}

class AudioSpectrumPlayer {
    
    weak var delegate: AudioSpectrumPlayerDelegate?
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    
    public var bufferSize: Int? {
        didSet {
            if let bufferSize = self.bufferSize {
                analyzer = RealtimeAnalyzer(fftSize: bufferSize)
                engine.mainMixerNode.removeTap(onBus: 0)
                engine.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(bufferSize), format: nil, block: {[weak self](buffer, when) in
                    guard let strongSelf = self else { return }
                    if !strongSelf.player.isPlaying { return }
                    buffer.frameLength = AVAudioFrameCount(bufferSize)
                    let spectra = strongSelf.analyzer.analyse(with: buffer)
                    if strongSelf.delegate != nil {
                        strongSelf.delegate!.player(strongSelf, didGenerateSpectrum: spectra)
                    }
                })
            }
        }
    }
    
    public var analyzer: RealtimeAnalyzer!
    
    init(bufferSize: Int = 2048) {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        try! engine.start()
    
        defer {
            self.bufferSize = bufferSize
        }
    }

    func play(withFileName fileName: String) {
        guard let audioFileURL = Bundle.main.url(forResource: fileName, withExtension: nil),
            let audioFile = try? AVAudioFile(forReading: audioFileURL) else { return }
        player.stop()
        player.scheduleFile(audioFile, at: nil, completionHandler: nil)
        player.play()
    }
    
    func stop() {
        player.stop()
    }
}
