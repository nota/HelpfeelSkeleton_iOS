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
    
    @IBAction
    func closeSelf(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func openChatSupport(sender: UIButton) {
        let chatSupportVC = storyboard!.instantiateViewController(withIdentifier: "chatSupportVC") as UIViewController
        let navVC: UINavigationController = UINavigationController(rootViewController: chatSupportVC)
        
        let item = navVC.topViewController!.navigationItem
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeSelf(sender:)))
        item.leftBarButtonItem = closeButton
        item.title = "Chat support"
        self.present(navVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.webViewUrl = appDelegate.helpfeelUrl!
        
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
        let flexbleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let chatSupportButton = UIBarButtonItem(title: "Chat support", style: .plain, target: self, action: #selector(HelpfeelViewController.openChatSupport(sender:)))
        toolBar.items = [historyBackButton, flexbleItem, chatSupportButton]
    }
    
    var detailItem: String? {
        didSet {
//            configureView()
        }
    }
}
