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
    
    private var webViewUrl = ""
    
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
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if (self.webViewUrl.utf8.count == 0) {
          self.webViewUrl = appDelegate.helpfeelUrl!
        }
        
        if let url = URL(string: self.webViewUrl) {
            self.webView.load(URLRequest(url: url))
        }
        // swipeでの戻る進むを許可
        self.webView.allowsBackForwardNavigationGestures = true
        self.attachNavItemButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func attachNavItemButtons() {
        let chatSupportButton = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(HelpfeelViewController.openChatSupport(sender:)))
        self.navigationItem.rightBarButtonItem = chatSupportButton
    }
    
    // リクエスト前
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // レスポンス取得後
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let url = webView.url!.absoluteString
        if (self.webViewUrl.hasPrefix(url) || url.hasPrefix(self.webViewUrl)) {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
        let vc = storyboard!.instantiateViewController(withIdentifier: "helpfeelVC3")
        setupNextVC(url: url, vc: vc)
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    // 読み込み完了
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let pageTitle = webView.title!
//        self.navigationItem.title = pageTitle
        print(pageTitle)
    }
    
    func setupNextVC(url: String, vc: UIViewController) {
        (vc as? HelpfeelViewController)?.webViewUrl = url
        var item = vc.navigationItem
        if let navController = vc as? UINavigationController {
            item = navController.topViewController!.navigationItem
        }
        item.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        item.leftItemsSupplementBackButton = true
        item.title = "Guide"
    }

    
    var detailItem: String? {
        didSet {
//            configureView()
        }
    }
}
