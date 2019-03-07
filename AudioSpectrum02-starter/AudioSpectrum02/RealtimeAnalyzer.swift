//
// AudioSpectrum02
// A demo project for blog: https://juejin.im/timeline
// Created by: potato04 on 2019/1/30
//

import Foundation
import AVFoundation
import Accelerate

class RealtimeAnalyzer {
    private var fftSize: Int
    private lazy var fftSetup = vDSP_create_fftsetup(vDSP_Length(Int(round(log2(Double(fftSize))))), FFTRadix(kFFTRadix2))
    
    public var frequencyBands: Int = 80 //频带数量
    public var startFrequency: Float = 100 //起始频率
    public var endFrequency: Float = 18000 //截止频率
    

    init(fftSize: Int) {
        self.fftSize = fftSize
    }
    
    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }

    func analyse(with buffer: AVAudioPCMBuffer) -> [[Float]] {
        return [[Float]]()
    }
    
    private func fft(_ buffer: AVAudioPCMBuffer) -> [[Float]] {
        var amplitudes = [[Float]]()
        guard let floatChannelData = buffer.floatChannelData else { return amplitudes }
        
        //1：抽取buffer中的样本数据
        var channels: UnsafePointer<UnsafeMutablePointer<Float>> = floatChannelData
        let channelCount = Int(buffer.format.channelCount)
        let isInterleaved = buffer.format.isInterleaved
        
        if isInterleaved {
            // deinterleave
            let interleavedData = UnsafeBufferPointer(start: floatChannelData[0], count: self.fftSize * channelCount)
            var channelsTemp : [UnsafeMutablePointer<Float>] = []
            for i in 0..<channelCount {
                var channelData = stride(from: i, to: interleavedData.count, by: channelCount).map{ interleavedData[$0] }
                channelsTemp.append(UnsafeMutablePointer(&channelData))
            }
            channels = UnsafePointer(channelsTemp)
        }
        
        for i in 0..<channelCount {
            
            let channel = channels[i]
            //2: 加汉宁窗
            var window = [Float](repeating: 0, count: Int(fftSize))
            vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
            vDSP_vmul(channel, 1, window, 1, channel, 1, vDSP_Length(fftSize))
            
            //3: 将实数包装成FFT要求的复数fftInOut，既是输入也是输出
            var realp = [Float](repeating: 0.0, count: Int(fftSize / 2))
            var imagp = [Float](repeating: 0.0, count: Int(fftSize / 2))
            var fftInOut = DSPSplitComplex(realp: &realp, imagp: &imagp)
            channel.withMemoryRebound(to: DSPComplex.self, capacity: fftSize) { (typeConvertedTransferBuffer) -> Void in
                vDSP_ctoz(typeConvertedTransferBuffer, 2, &fftInOut, 1, vDSP_Length(fftSize / 2))
            }
            
            //4：执行FFT
            vDSP_fft_zrip(fftSetup!, &fftInOut, 1, vDSP_Length(round(log2(Double(fftSize)))), FFTDirection(FFT_FORWARD));
            
            //5：调整FFT结果，计算振幅
            fftInOut.imagp[0] = 0
            let fftNormFactor = Float(1.0 / (Float(fftSize)))
            vDSP_vsmul(fftInOut.realp, 1, [fftNormFactor], fftInOut.realp, 1, vDSP_Length(fftSize / 2));
            vDSP_vsmul(fftInOut.imagp, 1, [fftNormFactor], fftInOut.imagp, 1, vDSP_Length(fftSize / 2));
            var channelAmplitudes = [Float](repeating: 0.0, count: Int(fftSize / 2))
            vDSP_zvabs(&fftInOut, 1, &channelAmplitudes, 1, vDSP_Length(fftSize / 2));
            channelAmplitudes[0] = channelAmplitudes[0] / 2 //直流分量的振幅需要再除以2
            amplitudes.append(channelAmplitudes)
        }
        return amplitudes
    }    
}
