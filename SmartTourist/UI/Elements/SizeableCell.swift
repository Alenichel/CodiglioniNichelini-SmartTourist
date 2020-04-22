//
//  SizeableCell.swift
//  SmartTourist
//
//  Created on 21/04/2020
//

import UIKit
import Tempura


public protocol SizeableCell: ModellableView {
    static func size(for model: VM) -> CGSize
}
