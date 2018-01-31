//
//  ViewController.swift
//  ScaledCarouselLayout
//
//  Created by Meggapixxel on 01/31/2018.
//  Copyright (c) 2018 Meggapixxel. All rights reserved.
//

import UIKit
import ScaledCarouselLayout

class ViewController: CarouselLayoutVC {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        
        // do your stuff
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarouselCell
        cell.set(String(indexPath.row))
        return cell
    }
    
}

class CarouselCell: UICollectionViewCell {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var backView: UIView!
    
    func set(_ text: String) {
        label.text = text
        backView.backgroundColor = .random
    }
    
}

extension CGFloat {
    
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
}

extension UIColor {
    
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
    
}
