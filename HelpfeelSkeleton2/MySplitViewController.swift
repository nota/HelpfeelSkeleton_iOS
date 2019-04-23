//
//  MySplitViewController.swift
//  HelpfeelSkeleton2
//
//  Created by daiki on 2019/04/23.
//  Copyright © 2019 daiiz. All rights reserved.
//

import UIKit

class MySplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 可能ならMaster, Detailをともに表示する
        preferredDisplayMode = .allVisible
        
        // 起動直後にHomeを表示
        let vc = storyboard!.instantiateViewController(withIdentifier: "homeVC") as UIViewController
        showDetailViewController(vc, sender: self)
    }
}
