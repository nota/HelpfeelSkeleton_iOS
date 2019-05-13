//
//  HelpfeelViewController.swift
//  HelpfeelSkeleton2
//
//  Created by daiki on 2019/04/22.
//  Copyright © 2019 daiiz. All rights reserved.
//

import UIKit
import WebKit

class HelpfeelViewController: UIViewController, UIGestureRecognizerDelegate, WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    private var webViewUrl = ""
    
    @IBAction
    func closeSelf(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction
    func historyBack(sender: UIButton) {
        if (self.webView.canGoBack) {
            // history stackがあればbrower backする
            self.webView.goBack()
        } else {
            // 呼び出し元のVCに戻る
            self.navigationController!.popViewController(animated: true)
        }
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
        self.view.addSubview(self.webView)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        
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
    
    func isSameUrl (a: String, b: String) -> Bool {
        // remove a trailing slash
        let _a = a.hasSuffix("/") ? String(a.dropLast()) : a
        let _b = b.hasSuffix("/") ? String(b.dropLast()) : b
        return _a == _b
    }
    
    func attachNavItemButtons() {
        let chatSupportButton = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(HelpfeelViewController.openChatSupport(sender:)))
        self.navigationItem.rightBarButtonItem = chatSupportButton
    }
    
    // リクエスト前
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url!.absoluteString
        print("### " + url)
        if (isSameUrl(a: self.webViewUrl, b: url)) {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
        // TODO:
        if (url.contains(".stripe.")) {
            return
        }
        let vc = storyboard!.instantiateViewController(withIdentifier: "helpfeelVC3")
        setupNextVC(url: url, button: 101, vc: vc) // buttonPrevious
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    // レスポンス取得後
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // 読み込み完了
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let pageTitle = webView.title!
//        self.navigationItem.title = pageTitle
        print(pageTitle)
    }
    
    func setupNextVC(url: String, button: Int, vc: UIViewController) {
        (vc as? HelpfeelViewController)?.webViewUrl = url
        var item = vc.navigationItem
        if let navController = vc as? UINavigationController {
            item = navController.topViewController!.navigationItem
        }
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: button)!, target: self, action: #selector(historyBack(sender:)))
        leftButton.tintColor = UIColor.darkGray
        item.hidesBackButton = true
        item.leftBarButtonItem = leftButton
        item.leftItemsSupplementBackButton = true
        item.title = "Your app guide"
    }

    var detailItem: String? {
        didSet {
//            configureView()
        }
    }
}
