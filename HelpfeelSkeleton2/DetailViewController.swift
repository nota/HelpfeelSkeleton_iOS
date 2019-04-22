//
//  DetailViewController.swift
//  HelpfeelSkeleton2
//
//  Created by daiki on 2019/04/22.
//  Copyright © 2019 daiiz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
            
            if let navItem = navItem {
                navItem.title = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

