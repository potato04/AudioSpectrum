//
// AudioSpectrum02
// A demo project for blog: https://juejin.im/timeline
// Created by: potato04 on 2019/1/30
//

import UIKit

class SpectrumView: UIView {
    
    var barWidth: CGFloat = 3.0
    var space: CGFloat = 1.0
    
    private let bottomSpace: CGFloat = 0.0
    private let topSpace: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
