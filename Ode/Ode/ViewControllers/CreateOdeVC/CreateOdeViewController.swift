//
//  CreateOdeViewController.swift
//  Ode
//
//  Created by Luqmaan Khan on 8/25/20.
//  Copyright © 2020 Luqmaan Khan. All rights reserved.
//

import UIKit
import AVFoundation


//EDIT VC
//DROP VC
class CreateOdeViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    

    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         captureSession.startRunning()
         setUpCaptureSession()
        cameraPreviewView.videoPlayerView.videoGravity = .resizeAspectFill
        self.view.backgroundColor = .black
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        captureSession.stopRunning()
    }
    

    private func setUpCaptureSession() {
        let camera = bestCamera()
           
           captureSession.beginConfiguration()
           
           // Add inputs

           guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
           captureSession.canAddInput(cameraInput) else {
               fatalError("Can't create an input from the camera, do something better than crashing")
           }
           captureSession.addInput(cameraInput)
                   
           if captureSession.canSetSessionPreset(.hd1920x1080) {
               captureSession.sessionPreset = .hd1920x1080
           }
        // Add audio input

        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Can't create and add input from microphone")
        }
        captureSession.addInput(audioInput)

        // ...
        
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record movie to disk")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
           
           
        self.cameraPreviewView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
    if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
        return device
    }
    
    if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
        return device
    }
    
    fatalError("No cameras on the device (or you are running it on the iPhone simulator")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    @IBAction func recordButtonTapped(_ sender: UIButton) {
    toggleRecord()

    }

    
    private func toggleRecord() {
        if fileOutput.isRecording {
            self.recordButton.setTitle("Record", for: .normal)
            fileOutput.stopRecording()
            updateViews()
        } else {
            self.recordButton.setTitle("Stop", for: .normal)
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
            updateViews()
        }
    }
        
        private func newRecordingURL() -> URL {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]

            let name = formatter.string(from: Date())
            let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
            return fileURL
        
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        print("Video: \(outputFileURL.path)")
        updateViews()
    }
}
