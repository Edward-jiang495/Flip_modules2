//
//  AudioModel.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import Foundation
import Accelerate

class AudioModel {
    
    // MARK: Properties
    private var BUFFER_SIZE:Int
    // thse properties are for interfaceing with the API
    // the user can access these arrays at any time and plot them if they like
    var timeData:[Float]
    var fftData:[Float]
    var twentyData:[Float]
    
    // MARK: Public Methods
    init(buffer_size:Int) {
        BUFFER_SIZE = buffer_size
        // anything not lazily instatntiated should be allocated here
        timeData = Array.init(repeating: 0.0, count: BUFFER_SIZE)
        fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        twentyData = Array.init(repeating: 0.0, count: 20)
    }
    
//    // public function for starting processing of microphone data
//    func startMicrophoneProcessing(withFps:Double){
//        // setup the microphone to copy to circualr buffer
//        if let manager = self.audioManager{
//            manager.inputBlock = self.handleMicrophone
//
//            // repeat this fps times per second using the timer class
//            //   every time this is called, we update the arrays "timeData" and "fftData"
//            Timer.scheduledTimer(timeInterval: 1.0/withFps, target: self,
//                                 selector: #selector(self.runEveryInterval),
//                                 userInfo: nil,
//                                 repeats: true)
//        }
//    }
    
    func startProcesingAudioFileForPlayback(){
        // set the output block to read from and play the audio file
        if let manager = self.audioManager,
           let fileReader = self.fileReader{
            manager.outputBlock = self.handleSpeakerQueryWithAudioFile
            fileReader.play()
            Timer.scheduledTimer(timeInterval: 0.05, target: self,
                                             selector: #selector(self.runEveryInterval),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    
    
    // You must call this when you want the audio to start being handled by our model
    func play(){
        self.audioManager?.play()
    }
    
    func pause() {
        if let manager = self.audioManager {
            manager.pause()
            manager.outputBlock = nil
        }
    }
    
    //==========================================
    // MARK: Private Properties
    private lazy var audioManager:Novocaine? = {
        return Novocaine.audioManager()
    }()
    
    private lazy var fftHelper:FFTHelper? = {
        return FFTHelper.init(fftSize: Int32(BUFFER_SIZE))
    }()
    
    
    private lazy var inputBuffer:CircularBuffer? = {
        return CircularBuffer.init(numChannels: Int64(self.audioManager!.numInputChannels),
                                   andBufferSize: Int64(BUFFER_SIZE))
    }()
    
    private lazy var fileReader:AudioFileReader? = {
        if let url = Bundle.main.url(forResource: "satisfaction", withExtension: "mp3"){
            var tmpFileReader:AudioFileReader? = AudioFileReader.init(audioFileURL: url, samplingRate: Float(audioManager!.samplingRate), numChannels: audioManager!.numOutputChannels)
            tmpFileReader!.currentTime = 0.0
            print("Audio file succesfully loaded for \(url)");
            return tmpFileReader;
        }else{
            print("Could not initialze audio input file")
            return nil;
        }
    }()
    
    
    //==========================================
    // MARK: Private Methods
    // NONE for this model
    
    //==========================================
    // MARK: Model Callback Methods
    @objc
    private func runEveryInterval(){
        if inputBuffer != nil {
            // copy time data to swift array
            self.inputBuffer!.fetchFreshData(&timeData,
                                             withNumSamples: Int64(BUFFER_SIZE))
            
            // now take FFT
            fftHelper!.performForwardFFT(withData: &timeData,
                                         andCopydBMagnitudeToBuffer: &fftData)
            
//            self.twentyData = Array(self.fftData[0..<20])
            
            let windowSize = self.fftData.count / 20
            for index in 0...19 {
                var sum:Float = 0
                var count:Float = 0

                for fttIndex in (index * windowSize)...((index + 1) * windowSize)
                {
                    sum += self.fftData[fttIndex]
                    count += 1
                }

                self.twentyData[index] = sum / count
            }
        }
    }
//
//    //==========================================
//    // MARK: Audiocard Callbacks
//    // in obj-C it was (^InputBlock)(float *data, UInt32 numFrames, UInt32 numChannels)
//    // and in swift this translates to:
//    private func handleMicrophone (data:Optional<UnsafeMutablePointer<Float>>, numFrames:UInt32, numChannels: UInt32) {
//        // copy samples from the microphone into circular buffer
//        self.inputBuffer?.addNewFloatData(data, withNumSamples: Int64(numFrames))
//    }
//
    //==========================================
    // MARK: Audiocard Callbacks
    // in obj-C it was (^InputBlock)(float *data, UInt32 numFrames, UInt32 numChannels)
    // and in swift this translates to:
    private func handleSpeakerQueryWithAudioFile(data:Optional<UnsafeMutablePointer<Float>>,numFrames:UInt32,numChannels:UInt32){
        if let file = self.fileReader {
            file.retrieveFreshAudio(data, numFrames: numFrames, numChannels: numChannels);
            self.inputBuffer?.addNewFloatData(data, withNumSamples: Int64(numFrames));
        }
    }
}
