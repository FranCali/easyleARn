//
//  GamesMenuViewController.swift
//  EasyLearn
//
//  Created by Califano Francesco on 07/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit

class GamesMenuViewController: UIViewController, UICollectionViewDataSource {
   
    var imgBasketArray = [UIImage]()
    var imgBalloonsArray = [UIImage]()
    
    var basketballImages = [UIImage]()
    var golfImages = [UIImage]()
    var nerfImages = [UIImage]()
    @IBOutlet weak var basketballCollectionView: UICollectionView!
    @IBOutlet weak var golfCollectionView: UICollectionView!
    @IBOutlet weak var nerfCollectionView: UICollectionView!
    
    
    @IBOutlet weak var basketButton: UIButton!
    @IBOutlet weak var balloonsButton: UIButton!
    
    
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
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgBasketArray.append(UIImage(named:"Basket-1")!)
        imgBasketArray.append(UIImage(named:"Basket-2")!)
        
        imgBalloonsArray.append(UIImage(named:"Balloons-1")!)
        imgBalloonsArray.append(UIImage(named:"Balloons-2")!)
    }

    override func viewDidAppear(_ animated: Bool) {
        animateButton(images: imgBasketArray, button: basketButton)
        animateButton(images: imgBalloonsArray, button: balloonsButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "playBalloons"){
            let destViewController = segue.destination as! BalloonViewController
            destViewController.nerfImages = self.nerfImages
            destViewController.basketballImages = self.basketballImages

        }else if(segue.identifier == "playBasket"){
            let destViewController = segue.destination as! BasketController
            destViewController.basketballImages = self.basketballImages
            destViewController.nerfImages = self.nerfImages

        } else {
            let destViewController = segue.destination as! ViewController
            destViewController.isTutorialEnabled = false
        }
        
        
        
        
        
    }
   

}
