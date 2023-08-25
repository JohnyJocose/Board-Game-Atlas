//
//  LoadingBarCode.swift
//  Board Game Atlas
//
//  Created by Johnathan Huijon on 4/3/23.
//

import Foundation
import UIKit

// extension that will be called in different view controllers that will bring in a loading spinner
// that wont let users do anything on screen

var vSpinnerHome : UIView?

// i found an error that would happen if theres a loading screen with bad signal and the user switches
// to another tab; when they come back the spinner doesnt go away
// thats while i made one for every tab

// Home tab spinner

extension UIViewController {
    func showSpinnerHome(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)

        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinnerHome = spinnerView
    }
    
    func removeSpinnerHome() {
        DispatchQueue.main.async {
            vSpinnerHome?.removeFromSuperview()
            vSpinnerHome = nil
        }
    }
}

// Profile Tab spinner
var vSpinnerProfile : UIView?

extension UIViewController {
    func showSpinnerProfile(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)

        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinnerProfile = spinnerView
    }
    
    func removeSpinnerProfile() {
        DispatchQueue.main.async {
            vSpinnerProfile?.removeFromSuperview()
            vSpinnerProfile = nil
        }
    }
}

// Psuedo home page goes into both tab so i have a special one for PseduoHome file just in case
var vSpinnerPseudo : UIView?

extension UIViewController {
    func showSpinnerPseudo(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)

        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinnerPseudo = spinnerView
    }
    
    func removeSpinnerPseudo() {
        DispatchQueue.main.async {
            vSpinnerPseudo?.removeFromSuperview()
            vSpinnerPseudo = nil
        }
    }
}

