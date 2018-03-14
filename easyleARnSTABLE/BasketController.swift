//
//  BasketController.swift
//  iLeARn
//
//  Created by Menichino Alfonso on 06/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit
import ARKit

enum BitMaskCategory: Int {
    case ball = 2
    case net = 3
    case collider = 4
    case ground = 5

}

class BasketController: UIViewController,SCNPhysicsContactDelegate, UICollectionViewDataSource, ARSCNViewDelegate {
   
    
    
    @IBOutlet weak var basketballCollectionView: UICollectionView!
    var basketballImages = [UIImage]()
    var nerfImages = [UIImage]()
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var testo: UILabel!
    
    @IBOutlet weak var mirino: UIButton!
    
    var colorsPlayer: AVAudioPlayer?

    
    let configuration = ARWorldTrackingConfiguration()
    
    let colorsDictionaryEN = [UIColor.red:"red", UIColor.green:"green", UIColor.black:"black", UIColor.brown:"brown", UIColor.blue:"blue", UIColor.purple:"violet", UIColor.gray:"gray", UIColor.orange:"orange"]
    
    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.black, UIColor.brown, UIColor.purple, UIColor.gray, UIColor.orange]
    
    let colorsDictionaryIT = [UIColor.red:"rosso", UIColor.green:"verde", UIColor.black:"nero", UIColor.brown:"marrone", UIColor.blue:"blu", UIColor.purple :"viola", UIColor.gray:"grigio", UIColor.orange:"arancione"]
    
    
    let colorsStringsIT = ["rosso", "verde", "blu", "nero", "marrone", "viola", "grigio", "arancione"]
    
    var colorsDictionary = [UIColor:String]()
    
    var indexForColor: Int?
    
    var trigger: SCNNode?
    var existTrigger: Bool = false
    
    var target : SCNNode?
    
    var basketAdded:Bool = false
    
    var power: Float = 10
    
    let ball = SCNNode(geometry: SCNSphere(radius: 0.2))

    var ballAdded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change dictionary and string array of colors in relation to device language
        if NSLocale.preferredLanguages[0] == "it-IT" {
            colorsDictionary = colorsDictionaryIT
        }else {
            colorsDictionary = colorsDictionaryEN
        }
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        self.configuration.planeDetection = .horizontal
        
        self.sceneView.session.run(configuration)
        
        self.sceneView.autoenablesDefaultLighting = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        self.sceneView.delegate = self

        ball.name = "ball"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        var imgArray = [UIImage]()

        imgArray.append(UIImage(named: "Home-1")!)
        imgArray.append(UIImage(named: "Home-2")!)
        
        animateButton(images: imgArray, button: homeButton)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        
        //guard let sceneView = sender.view as? ARSCNView else {return}
        
        guard let pointOfView = sceneView.pointOfView else {return}
        
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        
        if self.basketAdded == false{
            
            addBasket(x: position.x , y: position.y , z: -2.5)
            
            self.basketAdded = true;
            
            if(!basketballImages.isEmpty){
                DispatchQueue.main.async {
                    self.loadBall()
                }
            }
        }
            
        else{
            if(!basketballImages.isEmpty){
                basketballImages.removeLast()
                basketballCollectionView.reloadData()
                                
                if !self.existTrigger{
                    createTrigger()
                    self.existTrigger = true
                }
                
                self.ballAdded = false
                
                
                let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball))
                
                ball.physicsBody = body
                
                ball.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
                
                
                ball.physicsBody?.categoryBitMask = BitMaskCategory.ball.rawValue
                ball.physicsBody?.collisionBitMask = BitMaskCategory.net.rawValue | BitMaskCategory.collider.rawValue
                ball.physicsBody?.contactTestBitMask = BitMaskCategory.collider.rawValue
            }
        }
        
    }
    
    func loadBall(){
        
        self.removeOtherBall()
        
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        
        self.indexForColor = Int(randomNumbers(from: 0, to: CGFloat(colors.count)))
        
        let colorToUse = colors[indexForColor!]
        
        ball.geometry?.firstMaterial?.diffuse.contents = colorToUse
        
        let ballPosition = SCNVector3(0,-0.3,0) + position
        
        ball.position = ballPosition
        
        let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: ball))
        
        ball.physicsBody = body
        
        ball.physicsBody?.categoryBitMask = BitMaskCategory.ball.rawValue
        ball.physicsBody?.collisionBitMask = BitMaskCategory.net.rawValue | BitMaskCategory.collider.rawValue
        ball.physicsBody?.contactTestBitMask = BitMaskCategory.collider.rawValue | BitMaskCategory.ground.rawValue
        
        self.sceneView.scene.rootNode.addChildNode(ball)
        
        self.ballAdded = true
        
    }
    
    func addBasket(x: Float, y: Float, z: Float){
        
        let basketScene = SCNScene(named: "Media.scnassets/BasketField.scn")
        
        let basketNode = (basketScene?.rootNode.childNode(withName: "Basket", recursively: false))!
        
        let collider = (basketScene?.rootNode.childNode(withName: "collider", recursively: false))!
        
        let floor = (basketScene?.rootNode.childNode(withName: "floor", recursively: false))!
        
        basketNode.position = SCNVector3(x,y,z)
        
        basketNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: basketNode, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        basketNode.physicsBody?.restitution = 0.2
        
        collider.position = SCNVector3(x,y+1.5,z-3.1)
        
        collider.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: collider, options: nil))
        
        floor.position = SCNVector3(x,y-3,z-3.5)
        
        floor.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: floor, options: nil))
        
        floor.physicsBody?.categoryBitMask = BitMaskCategory.ground.rawValue
        floor.physicsBody?.collisionBitMask = BitMaskCategory.ball.rawValue
        floor.physicsBody?.contactTestBitMask = BitMaskCategory.ball.rawValue
        
        basketNode.physicsBody?.categoryBitMask = BitMaskCategory.net.rawValue
        basketNode.physicsBody?.collisionBitMask = BitMaskCategory.ball.rawValue
        
        collider.physicsBody?.categoryBitMask = BitMaskCategory.collider.rawValue
        //        collider.physicsBody?.collisionBitMask = BitMaskCategory.ball.rawValue
        collider.physicsBody?.contactTestBitMask = BitMaskCategory.ball.rawValue
        
        trigger = collider.clone()
        
        self.sceneView.scene.rootNode.addChildNode(basketNode)
        self.sceneView.scene.rootNode.addChildNode(floor)
        
    }
    
    
    func createTrigger(){
        self.sceneView.scene.rootNode.addChildNode(trigger!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeOtherBall(){
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in
            if node.name == "ball"{
                node.removeFromParentNode()
            }
        }
    }
    
    func randomNumbers(from firstNum: CGFloat, to secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    func playSoundByKey(key:String) {
        
        if NSLocale.preferredLanguages[0] == "it-IT" {
            guard let url = Bundle.main.url(forResource: "ColorsIT/\(key)", withExtension: "wav") else { return}
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                colorsPlayer = try AVAudioPlayer(contentsOf: url)
                guard let colorsPlayer = self.colorsPlayer else { return }
                
                colorsPlayer.play()
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }else {
            guard let url = Bundle.main.url(forResource: "ColorsEN/\(key)", withExtension: "wav") else { return}
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                colorsPlayer = try AVAudioPlayer(contentsOf: url)
                guard let colorsPlayer = self.colorsPlayer else { return }
                
                colorsPlayer.play()
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        var color : UIColor?
        
        if nodeA.name == "floor" || nodeB.name == "floor"{
            if nodeA.name == "ball"{
                target = nodeA
            }
            else if nodeB.name == "ball"{
                target = nodeB
            }
            
            target?.removeFromParentNode()
            self.existTrigger = false
            self.loadBall()
            self.createTrigger()
            
            return
        }
        
        if nodeA.name == "collider"{
            
            self.target = nodeA
            target?.removeFromParentNode()
            
        } else if nodeB.name == "collider" {
            
            self.target = nodeB
            target?.removeFromParentNode()
        }
        
        if nodeA.name == "ball"{
            
            color = nodeA.geometry?.firstMaterial?.diffuse.contents as? UIColor
            
        } else if nodeB.name == "ball" {
            
            color = nodeB.geometry?.firstMaterial?.diffuse.contents as? UIColor
        }
        
        // changing the text and play audio
        DispatchQueue.main.async(){
            
            if self.testo.isHidden{
                self.testo.isHidden = false
            }
            let colore: String = (self.colorsDictionary[color!]?.description)!
            self.testo.text = colore
            self.playSoundByKey(key:colore)
            self.testo.textColor = color
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if self.ballAdded {
            guard let pointOfView = sceneView.pointOfView else { return }
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let position = orientation + location
            
            let ballPosition = SCNVector3(0,-0.3,0) + position
            
            ball.position = ballPosition
        }
        
    }
        
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return basketballImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basketballCell", for: indexPath) as! BasketballCollectionViewCell
        
        cell.imageView.image = basketballImages[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destViewController = segue.destination as! GamesMenuViewController
        destViewController.basketballImages = self.basketballImages
        destViewController.nerfImages = self.nerfImages
    }

}


