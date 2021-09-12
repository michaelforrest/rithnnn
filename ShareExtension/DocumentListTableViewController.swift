//
//  DocumentListTableViewController.swift
//  ShareExtension
//
//  Created by Michael Forrest on 12/09/2021.
//

import UIKit

protocol DocumentListTableViewControllerDelegate: class{
    var selectedDocument: RithnnnDocumentInfo?{ get }
    func documentListSelected(document: RithnnnDocumentInfo)
}

class DocumentListTableViewController: UITableViewController {
    let documents = RithnnnAppGroup.listDocuments()
    weak var delegate: DocumentListTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        documents.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let doc = documents[indexPath.row]
        cell.textLabel?.text = doc.title
        cell.detailTextLabel?.text = Date().description
        cell.accessoryType = (doc.uuid == delegate?.selectedDocument?.uuid) ? .checkmark : .none
        return cell
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.documentListSelected(document: documents[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

}
