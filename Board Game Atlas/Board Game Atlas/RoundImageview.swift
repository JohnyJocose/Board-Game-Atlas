//
//  RoundImageview.swift
//  Board Game Atlas
//
//  Created by Johnathan uijon on 3/5/23.
//

import UIKit

// extension that will make my profile Pictures have a round border
// (which will be found in the Profile and ChangeUsername File)
extension UIImageView {
    func roundedImage() {
        
        self.layer.cornerRadius = (self.frame.size.width) / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor.black.cgColor
    }
}
