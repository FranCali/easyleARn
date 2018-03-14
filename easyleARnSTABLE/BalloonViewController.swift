//
//  BalloonViewController.swift
//  StARt
//
//  Created by Califano Francesco on 08/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit
import ARKit


class BalloonViewController: UIViewController, UICollectionViewDataSource, SCNPhysicsContactDelegate{
    
    var player: AVAudioPlayer?
    var colorsPlayer: AVAudioPlayer?
    
    @IBOutlet weak var nerfCollectionView: UICollectionView!
    var nerfImages = [UIImage]()
    var basketballImages = [UIImage]()
    
    let colorsDictionaryEN = ["red":UIColor.red, "green":UIColor.green, "black":UIColor.black, "brown":UIColor.brown, "blue":UIColor.blue, "purple":UIColor.purple, "gray":UIColor.gray, "orange":UIColor.orange]
    let colorsStringsEN = ["red", "green", "blue", "black", "brown", "purple", "gray", "orange"]
    let colorsDictionaryIT = ["rosso":UIColor.red, "verde":UIColor.green, "blu":UIColor.blue, "nero":UIColor.black, "marrone":UIColor.brown, "viola":UIColor.purple, "grigio":UIColor.gray, "arancione":UIColor.orange]
    let colorsStringsIT = ["rosso", "verde", "blu", "nero", "marrone", "viola", "grigio", "arancione"]
    
    var colorsStrings = [String]()
    var colorsDictionary = [String:UIColor]()
    
    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.black, UIColor.brown, UIColor.purple, UIColor.gray, UIColor.orange]
    var colorToFind:String?
    var pickedColors = [Int](repeating: 0, count:8)
    
    enum BitMaskCategory: Int {
        case bullet = 2
        case target = 3
    }
    
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power:Float = 10
    var Target:SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run(configuration)
        //        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.autoenablesDefaultLighting = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(gestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        //Change dictionary and string array of colors in relation to device language
        if NSLocale.preferredLanguages[0] == "it-IT" {
            colorsStrings = colorsStringsIT
            colorsDictionary = colorsDictionaryIT
        }else {
            colorsStrings = colorsStringsEN
            colorsDictionary = colorsDictionaryEN
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var imgArray = [UIImage]()
        imgArray.append(UIImage(named: "Home-1")!)
        imgArray.append(UIImage(named: "Home-2")!)
        animateButton(images: imgArray, button: homeButton)
        addTargets()
        showColorLabel()
    }
    
    
    func showColorLabel() {
        var colorIndex:Int
        repeat{
            colorIndex = Int(randomNumbers(firstNum: 0, secondNum: CGFloat(self.colors.count)))
        }while(pickedColors[colorIndex] != 0)
        pickedColors[colorIndex] = 1
        self.colorLabel.text = colorsStrings[colorIndex]
        colorToFind = self.colorLabel.text
        playSoundByKey(key: colorsStrings[colorIndex])
        UIView.animate(withDuration: 2, animations: {self.colorLabel.alpha = 1})
    }
    func hideColorLabel() {
        UIView.animate(withDuration: 2, animations: {self.colorLabel.alpha = 0})
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        
        
        if(nerfImages.count > 0){
            self.nerfImages.removeLast()
            self.nerfCollectionView.reloadData()
            let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
            bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            bullet.position = position
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
            body.isAffectedByGravity = false
            bullet.physicsBody = body
            bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
            self.sceneView.scene.rootNode.addChildNode(bullet)
            bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
            bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
            bullet.runAction(SCNAction.sequence([SCNAction.wait(duration: 2), SCNAction.removeFromParentNode()]))
            playSound(filename: "BulletFire", fileextension: "wav", volume: 1)
        } else{
            
        }
        
    }
    
    func addTargets() {
        for colorIndex in 0..<colors.count {
            let balloonNode = self.addBalloon(x: Float(randomNumbers(firstNum: -3, secondNum: 3)), y: Float(randomNumbers(firstNum: 0, secondNum: 1)), z: Float(randomNumbers(firstNum: -2, secondNum: -4)))
            
            let geometry = balloonNode.geometry!
            
            for index in 0..<geometry.materials.count {
                balloonNode.geometry?.materials[index].diffuse.contents = colors[colorIndex]
            }
        }
    }
    
    
    
    func addBalloon(x: Float, y: Float, z: Float) -> SCNNode{
        let balloonScene = SCNScene(named: "Media.scnassets/Balloon.scn")
        let balloonNode = (balloonScene?.rootNode.childNode(withName: "balloon", recursively: false))!
        balloonNode.position = SCNVector3(x,y,z)
        balloonNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: balloonNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: SCNVector3(2,2,2)]))
        balloonNode.physicsBody = body
        balloonNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        balloonNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        self.sceneView.scene.rootNode.addChildNode(balloonNode)
        animateBalloon(balloon: balloonNode)
        return balloonNode
    }
    
    func animateBalloon(balloon:SCNNode) {
        let xMovement = randomNumbers(firstNum: -2, secondNum: 2)
        let yMovement = randomNumbers(firstNum: -2, secondNum: 2)
        let animation = SCNAction.sequence([SCNAction.move(by: SCNVector3(xMovement,yMovement,0), duration: 2), SCNAction.move(by: SCNVector3(-xMovement,-yMovement,0), duration: 2)])
        let foreverAnimation = SCNAction.repeatForever(animation)
        balloon.runAction(foreverAnimation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        let confetti = SCNParticleSystem(named: "Media.scnassets/Confetti.scnp", inDirectory: nil)
        confetti?.loops = false
        //      confetti?.particleLifeSpan = 4
        //      confetti?.emitterShape = Target?.geometry
        let confettiNode = SCNNode()
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue &&
            nodeB.physicsBody?.categoryBitMask == BitMaskCategory.bullet.rawValue{
            self.Target = nodeA
            confettiNode.addParticleSystem(confetti!)
            confettiNode.position = contact.contactPoint
            
            if isRightColor(colorLabel: colorToFind!, balloonColor: Target?.geometry?.firstMaterial?.diffuse.contents as! UIColor) {
                self.sceneView.scene.rootNode.addChildNode(confettiNode)
                Target?.removeFromParentNode()
                
                playSound(filename: "BalloonPop", fileextension: "wav", volume: 1)
            }
            
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue &&
            nodeA.physicsBody?.categoryBitMask == BitMaskCategory.bullet.rawValue{
            self.Target = nodeB
            confettiNode.addParticleSystem(confetti!)
            confettiNode.position = contact.contactPoint
            
            if isRightColor(colorLabel: colorToFind!, balloonColor: Target?.geometry?.firstMaterial?.diffuse.contents as! UIColor) {
                self.sceneView.scene.rootNode.addChildNode(confettiNode)
                Target?.removeFromParentNode()
                
                playSound(filename: "BalloonPop", fileextension: "wav", volume: 1)
            }
        }
    }
    
    func isRightColor(colorLabel:String, balloonColor:UIColor) -> Bool{
        if colorsDictionary[colorLabel] == balloonColor {
            DispatchQueue.main.async {
                if(!self.areAllColorsPicked()){
                    self.showColorLabel()
                }
            }
            return true
        }
        return false
    }
    
    func areAllColorsPicked()->Bool {
        var countPicked = 0
        for index in 0..<pickedColors.count {
            if(pickedColors[index] == 1){
                countPicked+=1
            }
        }
        if(countPicked == pickedColors.count){
            return true
        }
        return false
    }
    
    func playSound(filename:String, fileextension:String, volume:Float) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileextension) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.volume = volume
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nerfImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nerfCell", for: indexPath) as! NerfCollectionViewCell
        
        cell.imageView.image = nerfImages[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destViewController = segue.destination as! GamesMenuViewController
        destViewController.nerfImages = self.nerfImages
        destViewController.basketballImages = self.basketballImages
    }
}

