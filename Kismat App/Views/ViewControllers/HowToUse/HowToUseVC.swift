//
//  HowToUseVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 27/08/2023.
//

import UIKit
import WebKit

class HowToUseVC: MainViewController, WKNavigationDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the WKWebView's delegate.
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load the YouTube video URL in the WKWebView.
        //let url = URL(string: "https://www.youtube.com/watch?v=UbYONxCvd8g")!
        
        let videoID = "3cYBfuphkuE" // Replace with your YouTube video ID
        let urlString = "https://www.youtube.com/embed/\(videoID)?playsinline=1&showinfo=0&rel=0"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        webView.load(request)
    }

    // WKNavigationDelegate method to handle the navigation start event.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Navigation started")
    }
    
    // WKNavigationDelegate method to handle the navigation finish event.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Navigation finished")
    }
}
