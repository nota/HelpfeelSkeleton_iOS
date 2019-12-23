//
//  HelpfeelViewController.swift
//  HelpfeelSkeleton2
//
//  Created by daiki on 2019/04/22.
//  Copyright © 2019 daiiz. All rights reserved.
//

import UIKit
import WebKit
import Speech

let appName = "helpfeelSkeleton"

func isSameUrl (a: String, b: String) -> Bool {
    // remove a trailing slash
    let _a = a.hasSuffix("/") ? String(a.dropLast()) : a
    let _b = b.hasSuffix("/") ? String(b.dropLast()) : b
    return _a == _b
}

func isHelpfeelRootUrl (url: String) -> Bool {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return isSameUrl(a: url, b: appDelegate.helpfeelUrl!)
}

class HelpfeelViewController: UIViewController, UIGestureRecognizerDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, SFSpeechRecognizerDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == appName {
            let body = message.body as! String
            switch body {
            case "button:L":
                requestRecognizerAuthorization()
            case "button:R":
                if audioEngine.isRunning {
                    audioEngine.stop()
                    recognitionRequest?.endAudio()
                    print("audioEngine is stopped.")
                }
            default:
                break
            }
        }
    }
    
    @IBOutlet var webView: WKWebView!
    private var webViewUrl = ""

    private static let processPool = WKProcessPool()
    
    // 音声入力の設定
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
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
    
    // Initialize webView and add to subview
    func initWkWebView () {
        // Share session between WebViews
        let webViewConfiguration = WKWebViewConfiguration()
        let processPool = HelpfeelViewController.processPool
        webViewConfiguration.processPool = processPool
        
        // WebView内に表示したページからメッセージを受け取るための設定
        let userController: WKUserContentController = WKUserContentController()
        userController.add(self, name: appName)
        webViewConfiguration.userContentController = userController
        
        // Set webView size
        let statusBarHeight: CGFloat! = UIApplication.shared.statusBarFrame.height
        self.webView = WKWebView(
            frame: CGRect(x: 0, y: statusBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - statusBarHeight),
            configuration: webViewConfiguration)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizer.delegate = self; // 音声入力の設定
        
        self.initWkWebView()
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
    
    func attachNavItemButtons() {
        let chatSupportButton = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(HelpfeelViewController.openChatSupport(sender:)))
        self.navigationItem.rightBarButtonItem = chatSupportButton
    }
    
    // リクエスト前
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url!.absoluteString
        if (isSameUrl(a: self.webViewUrl, b: url)) {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
        if (!url.hasPrefix("http://") && !url.hasPrefix("https://")) {
            return
        }
        if (isHelpfeelRootUrl(url: url)) {
            // Return to the root of the transition history
            self.navigationController!.popToRootViewController(animated: true)
            return
        }
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
    private func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.title = webView.title!
    }
    
    // 音声入力
    private func requestRecognizerAuthorization () {
        SFSpeechRecognizer.requestAuthorization({ authStates in
            // ここはメインスレッドでは実行されない
            // メインスレッドの更新のために参照したいのでOpetationQueueに登録する
            OperationQueue.main.addOperation { [weak self] in
                guard self != nil else { return }
                switch authStates {
                case .authorized:
                    print("authorized")
                    // 音声認識を開始
                    try! self!.startRecording()
                case .denied:
                    print("denied")
                case .restricted:
                    print("restricted") // この端末では許可されなかった
                case .notDetermined:
                    print("notDetermined")
                }
            }
        })
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
        item.title = ""
    }
    
    private func startRecording () throws {
        // 前回のタスクが残っている場合はクリアする
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record)
        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setActive(true)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode: AVAudioInputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard self != nil else { return }
            var isFinal = false
            if (result != nil) {
                let fullText = result!.bestTranscription.formattedString
                isFinal = result!.isFinal
                // TODO: WebView内のウェブページに送る
                print("###", fullText)
            }
            if error != nil || isFinal {
                self!.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self!.recognitionRequest = nil
                self!.recognitionTask = nil
            }
        }
        
        // 収録した音声バッファをrecognitionRequestに追加する
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}
