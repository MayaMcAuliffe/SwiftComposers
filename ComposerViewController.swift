//
//  ComposerViewController.swift
//  composers
//
//  Created by Maya McAuliffe on 6/11/18.
//  Copyright © 2018 Maya McAuliffe. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, UITextViewDelegate {
    var composer: Composer!
    var wikiURL:String? = nil
    var wikiText:String? = nil
    var imageURL:String? = nil

    
//    init() {
//        
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog(composer.name)
        fetchWikiData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchWikiData() {
        
        let wikiURLBase = "https://en.wikipedia.org/w/api.php?format=json&action=query&format=json&prop=pageimages|extracts|info&exintro=&explaintext=&redirects=1&piprop=original&inprop=url&titles=" + composer.name
        
        guard let wikiURLString = wikiURLBase.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return
        }
        
        guard let wikiAPIURL = URL(string: wikiURLString) else {
            print("Unable to form URL")
            return
        }
        
        var request = URLRequest(url: wikiAPIURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: sessionConfiguration)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error from data task")
                return
            }
            
            // Deserialize the response
            var responseObject:Dictionary<String,Any>?
            do {
                try responseObject = JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary
            } catch {
                print("Unable to deserialize JSON response object.")
                return
            }
            if let error = responseObject!["error"] as? String {
                print(error)
                return
            } else {
                guard let query = responseObject!["query"] as? Dictionary<String,Any>,
                    let pages = query["pages"] as? Dictionary<String,Any>,
                    let page = pages.values.first as? Dictionary<String,Any>,
                    let extract = page["extract"] as? String else {
                        return
                }
                
                if let endpoint = page["canonicalurl"] as? String {
                    self.wikiURL = endpoint
                }
                //NSLog(extract)
                self.wikiText = extract
                //NSLog(self.wikiText!)
               // self.infoTextView.text = self.wikiText
//                let infoTextView = UITextView()
//                let attributedText = NSMutableAttributedString(string: self.wikiText!)
//                
//                infoTextView.attributedText = attributedText
//                self.view.addSubview(infoTextView)
                
                DispatchQueue.main.async {
                    // Update UI
                    
                    let infoTextView = UITextView()
                    let attributedText = NSMutableAttributedString(string: self.wikiText!)
                    NSLog(self.wikiText!)
                    infoTextView.attributedText = attributedText
                    //infoTextView.text = self.wikiText
                    infoTextView.isScrollEnabled = false
                    infoTextView.backgroundColor = UIColor.clear
                    infoTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    infoTextView.delegate = self
                    infoTextView.isUserInteractionEnabled = true
                    infoTextView.isEditable = false
                    
                    let maxWidth = self.view.frame.width
                    let newSize = infoTextView.sizeThatFits(CGSize(width: maxWidth,
                                                                      height: CGFloat.greatestFiniteMagnitude))
                    infoTextView.frame.size = CGSize(width: min(maxWidth, newSize.width),
                                                        height: newSize.height)
                    
                    infoTextView.frame.origin = CGPoint(x: 0, y: 100)
                    
                    self.view.addSubview(infoTextView)
                }
                
                
//                guard let pageimage = page["original"] as? Dictionary<String,Any>,
//                    let imageURL = pageimage["source"] as? String,
//                    let pictureURL = URL(string: imageURL) else {
//                        DispatchQueue.main.async {
//                            //self.updateAboutText()
//                        }
//                        return
//                }
                
//                self.imageURL = imageURL
//                UIImage.downloadedFrom(url: pictureURL,
//                                       completion: { (error:String?, image:UIImage?) in
//                                        DispatchQueue.main.async {
//                                           // self.imageToUse = image
//                                           // self.updateAboutText()
//                                           // self.updateAboutImage()
//                                        }
//                })
            }
        }
        dataTask.resume()
        
    }
    
    

}
extension UIImage {
    static func downloadedFrom(url: URL, completion handler:  @escaping (_ error:String?, _ image:UIImage?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: sessionConfiguration)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                handler(error as? String, nil)
                return
            }
            
            guard let imageData = data else {
                handler("No data", nil)
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                handler("Unable to create image", nil)
                return
            }
            
            handler(nil, image)
            return
        }
        
        dataTask.resume()
    }
}



