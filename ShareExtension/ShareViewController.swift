//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Michael Forrest on 11/09/2021.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        /* LOOKS LIKE **
         Optional<NSExtensionContext>
           - some : <EXExtensionContextImplementation: 0x60000261c510> - UUID: 7A5A8A77-38E8-4B71-8909-7EB258B60940 - _isHost: NO
         _isDummyExtension:NO
         inputItems:
         (
             "<NSExtensionItem: 0x600001610330> - userInfo: {\n    NSExtensionItemAttachmentsKey =     (\n        \"<NSItemProvider: 0x600003f18700> {types = (\\n    \\\"public.zip-archive\\\",\\n    \\\"public.file-url\\\"\\n)}\"\n    );\n    \"com.apple.UIKit.NSExtensionItemUserInfoIsContentManagedKey\" = 0;\n}"
         )
         */
        return true
    }

    override func didSelectPost() {
        handleSharedFile()
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [ ]
    }
    
    private func handleSharedFile() {
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = kUTTypeData as String
        for provider in attachments {
            // Check if the content type is the same as we expected
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType,
                                  options: nil) { [unowned self] (url, error) in
                    guard error == nil else { return }
                    
                    if let url = url as? URL, url.absoluteString.hasSuffix(".zip") {
                        moveZip(from: url)
                    } else {
                        // Handle this situation as you prefer
                        fatalError("Impossible to save image")
                    }
                }}
        }
    }
    
    private func moveZip(from url: URL){
        let fileManager = FileManager.default
        let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.rithmmm")!.appendingPathComponent("Inbound").appendingPathComponent(url.lastPathComponent)
        try! fileManager.moveItem(at: url, to: container)
        
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

}
