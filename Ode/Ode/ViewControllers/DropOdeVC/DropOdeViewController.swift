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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let videoNode = loadMovieModel() {
            node.addChildNode(videoNode)
        }
    }
    
    @IBAction func dropTapped(_ sender: UIButton) {
        guard let hitTestResult = sceneView.hitTest(sender.center, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane]).first else {return}
        let anchor = ARAnchor(name: "video", transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    
    private func loadMovieModel() -> SCNNode? {
        guard let url = self.movieURL else {return nil}
        let node = SCNReferenceNode(url: url)
        node?.load()
        return node
    }

}
