//
//  ViewController.swift
//  SolarSystem
//
//  Created by 小池駿平 on 2017/10/15.
//  Copyright © 2017年 小池駿平. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import GoogleMobileAds

class ViewController: UIViewController, ARSCNViewDelegate, GADBannerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var bannerView: GADBannerView!
    let request = GADRequest()
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var supportText: UILabel!
    
    
    var showPortal = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
        
        // config banner
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = Consts.bannerAdUnitId
        bannerView.rootViewController = self
        bannerView.load(request)
        
        // config interstitial
        interstitial = GADInterstitial(adUnitID: Consts.interstitialAdUnitId)
        interstitial.load(request)
    }
    
    @IBAction func choosePicture() {
        // カメラロールが利用可能か？
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    @IBAction func clearPortal(_ sender: Any) {
        for node in self.sceneView.scene.rootNode.childNodes {
            print(node)
            node.removeFromParentNode()
        }
        showPortal = false
        
        interstitial.present(fromRootViewController: self)
        request.testDevices = [kGADSimulatorID]
        interstitial = GADInterstitial(adUnitID: Consts.interstitialAdUnitId)
        interstitial.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (showPortal) {
            return
        }
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        guard let hitResult = results.first else { return }
        let portalScene = SCNScene(named: "art.scnassets/portal.scn")!
        
        guard let portalNode = portalScene.rootNode.childNode(withName: "portal", recursively: true) else { return }
        
        let x = hitResult.worldTransform.columns.3.x
        let y = hitResult.worldTransform.columns.3.y + 1
        let z = hitResult.worldTransform.columns.3.z - 6
        
        self.supportText.alpha = 0
        for node in self.sceneView.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
        
        let fireNode = Fire().createFire(x: x, y: y - 3, z: z)//originaly +2
        self.sceneView.scene.rootNode.addChildNode(fireNode)
 
        portalNode.position = SCNVector3(x: x, y: y, z: z)
        portalNode.renderingOrder = 100
        portalNode.opacity = 0
        let fadeIn = SCNAction.fadeIn(duration: 5)
        portalNode.runAction(fadeIn)
        //portalNode.
        //portalNod
        portalNode.
        let material = SCNMaterial()
        
        self.sceneView.scene.rootNode.addChildNode(portalNode)
        
        let solarSystem = SolarSystem(x: x, y: y, z: z)
        for node in solarSystem.getNodeList() {
            self.sceneView.scene.rootNode.addChildNode(node)
        }
        self.showPortal = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (showPortal) {
            return
        }
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        plane.materials = [GridMaterial().create()]
        planeNode.geometry = plane
        node.addChildNode(planeNode)
        DispatchQueue.main.async(execute: {
            UIApplication.shared.registerForRemoteNotifications()
            self.supportText.text = "1度だけ水平面をタップしてください"
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


