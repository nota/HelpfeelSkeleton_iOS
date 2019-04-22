//
//  HelpfeelViewController.swift
//  HelpfeelSkeleton2
//
//  Created by daiki on 2019/04/22.
//  Copyright © 2019 daiiz. All rights reserved.
//

import UIKit
import WebKit

class HelpfeelViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    private var webViewUrl: String = "https://helpfeel.notainc.com/SFCHelp"
    
    @IBAction func goBack(sender: UIButton) {
        if (self.webView.canGoBack) {
            self.webView.goBack()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        if let url = URL(string: self.webViewUrl) {
            self.webView.load(URLRequest(url: url))
        }
        // swipeでの戻る進むを許可
        self.webView.allowsBackForwardNavigationGestures = true
        self.attachToolbarItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func attachToolbarItems() {
        let historyBackButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(HelpfeelViewController.goBack(sender:)))
        toolBar.items = [historyBackButton]
    }
    
    var detailItem: String? {
        didSet {
//            configureView()
        }
    }
}
