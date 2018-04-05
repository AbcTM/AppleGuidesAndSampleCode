//
//  ViewController.swift
//  MultiSelectTableViewSwift
//
//  Created by tlc on 2018/4/5.
//  Copyright © 2018年 tlc. All rights reserved.
//

import UIKit

class MasterListViewController: UITableViewController {

    var dataArray: Array<String> = []
    
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    
    // MARK: - life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        for index in 0..<12 {
            self.dataArray.append("item \(index)")
        }
        
        updateButtonsToMatchTableState()
    }

    // MARK: - action Methods
    @IBAction func editAction(_ sender: Any) {
        self.tableView.setEditing(true, animated: true)
        self.updateButtonsToMatchTableState()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.tableView.setEditing(false, animated: true)
        self.updateButtonsToMatchTableState()
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.tableView.beginUpdates()
        let appendItem = "new Item: \(arc4random()%10000000)"
        self.dataArray.append(appendItem)
        
        let newIndexPath = IndexPath.init(row: self.dataArray.count-1, section: 0)
        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        
        self.updateButtonsToMatchTableState()
    }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        let acionTitle: String
        if let selectedRows = self.tableView.indexPathsForSelectedRows, selectedRows.count == 1 {
            acionTitle = NSLocalizedString("Are you sure you want to remove this item?", comment: "")
        }else{
            acionTitle = NSLocalizedString("Are you sure you want to remove These items?", comment: "")
        }
        
        let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel title for item removal action")
        let okTitle = NSLocalizedString("Ok", comment: "OK title for item removal action")
        let alertVC = UIAlertController.init(title: acionTitle, message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction.init(title: cancelTitle, style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction.init(title: okTitle, style: .default, handler: { (action) in
            if let selectedRows = self.tableView.indexPathsForSelectedRows, selectedRows.count > 0 {
                for selectionIndex in selectedRows {
                    self.dataArray.remove(at: selectionIndex.row)
                }
                self.tableView.deleteRows(at: selectedRows, with: .automatic)
            }else{
                self.dataArray.removeAll()
                self.tableView.reloadSections(NSIndexSet.init(index: 0) as IndexSet, with: .automatic)
            }
            
            self.tableView.setEditing(false, animated: true)
            self.updateButtonsToMatchTableState()
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - ui
    func updateButtonsToMatchTableState() {
        if self.tableView.isEditing {
            self.navigationItem.rightBarButtonItem = cancelButton
            self.updateDeleteButtonTitle()
            self.navigationItem.leftBarButtonItem = deleteButton
        }else{
            self.navigationItem.rightBarButtonItem = editButton
            if self.dataArray.count > 0 {
                self.editButton.isEnabled = true
            }else {
                self.editButton.isEnabled = false
            }
            self.navigationItem.leftBarButtonItem = addButton
        }
    }
    
    func updateDeleteButtonTitle() {
        if let selectedRows = self.tableView.indexPathsForSelectedRows {
            if selectedRows.count == self.dataArray.count || selectedRows.count == 0 {
                self.deleteButton.title = NSLocalizedString("Delete All", comment: "")
            }else{
                let titleFormatString = NSLocalizedString("Delete (%d)", comment: "Title for delete button with placeholder for number")
                self.deleteButton.title = String.init(format: titleFormatString, selectedRows.count)
            }
        }else{
            self.deleteButton.title = NSLocalizedString("Delete All", comment: "")
        }
    }
}


extension MasterListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.dataArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateDeleteButtonTitle()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateButtonsToMatchTableState()
    }
}
