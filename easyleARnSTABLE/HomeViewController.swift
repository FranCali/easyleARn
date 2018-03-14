//
//  HomeViewController.swift
//  StARt
//
//  Created by Califano Francesco on 08/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        var imgArray = [UIImage]()
        
        if NSLocale.preferredLanguages[0] == "it-IT" {
            imgArray.append(UIImage(named:"JoinITA-1")!)
            imgArray.append(UIImage(named:"JoinITA-2")!)
        }else {
            imgArray.append(UIImage(named:"JoinENG-1")!)
            imgArray.append(UIImage(named:"JoinENG-2")!)
        }
        
       animateButton(images: imgArray, button: joinButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("called")

    }
    override func viewDidAppear(_ animated: Bool) {
        var imgArray = [UIImage]()
        imgArray.append(UIImage(named: "welcomePage-1")!)
        imgArray.append(UIImage(named: "welcomePage-2")!)
        imgArray.append(UIImage(named: "welcomePage-3")!)

        animateImageView(images: imgArray, view: imageView, duration: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
