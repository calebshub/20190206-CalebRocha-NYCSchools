//
//  SingleWebViewController.swift
//  20190206-CalebRocha-NYCSchools
//
//  Created by Caleb Admin on 2/19/19.
//  Copyright © 2019 Caleb Admin. All rights reserved.
//

import Foundation
import UIKit
import WebKit


class SingleWebViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var webView: WKWebView!
    
    var schoolWebsiteURL : URL?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.webView.navigationDelegate = self
        
        if let webURL = self.schoolWebsiteURL {
            let request = URLRequest(url:webURL)
            webView.navigationDelegate = self
            webView.load(request)
            
        } else {
            // todo: show error, give user chance to return
        }
        
        // setting up the tool bar with navigation buttons
        // going back, forward in navigation, and refreshing the page -> all calling methods of the WKWebView
        let backImage = UIImage(named: "back-arrow")?.withRenderingMode(.alwaysOriginal)
        let backButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: webView, action: #selector(webView.goBack))
        
        let forwardImage = UIImage(named: "forward-arrow")?.withRenderingMode(.alwaysOriginal)
        let forwardButtomItem = UIBarButtonItem(image: forwardImage, style: .plain, target: webView, action: #selector(webView.goForward))
        
        let refreshImage = UIImage(named: "refresh-arrow")?.withRenderingMode(.alwaysOriginal)
        let refreshButtomItem = UIBarButtonItem(image:refreshImage, style: .plain, target: webView, action: #selector(webView.reload))
        
        // this is used to add space between buttons
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [refreshButtomItem,flex,flex,backButtonItem,flex,forwardButtomItem]
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // hid the tool bar when we leave the controller
        navigationController?.isToolbarHidden = true
    }
    
    // MARK: - WKWebView delegate methods
    // I would normally add a loading indicator and progress bar to
    // illustrate the states of the WKWebView
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Starting to load")
    }
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("finished loading")
    }
    
    // used to set initial website of the controller.
    // http:// is appended so the page loads properly
    // I'd normally be much more rigorous in creating proper URLs
    func setSchoolWebsite (_ schoolWebSite : String) {
        
        var secureWebSite = schoolWebSite
        if (!schoolWebSite.hasPrefix("http://")) {
            secureWebSite = "http://" + schoolWebSite
        }
        self.schoolWebsiteURL = URL(string:secureWebSite)
    }
}


