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
    
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    
    @IBOutlet weak var editButton: UIButton!
    var movieURL: URL?
    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    @IBOutlet weak var recordButton: UIButton!
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButtonItem = UIBarButtonItem(title: "Edit Node", style: .plain, target: self, action: #selector(self.navigateToEdit))
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        self.videoPlayerView.alpha = 0
         captureSession.startRunning()
         setUpCaptureSession()
        cameraPreviewView.videoPlayerView.videoGravity = .resizeAspectFill
        self.view.backgroundColor = .black
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
            view.addGestureRecognizer(tapGesture)
        }

        @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
            print("tap")
            switch(tapGesture.state) {
                
            case .ended:
                replayMovie()
            default:
                print("Handled other states: \(tapGesture.state)")
            }
    }
    
    @objc func navigateToEdit() {
        let editVC = EditNodeViewController()
        self.navigationController?.pushViewController(editVC, animated: true)
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
    
    private func playVideo(url: URL) {
        self.movieURL = url
        let player = AVPlayer(url: url)
        self.player = player
        self.videoPlayerView.player = player
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    @objc func replayMovie(){
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        let editVC = EditNodeViewController()
        editVC.movieURL = self.movieURL
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            self.recordButton.setTitle("Record", for: .normal)
            updateViews()
            self.videoPlayerView.alpha = 1
        } else {
            self.videoPlayerView.alpha = 0
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
        DispatchQueue.main.async {
            self.playVideo(url: outputFileURL)
        }
    }
}
