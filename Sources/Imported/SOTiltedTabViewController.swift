//
//  SOTiltedTabViewController.swift
//  UserInterface
//
//  Created by Ian McDowell on 12/30/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

@_exported import TiltedTabView

public protocol SOTiltedTabViewControllerDelegate: TiltedTabViewControllerDelegate {}
public protocol SOTiltedTabViewControllerDataSource: TiltedTabViewControllerDataSource {}
open class SOTiltedTabViewController: TiltedTabViewController {}
