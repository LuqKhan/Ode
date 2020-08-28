//
//  VideoPlayerView.swift
//  Ode
//
//  Created by Luqmaan Khan on 8/26/20.
//  Copyright © 2020 Luqmaan Khan. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var videoPlayerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get { return videoPlayerLayer.player }
        set { videoPlayerLayer.player = newValue }
    }
}
