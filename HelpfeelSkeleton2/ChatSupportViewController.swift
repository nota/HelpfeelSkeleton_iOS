//
//  ChatSupportViewController.swift
//  HelpfeelSkeleton2
//
//  Created by daiki on 2019/04/22.
//  Copyright © 2019 daiiz. All rights reserved.
//

import UIKit

class ChatSupportViewController: UIViewController {

    @IBOutlet weak var navBarItem: UINavigationItem!
    
    @IBAction func closeSelf(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attachButtons()
    }
    
    
    func attachButtons() {
//        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(ChatSupportViewController.closeSelf(sender:)))
//        self.navBarItem.leftBarButtonItem = closeButton
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
