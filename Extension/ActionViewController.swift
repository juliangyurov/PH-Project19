//
//  ActionViewController.swift
//  Extension
//
//  Created by Yulian Gyuroff on 31.10.23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    @IBOutlet var script: UITextView!

    var pageTitle = ""
    var pageURL = ""
    var pageBody = ""
    var pageHead = ""
    var pageDoctype = ""
    var testURL = URL(string: "")
    
     override func viewDidLoad() {
        super.viewDidLoad()
          
         let select = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(selectScript))
         let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
         navigationItem.rightBarButtonItems = [done,select]
         
         let notificationCenter = NotificationCenter.default
         notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
         notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    //do stuff
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    print("-------------------------------------------")
                    print(javaScriptValues)
                    print("-------------------------------------------")
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    self?.pageBody = javaScriptValues["body"] as? String ?? ""
                    self?.pageHead = javaScriptValues["head"] as? String ?? ""
                    self?.pageDoctype = javaScriptValues["doctype"] as? String ?? ""
                    
                    //self?.testURL = self?.pageURL as URL
                   
                    print("-------------------------------------------")
                    print("host: \(  URL(string: self?.pageURL ?? "")?.host  )")
                    print("-------------------------------------------")
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                    
                }
            }
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame,from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        }else{
            script.contentInset = UIEdgeInsets(top: 0, left: 0,
                                               bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                                               right: 0)
        }
        script.scrollIndicatorInsets = script.contentInset
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func selectScript() {
        let ac = UIAlertController(title: "Select script", message: "from prepared javascripts", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "alert(document.title)", style: .default, handler: javascriptSelector))
        ac.addAction(UIAlertAction(title: "alert(document.URL)", style: .default, handler: javascriptSelector))
        ac.addAction(UIAlertAction(title: "alert(document.cookie)", style: .default, handler: javascriptSelector))
        ac.addAction(UIAlertAction(title: "alert(document.body.innerText)", style: .default, handler: javascriptSelector))
        ac.addAction(UIAlertAction(title: "alert(document.compatMode)", style: .default, handler: javascriptSelector))
        ac.addAction(UIAlertAction(title: "alert(document.contentType)", style: .default, handler: javascriptSelector))
        ac.addAction(UIAlertAction(title: "alert(document.location)", style: .default, handler: javascriptSelector))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func javascriptSelector(alert: UIAlertAction) {
        script.text = ""
        script.text = alert.title
     }

}
