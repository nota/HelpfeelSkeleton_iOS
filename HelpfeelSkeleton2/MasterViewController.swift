//
//  MasterViewController.swift
//  HelpfeelSkeleton2
//
//  Created by daiki on 2019/04/22.
//  Copyright © 2019 daiiz. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    static private let defaultHelpfeelUrl = "https://helpfeel.notainc.com/SFCHelp"
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    private var helpfeelUrl: String = MasterViewController.defaultHelpfeelUrl

    override func viewDidLoad() {
        super.viewDidLoad()
        // reverse order
        prependNewMenuItem(label: "Settings")
        prependNewMenuItem(label: "Chat support")
        prependNewMenuItem(label: "Guide")
        prependNewMenuItem(label: "Home")
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc
    func prependNewMenuItem(label: String) {
        objects.insert(label, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! String
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        let label = cell?.textLabel?.text
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var vc = storyboard!.instantiateViewController(withIdentifier: "homeVC") as UIViewController
        
        // Settings
        if (label == "Settings") {
            self.askWebViewUrl()
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        // MenuItemごとにViewControllerを指定する
        switch label {
        case "Guide":
            // Helpfeel
            vc = storyboard!.instantiateViewController(withIdentifier: "helpfeelVC3") as UIViewController
            appDelegate.helpfeelUrl = self.helpfeelUrl
            setupNextVC(title: "Guide", vc: vc)
            break
        case "Chat support":
            vc = storyboard!.instantiateViewController(withIdentifier: "chatSupportVC") as UIViewController
            setupNextVC(title: "Chat support", vc: vc)
            break
        default:
            setupNextVC(title: "Your app", vc: vc)
        }
        
        splitViewController!.showDetailViewController(vc, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setupNextVC(title: String, vc: UIViewController) {
        var item = vc.navigationItem
        if let navController = vc as? UINavigationController {
            item = navController.topViewController!.navigationItem
        }
        item.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        item.leftItemsSupplementBackButton = true
        item.title = title
    }
    
    func askWebViewUrl() {
        let alert = UIAlertController(title: "WebView URL", message: "Please input here.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction!) -> Void in
            let textFields:Array<UITextField>? = alert.textFields
            if (textFields?.count)! > 0 {
                // 入力されたURLを取得
                let url: String! = textFields![0].text!
                if (url.utf8.count == 0) {
                    return
                }
                self.helpfeelUrl = url!
            }
        })
        alert.addAction(defaultAction)
        
        let resetAction = UIAlertAction(title: "Reset", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
            self.helpfeelUrl = MasterViewController.defaultHelpfeelUrl
        })
        alert.addAction(resetAction)
        
        // TextFieldを追加
        alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = self.helpfeelUrl
        })
        present(alert, animated: true, completion: nil)
    }
}

