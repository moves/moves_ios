//
//  WebViewController.swift
//  D-Track
//
//  Created by Zubair Ahmed on 08/02/2022.
//

import UIKit
import WebKit
class WebViewController: UIViewController , UIWebViewDelegate,WKNavigationDelegate, UIScrollViewDelegate {
    
    var myUrl = "www.google.com"
    var linkTitle = ""
    
    //MARK:- OUTLET
    
    @IBOutlet weak var wkwebView: WKWebView!

    @IBOutlet weak var linkTitleLbl: UILabel!
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    //MARK:-  VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(myUrl)
        self.loader.startAnimating()
        myUrl = addSchemeIfNeeded(to: myUrl)
        
        guard let url = URL(string: myUrl) else {
            Utility.showMessage(message: "Invalid Url", on: self.view)
            return
        }
        
        let request = URLRequest(url: URL(string: myUrl)!)
        self.navigationController?.isNavigationBarHidden = true
        wkwebView?.navigationDelegate = self
        
        wkwebView?.load(request)
        wkwebView.scalesLargeContentImage = false
        wkwebView.showsLargeContentViewer = true
        wkwebView.isMultipleTouchEnabled = false
        //wkwebView.scrollView.delegate = self
    }
    
    private func addSchemeIfNeeded(to urlString: String) -> String {
            var modifiedUrlString = urlString
            if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                if urlString.hasPrefix("www.") {
                    modifiedUrlString = "http://" + urlString
                } else {
                    modifiedUrlString = "http://www." + urlString
                }
            }
            return modifiedUrlString
        }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        self.linkTitleLbl.text = self.linkTitle
    }

    
//    //MARK: - UIScrollViewDelegate
//    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//             scrollView.pinchGestureRecognizer?.isEnabled = false
//    }
////    @objc func back(sender: UIBarButtonItem) {
////        self.navigationController?.popViewController(animated: true)
////    }
    
  
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        print(message.body)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print(#function)

        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        webView.evaluateJavaScript("navigator.userAgent", completionHandler: { result, error in
            if let userAgent = result as? String {
                print(userAgent)
                self.loader.stopAnimating()
                self.loader.isHidden = true
            }
        })
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Utility.showMessage(message: error.localizedDescription, on: self.view)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Utility.showMessage(message: error.localizedDescription, on: self.view)
    }
    
    //MARK:- BUTTON ACTION
    
    @IBAction func backBtnAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
   
}
