//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Michael Forrest on 11/09/2021.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    var selectDocumentItem: SLComposeSheetConfigurationItem?
    override func loadView() {
        super.loadView()
        
        
        let item = SLComposeSheetConfigurationItem()
        item?.title = "Set"
        item?.value = "Quantize thingy"
        item?.tapHandler = {
            let controller = UITableViewController()
            self.pushConfigurationViewController(controller)
        }
        self.selectDocumentItem = item
    }
    
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
        [ selectDocumentItem ]
    }
    
   

}
