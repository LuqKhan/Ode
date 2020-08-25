//
//  LoginViewController.swift
//  Ode
//
//  Created by Luqmaan Khan on 8/25/20.
//  Copyright © 2020 Luqmaan Khan. All rights reserved.
//

import UIKit
import AVFoundation

class LoginViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    
    var authorized: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        requestPermissionAndShowCamera()
    }
    
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            
        case .notDetermined:
            // First time user has seen the dialog, we don't have permission
            
            requestPermission()
        case .restricted:
            // parental controls
            
            fatalError("Video is disabled for parental controls")
        case .denied:
            // we asked for permission and they said no
            
            fatalError("Tell user they need to enable Privacy for Video/Camera/Microphone")
        case .authorized:
            // we asked for permission and they said yes
            self.authorized = true
          print("Camera auth granted")
        default:
            fatalError("A new status was added that we need to handle")
        }
    }
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            guard granted else {
                fatalError("Tell user they need to enable Privacy for Video/Camera/Microphone")
            }
            DispatchQueue.main.async { [weak self] in
                self?.authorized = true
                print("Camera auth granted")
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func signInTapped(_ sender: UIButton) {
        let tab = UITabBarController()
        let createVC = CreateOdeViewController()
        let navController = UINavigationController(rootViewController: tab)
        tab.viewControllers = [createVC]
        navController.modalPresentationStyle = .overFullScreen
        if self.authorized {
        self.present(navController, animated: true, completion: nil)
    
        }
    }
    
}
