//
// AudioSpectrum01
// A demo project for blog: https://juejin.im/timeline
// Created by: potato04 on 2019/1/13
//

import Foundation
import AVFoundation
import Accelerate

protocol AudioSpectrumPlayerDelegate: AnyObject {
    func player(_ player: AudioSpectrumPlayer, didGenerateSpectrum spectrum: [[Float]])
}

class AudioSpectrumPlayer {
    
    weak var delegate: AudioSpectrumPlayerDelegate?
    
    init() {
        
    }
    
    func play(withFileName fileName: String) {
        
    }
    
    func stop() {
        
    }
}
