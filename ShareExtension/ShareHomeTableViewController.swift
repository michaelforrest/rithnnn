//
//  ShareHomeTableViewController.swift
//  ShareExtension
//
//  Created by Michael Forrest on 12/09/2021.
//

import UIKit
import MobileCoreServices

class CancelledError: Error{}

class ShareHomeTableViewController: UITableViewController {

    var selectedDocument: RithnnnDocumentInfo?
    @IBOutlet weak var selectedDocumentNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDocument = RithnnnAppGroup.getLatestDocument()
        selectedDocumentNameLabel.text = selectedDocument?.title ?? "Select..."
    }
    @IBAction func dismiss(){
        dismiss(animated: true){
            self.extensionContext?.cancelRequest(withError: CancelledError())
        }
    }
    @IBAction func didPressSave(){
        handleSharedFile(document: selectedDocument)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // just the detail view
        if let dest = segue.destination as? DocumentListTableViewController{
            dest.delegate = self
        }
    }
}

extension ShareHomeTableViewController:DocumentListTableViewControllerDelegate{
    func documentListSelected(document: RithnnnDocumentInfo) {
        selectedDocument = document
        selectedDocumentNameLabel.text = document.title
    }
}

extension UIViewController{
    func handleSharedFile(document: RithnnnDocumentInfo?=nil) {
        guard let document = document else { return }
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = kUTTypeData as String
        for provider in attachments {
            // Check if the content type is the same as we expected
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType,
                                  options: nil) { [unowned self] (url, error) in
                    guard error == nil else { return }
                    
                    if let url = url as? URL, url.absoluteString.hasSuffix(".zip") {
                        moveZip(from: url, document: document)
                    } else {
                        // Handle this situation as you prefer
                        fatalError("Impossible to save image")
                    }
                }}
        }
    }
    
    func moveZip(from url: URL, document: RithnnnDocumentInfo){
        let fileManager = FileManager.default
        let container = fileManager
            .containerURL(forSecurityApplicationGroupIdentifier: "group.rithnnn")!
            .appendingPathComponent("Inbound")
            .appendingPathComponent(document.uuid)
            
        if !fileManager.fileExists(atPath: container.path){
            try! fileManager.createDirectory(at: container, withIntermediateDirectories: true, attributes: nil)
        }
        try? fileManager.moveItem(at: url, to: container.appendingPathComponent(url.lastPathComponent))
        print("writing to", container)
        
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
}
