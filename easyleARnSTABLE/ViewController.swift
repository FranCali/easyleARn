//
//  ViewController.swift
//  EasyLearn
//
//  Created by Califano Francesco on 06/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//
import UIKit
import ARKit
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var teacherImageView: UIImageView!

    var player: AVAudioPlayer?

    @IBOutlet weak var backpackButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var basketballCollectionView: UICollectionView!
    @IBOutlet weak var golfCollectionView: UICollectionView!
    @IBOutlet weak var nerfCollectionView: UICollectionView!
    
    var countedObjects = 0
    var numbersAudioURLContainer:[URL]?
    var alreadyTapped = false
    var isTutorialEnabled:Bool = true
    
    //Arrays and images for  collection views
    let basketballImage = UIImage(named: "Basketball")
    let golfBallImage = UIImage(named: "GolfBall")
    let nerfImage = UIImage(named: "NerfDart")
    var basketballImages = [UIImage]()
    var golfImages = [UIImage]()
    var nerfImages = [UIImage]()
    var basketBallsCollection = [SCNNode]()
    var golfBallsCollection = [SCNNode]()
    var nerfDartsCollection = [SCNNode]()
    
    let total3DModelsNumber = 20
    
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Session configuring and running operation
        sceneView.autoenablesDefaultLighting = true
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap) )
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        load3DModels()
        fillURLArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    override func viewDidAppear(_ animated: Bool) {

        
        animateBackpack()
        
        teacherImageView.isHidden=true
//        if(isTutorialEnabled) {
//            startTutorial()
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// Custom animation applied after tapping on object
    func slideDown(_ node:SCNNode){
//        let collectionViewX = basketballCollectionView.frame.origin.x
//        let collectionViewY = basketballCollectionView.frame.origin.y
        
        let fadeOutAction = SCNAction.fadeOut(duration: 0.5)
        let moveToOriginAction = SCNAction.move(to: SCNVector3(0,0,0), duration: 0.5)
        node.runAction(fadeOutAction, completionHandler: {node.removeFromParentNode();self.alreadyTapped = false
        })
        node.runAction(moveToOriginAction)
    }
    
    func showNumberLabel(number: Int) {
        numberLabel.text = String(number)

        UIView.animate(withDuration: 2, animations: {
            self.numberLabel.alpha = 1
        }, completion: { (terminated) in
            UIView.animate(withDuration: 2, animations: {self.numberLabel.alpha = 0})
        })
    }
    
    
//Set of animations for Teacher
    
    func animateTeacherToCollectionViews(){
        self.teacherImageView.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 2, animations: {
            self.teacherImageView.center.x = (self.basketballCollectionView.center.x-(self.basketballCollectionView.bounds.width/2)+100)
            self.teacherImageView.center.y = (self.basketballCollectionView.center.y - (self.basketballCollectionView.bounds.height/2)-20)

        }, completion: {
            (terminated) in
            
            if NSLocale.preferredLanguages[0] == "it-IT" {
                self.playSound(filename: "TutorialIT/Tutorial-2", fileextension: "wav", volume: 1)
            }else {
                self.playSound(filename: "TutorialEN/Tutorial-2", fileextension: "wav", volume: 1)
            }
        })
    }
    
    func animateTeacherToBackpack(){
        self.teacherImageView.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 2, animations: {
            self.teacherImageView.center.x = (self.backpackButton.center.x-(self.backpackButton.bounds.width/2)-70)
            self.teacherImageView.center.y = (self.teacherImageView.center.y)
            
        }, completion: {
            (terminated) in
            if NSLocale.preferredLanguages[0] == "it-IT" {
                self.playSound(filename: "TutorialIT/Tutorial-3", fileextension: "wav", volume: 1)
            }else {
                self.playSound(filename: "TutorialEN/Tutorial-3", fileextension: "wav", volume: 1)
            }
        })
    }
    
    func animateTeacher(){
        var imgArray=[UIImage]()
        imgArray.append(UIImage(named: "Teacher-1")!)
        imgArray.append(UIImage(named: "Teacher-2")!)
        animateImageView(images: imgArray, view: self.teacherImageView, duration: 2)
    }
    
    func animateTeacherReversed(){
        self.teacherImageView.stopAnimating()
        var imgArray=[UIImage]()
        imgArray.append(UIImage(named: "TeacherReversed-1")!)
        imgArray.append(UIImage(named: "TeacherReversed-2")!)
        animateImageView(images: imgArray, view: self.teacherImageView, duration: 2)
    }

    func animateBackpack(){
        var imgArray = [UIImage]()
        imgArray.append(UIImage(named:"Backpack-1")!)
        imgArray.append(UIImage(named:"Backpack-2")!)
        
        animateButton(images: imgArray, button: backpackButton)
    }
    
    func startTutorial(){
        self.teacherImageView.isHidden = false
        self.teacherImageView.translatesAutoresizingMaskIntoConstraints = true
        animateTeacher()
        if NSLocale.preferredLanguages[0] == "it-IT" {
            self.playSound(filename: "TutorialIT/Tutorial-1", fileextension: "wav", volume: 1)
        }else {
            self.playSound(filename: "TutorialEN/Tutorial-1", fileextension: "wav", volume: 1)
        }
    }
    
//End animations
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if hitTest.isEmpty{
            //print("didn't touch anything")
        }
        else{
            let results = hitTest.first!
            let node = results.node
            let name = results.node.name
            
//
//            if(isTutorialEnabled) {
//                //Teacher animations for tutorial
//                if(countedObjects == 0){
//                    animateTeacherReversed()
//                    animateTeacherToCollectionViews()
//                }
//                if(countedObjects == 3){
//                    animateTeacher()
//                    animateTeacherToBackpack()
//                }
//                //End teacher animations
//            }
            
            if(!alreadyTapped){
                playSoundAtIndex(index: countedObjects)

                countedObjects+=1

                showNumberLabel(number: countedObjects)
            }
            
            if(name == "Basketball"){
                //node.removeFromParentNode()
                if(!alreadyTapped) {
                    basketballImages.append(basketballImage!)
                    basketballCollectionView.reloadData()
                    alreadyTapped = true
                    slideDown(node)
                }
            }else if(name == "GolfBall"){
                //node.removeFromParentNode()
                if(!alreadyTapped){
                    golfImages.append(golfBallImage!)
                    golfCollectionView.reloadData()
                    alreadyTapped = true
                    slideDown(node)
                }
            }else {
               //node.removeFromParentNode()
                if(!alreadyTapped){
                nerfImages.append(nerfImage!)
                nerfCollectionView.reloadData()
                alreadyTapped = true
                slideDown(node)
                }
            }
        }
    }
    
    func addNode(sceneName:String) -> SCNNode{
        let scene = SCNScene(named: sceneName)
        let node = scene?.rootNode.childNodes.first
        node?.position = SCNVector3(randomNumbers(firstNum: -3, secondNum: 3), randomNumbers(firstNum: -1, secondNum: 1.5), randomNumbers(firstNum: 2, secondNum: -2))
        node?.eulerAngles = SCNVector3(randomNumbers(firstNum: CGFloat(0.degreesToRadians), secondNum: CGFloat(360.degreesToRadians)),randomNumbers(firstNum: CGFloat(0.degreesToRadians), secondNum: CGFloat(360.degreesToRadians)),randomNumbers(firstNum: CGFloat(0.degreesToRadians), secondNum: CGFloat(360.degreesToRadians))
        )
        
        let animRotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 360, z: 0, duration: 300))
        let moveForw = SCNAction.moveBy(x: 1, y: 0, z: 0, duration: 10)
        let moveBack = SCNAction.moveBy(x: -1, y: 0, z: 0, duration: 10)
        let moveGroup = SCNAction.sequence([moveForw,moveBack])
        
        node?.runAction(animRotate)
        node?.runAction(moveGroup)
        
        self.sceneView.scene.rootNode.addChildNode(node!)
        return node!
    }
    
//    Generates 20 random models
    func load3DModels() {
        
        for _ in 0..<total3DModelsNumber {
            let randomIndex = Int(randomNumbers(firstNum: 0, secondNum: 3))
            
            switch(randomIndex) {
            case 0: basketBallsCollection.append(addNode(sceneName: "Media.scnassets/Basketball.scn"))
                
            case 1: golfBallsCollection.append(addNode(sceneName: "Media.scnassets/Golfball.scn"))
                
            case 2: nerfDartsCollection.append(addNode(sceneName: "Media.scnassets/Nerf.scn"))
                
            default: return
                
            }
        }
    }
    
    
    
    
    //Collection View delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == self.basketballCollectionView){
            return basketballImages.count
        } else if(collectionView == self.golfCollectionView){
            return golfImages.count
        } else {
            return nerfImages.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.basketballCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basketballCell", for: indexPath) as! BasketballCollectionViewCell
            
            cell.imageView.image = basketballImages[indexPath.row]
            return cell
        } else if(collectionView == self.golfCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "golfCell", for: indexPath) as! GolfCollectionViewCell
            
            cell.imageView.image = golfImages[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nerfCell", for: indexPath) as! NerfCollectionViewCell
            
            cell.imageView.image = nerfImages[indexPath.row]
            return cell
        }
    }
    
    //AUDIO SETTINGS
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
    
    func fillURLArray() {
        //in questo modo ottengo un array di url (dai quali ottengo i file mp3), l'array è ordinato a seconda della disposizione dei file nella directory audioFiles
        numbersAudioURLContainer = []
        for index in 0...19 {
            if NSLocale.preferredLanguages[0] == "it-IT" {
                guard let url = Bundle.main.url(forResource: "Sounds/NumbersIT/\(index+1)", withExtension: "wav") else { return}
                numbersAudioURLContainer?.insert(url, at: index)
            }else {
                guard let url = Bundle.main.url(forResource: "Sounds/NumbersEN/\(index+1)", withExtension: "wav") else { return}
                numbersAudioURLContainer?.insert(url, at: index)
            }
        }
    }
    
    func playSoundAtIndex(index:Int) {
        //array già riempito grazie alla funzione fillArrayUrl
        let url = numbersAudioURLContainer![index]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    //END AUDIO SETTINGS
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destViewController:GamesMenuViewController = segue.destination as! GamesMenuViewController
        destViewController.basketballImages = self.basketballImages
        destViewController.golfImages = self.golfImages
        destViewController.nerfImages = self.nerfImages
        player?.stop()
    }
    
}
func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}


