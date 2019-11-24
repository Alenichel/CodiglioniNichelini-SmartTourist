//
//  WelcomeView.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni on 24/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import UIKit


/// A view to ask the user for location and notification permissions
class WelcomeView: UIScrollView {
    var pageViewController = UIPageViewController()
    
    func setup() {
        self.addSubview(self.pageViewController.view)
    }
    
    func style() {
        
    }
    
    override func layoutSubviews() {
        
    }
}
