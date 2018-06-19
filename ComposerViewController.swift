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
    var imageToUse:UIImage? = nil
    
    // UI components
    let containerView:UIScrollView = UIScrollView() // entire screen vertical scroll
    var aboutComposerImage:UIImageView? = nil
    let composerContainer:UIView = UIView() // about the composer

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog(composer.name)
        prepareContainerView()
        self.view.addSubview(containerView)
        // prepapreComposerContainer()
        // containerView.addSubview(composerContainer)
        fetchWikiData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func prepareContainerView() {
        containerView.frame.origin = CGPoint(x: 0,
                                             y: 0) // i have an older verson that doesn't have self.view.safeAreaInsets.top
        containerView.frame.size = CGSize(width: self.view.frame.size.width,
                                          height: self.view.frame.size.height - containerView.frame.origin.y)
        containerView.backgroundColor = UIColor.clear
        containerView.contentSize = CGSize(width: 320, height: 650)//containerView.frame.size
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
                
                self.wikiText = extract
                
                self.composer.info = self.wikiText!
                
                guard let pageimage = page["original"] as? Dictionary<String,Any>,
                let imageURL = pageimage["source"] as? String,
                let pictureURL = URL(string: imageURL) else { // if there is no photo, just provide text
                    DispatchQueue.main.async {
                        self.updateAboutText()
                        
                    }
                    return
                }
                
                self.imageURL = imageURL
                UIImage.downloadedFrom(url: pictureURL,
                                       completion: { (error:String?, image:UIImage?) in
                                        DispatchQueue.main.async {
                                           // self.imageToUse = image
                                           self.updateAboutText()
                                           // self.updateAboutImage()
                                        }
                })
            }
        }
        dataTask.resume()
        
    }
    // i think that the reason that the scrolling bounces is beause this is bigger than the container view and the container view has to know how big this is in order to know when to bounce back. we have to create this first and then the container view and then give this size to the cpntainer view so it can scroll properly
    
    func updateAboutText(){
        let infoTextView = UITextView()
        let attributedText = NSMutableAttributedString(string: self.wikiText!)
        infoTextView.attributedText = attributedText
        infoTextView.isScrollEnabled = true
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
        
        infoTextView.frame.origin = CGPoint(x: 0, y: 0)
        
        containerView.contentSize = infoTextView.frame.size
        containerView.addSubview(infoTextView)

    }
    
//    func updateAboutImage() {
//        guard imageToUse != nil else {
//            return
//        }
//        
//        let newAuthorImage = UIImageView()
//        let imageSize = self.imageToUse?.size ?? CGSize(width: 10, height: 10)
//        
//        let widthAdjustmentFactor = imageSize.width / (aboutComposerContainer.frame.size.width / 4)
//        let heightAdjustmentFactor = imageSize.height / (aboutComposerContainer.frame.size.height / 2) //TODO: Watch out, because aboutComposerView might be 0 if text is not returned yet and resizing has run.
//        let adjustmentFactor = max(widthAdjustmentFactor, heightAdjustmentFactor)
//        
//        let rowHeightMultiple = aboutComposerText?.font?.lineHeight ?? 1
//        var finalEstHeight = imageSize.height / adjustmentFactor
//        finalEstHeight = finalEstHeight / rowHeightMultiple
//        finalEstHeight = floor(finalEstHeight) * rowHeightMultiple
//        
//        let correctedAdjustmentFactor = imageSize.height / finalEstHeight
//        newAuthorImage.frame.size = CGSize(width: imageSize.width / correctedAdjustmentFactor,
//                                           height: imageSize.height / correctedAdjustmentFactor)
//        newAuthorImage.contentMode = .scaleAspectFit
//        newAuthorImage.image = self.imageToUse
//        newAuthorImage.layer.borderWidth = 0.5
//        
//        if aboutComposerText != nil {
//            aboutComposerText?.textContainer.exclusionPaths = [UIBezierPath(rect: newAuthorImage.frame)]
//            newAuthorImage.frame.origin.y = aboutComposerText?.textContainerInset.top ?? 0
//            newAuthorImage.frame.origin.x = aboutComposerText?.textContainerInset.left ?? 0
//            let maxWidth = aboutComposerContainer.frame.width
//            let newSize = aboutComposerText?.sizeThatFits(CGSize(width: maxWidth,
//                                                                 height: CGFloat.greatestFiniteMagnitude))
//            aboutComposerText?.frame.size = CGSize(width: min(maxWidth, newSize?.width ?? 0),
//                                                   height: newSize?.height ?? 0)
//            
//        }
//        
//        newAuthorImage.frame.origin = CGPoint(x: 0, y: aboutTitleView.frame.maxY + 5)
//        aboutComposerImage = newAuthorImage
//        
//        aboutComposerContainer.frame.size.height = aboutComposerText?.frame.maxY ?? 0
//        containerView.contentSize.height = aboutComposerContainer.frame.maxY + 10
//        
//        aboutComposerContainer.addSubview(aboutComposerImage!)
//    }
    
    

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



