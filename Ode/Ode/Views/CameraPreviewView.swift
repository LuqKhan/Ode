//
//  CameraPreviewView.swift
//  Ode
//
//  Created by Luqmaan Khan on 8/25/20.
//  Copyright © 2020 Luqmaan Khan. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {

    
    override class var layerClass: AnyClass {
           return AVCaptureVideoPreviewLayer.self
       }
       
       var videoPlayerView: AVCaptureVideoPreviewLayer {
           return layer as! AVCaptureVideoPreviewLayer
       }
       
       var session: AVCaptureSession? {
           get { return videoPlayerView.session }
           set { videoPlayerView.session = newValue }
       }
}
