//
//  GlobalFunctions.swift
//  EasyLeARn
//
//  Created by Califano Francesco on 10/03/18.
//  Copyright © 2018 Califano Francesco. All rights reserved.
//

import UIKit
import ARKit

//Button animation
func animateButton(images: [UIImage], button: UIButton){
    button.imageView?.animationImages = images
    button.imageView?.animationDuration = 0.5
    button.imageView?.animationRepeatCount = 0
    button.imageView?.startAnimating()
}

//ImageView animation
func animateImageView(images: [UIImage], view: UIImageView, duration: TimeInterval){
    view.stopAnimating()
    view.animationImages = images
    view.animationDuration = duration
    view.animationRepeatCount = 0
    view.startAnimating()
}

//Sum of two vectors
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z )
}
