//
//  DropOdeViewController.swift
//  Ode
//
//  Created by Luqmaan Khan on 8/27/20.
//  Copyright © 2020 Luqmaan Khan. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class DropOdeViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
    
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    @IBOutlet weak var sceneView: ARSCNView!
    var movieURL: URL?
    var grids = [Grid]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = self.movieURL {
            let item = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: item)
            self.videoPlayerView.player = player
            player.play()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification
                           in player.seek(to: CMTime.zero)
                           player.play()
                       }
            
        }
        guard ARWorldTrackingConfiguration.isSupported else {
                   fatalError("""
                       ARKit is not available on this device. For apps that require ARKit
                       for core functionality, use the `arkit` key in the key in the
                       `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                       the app from installing. (If the app can't be installed, this error
                       can't be triggered in a production scenario.)
                       In apps where AR is an additive feature, use `isSupported` to
                       determine whether to show UI for launching AR experiences.
                   """) // For details, see https://developer.apple.com/documentation/arkit
               }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        sceneView.session.pause()
    }
    
    @objc func tapped(gesture: UITapGestureRecognizer) {
        let touchPosition = gesture.location(in: self.sceneView)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)
        guard let hitTest = hitTestResults.first else {
            return
        }
        addOdeBackground(hitTestResult: hitTest)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = Grid(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
            }.first

        guard let foundGrid = grid else {
            return
        }

        foundGrid.update(anchor: planeAnchor)
    }
    
    func addOdeBackground(hitTestResult: ARHitTestResult) {
        let scene = SCNScene(named: "tv.scn")
        let odeBackgroundNode = scene?.rootNode.childNode(withName: "tv_node", recursively: true)
        odeBackgroundNode?.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
        let backgroundPlaneNode = odeBackgroundNode?.childNode(withName: "screen", recursively: true)
        let backgroundPlaneNodeGeometry = backgroundPlaneNode?.geometry as! SCNPlane
        if let url = self.movieURL {
      
            let item = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: item)
            let videoNode = SKVideoNode(avPlayer: player)
            
            videoNode.zRotation = CGFloat(-Double.pi) * 90 / 180
            let videoScene = SKScene(size: .init(width: backgroundPlaneNodeGeometry.width*1000, height: backgroundPlaneNodeGeometry.height*1000))
            videoScene.addChild(videoNode)
            videoNode.position = CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2)
            videoNode.size = videoScene.size

            let tvScreenMaterial = backgroundPlaneNodeGeometry.materials.first(where: { $0.name == "video" })
            tvScreenMaterial?.diffuse.contents = videoScene

            videoNode.play()
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification
                in player.seek(to: CMTime.zero)
                player.play()
            }
        
        self.sceneView.scene.rootNode.addChildNode(odeBackgroundNode!)
        }
    }

}
