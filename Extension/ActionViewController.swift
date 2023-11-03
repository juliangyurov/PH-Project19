//
//  ActionViewController.swift
//  Extension
//
//  Created by Yulian Gyuroff on 31.10.23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController, DataEnteredDelegate {
    
    func userDidEnterInformation(jsTitle: String) {
        print("RETURNED: jsTitle: \(jsTitle)")
        for site in webSites{
            //print(site.host,site.jScripts.count)
            for jScript in site.jScripts{
                 //print(jScript.jsTitle,jScript.javaScript)
                if jScript.jsTitle == jsTitle {
                    script.text = jScript.javaScript
                }
            }
            
        }
    }
    
    @IBOutlet var script: UITextView!

    var pageTitle = ""
    var pageURL = ""
    var pageBody = ""
    var pageHead = ""
    var pageDoctype = ""
    var testURL = URL(string: "")
    
    var webSites = [WebSite]()
    var host = ""
    let defaults = UserDefaults.standard
    
    var scriptTitle = "StartingTitle" {
        didSet{
            var tempJavaScript = JavaScript(javaScript: script.text, jsTitle: scriptTitle)
            var tempJavaScripts = [JavaScript]()
            tempJavaScripts.append(tempJavaScript)
            var webSite = WebSite(host: host, jScripts: tempJavaScripts)
            //webSites.removeAll()
            webSites.append(webSite)
            save()
        }
    }
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
         
         let table = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showTable))
         let select = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(selectScript))
         let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
         navigationItem.rightBarButtonItems = [done,select,table]
         
         if let savedWebSites = defaults.object(forKey: "savedWebSites") as? Data {
             if let decodedWebSites = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedWebSites) as? [WebSite] {
                 webSites = decodedWebSites
                 print("-------------------- webSites.count: \(webSites.count) ------------------------")
                 for site in webSites{
                     print("---------------------------------------------------------------")
                     print(site.host,site.jScripts.count)
                     for script in site.jScripts{
                         print("---------------------------------------------------------------")
                         print(script.jsTitle,script.javaScript)
                     }
                     
                 }
                 print("---------------------------------------------------------------")
             }
         }
         
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
                    self?.host = URL(string: self?.pageURL ?? "")?.host ?? ""
                    print("host: \(  URL(string: self?.pageURL ?? "")?.host  ) absoluteString: \(URL(string: self?.pageURL ?? "")?.absoluteString)")
                    print("-------------------------------------------")
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                    
                }
            }
        }
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
    
    @objc func showTable() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SavedJS") as? SavedJavaScripts {
            vc.delegate = self
            for site in webSites{
                print(site.host,site.jScripts,terminator: " ->->-> ")
                for someScript in site.jScripts{
                    print(someScript.jsTitle,terminator: " -> ")
                    vc.jsTitles.append(someScript.jsTitle)
                }
             }
            print(webSites[0].jScripts[0].jsTitle)
            print("---->>>END<<<----")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func done() {
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
 
    
    func javascriptSelector(alert: UIAlertAction) {
        //var ourTitle = "Test123"
        let ac = UIAlertController(title: "Title needed", message: "Give some name for the script", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default){
            [weak self, weak ac] _ in
            guard let str = ac?.textFields?[0].text else { return }
            self?.scriptTitle = str
            print("&&&&&&&&&&&&&&&&&&&&& \(self?.scriptTitle) &&&&&&&&&&&&&&&&&&&&&&&&")
            
        })
        present(ac, animated: true, completion: nil)
        
        script.text = ""
        script.text = alert.title
//        var tempJavaScript = JavaScript(javaScript: script.text, jsTitle: ourTitle)
//        var tempJavaScripts = [JavaScript]()
//        tempJavaScripts.append(tempJavaScript)
//        var webSite = WebSite(host: host, jScripts: tempJavaScripts)
//        webSites.removeAll()
//        webSites.append(webSite)
//        save()
     }
    
    func save() {
        if let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: webSites, requiringSecureCoding: false){
            defaults.set(archivedData, forKey: "savedWebSites")
        }
    }

}
