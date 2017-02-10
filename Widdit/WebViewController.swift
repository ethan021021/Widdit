//
//  WebViewController.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 21.01.17.
//  Copyright © 2017 John McCants. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var webView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_reply_close"), style: .Done, target: self, action: #selector(webViewCloseTapped))
        webView.frame = view.bounds
        webView.delegate = self
        view.addSubview(webView)
        
    }
    
    func makeRequest(url: NSURL) {
        showHud()
        webView.loadRequest(NSURLRequest(URL: url))
        title = url.host!
    }
    
    func webViewCloseTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        hideHud()
    }
}
