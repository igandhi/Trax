//
//  MasterVC.swift
//  SwiftyExpandingCells
//
//  Created by Fischer, Justin on 11/19/15.
//  Copyright © 2015 Fischer, Justin. All rights reserved.
//

import UIKit
import Alamofire

extension UIView {
    func makeCircular() {
        let cntr:CGPoint = self.center
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.center = cntr
    }
}

class MasterVC: UITableViewController, UINavigationControllerDelegate, SegueHandlerType {
    let transtition = SwiftyExpandingTransition()
    var selectedCellFrame = CGRectZero
    var selectedBrand: Brand?
    
    let GET_ALL_TRAINS: String = "http://162.243.253.200:5000/getAllTrains"
    
    
    
    @IBOutlet var mainTableView: UITableView!
    
    enum SegueIdentifier: String {
        case DetailVC = "DetailVC"
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Making Json Call")
        Alamofire.request(.GET, GET_ALL_TRAINS)
            .responseJSON { response in
                //                print(response.request)  // original URL request
                //                print(response.response) // URL response
                //                print(response.data)     // server data
                //                print(response.result)   // result of response serialization
                if let JSON = response.result.value {
                    if let items = JSON["data"] as? [[String: AnyObject]] {
                        for item in items {
                            if let name = item["trainName"] as? String {
                                let idInt : Int = (item["trainId"] as? Int)!
                                let id : String = String(idInt)
                                let iconText : String = name[name.startIndex...name.startIndex.advancedBy(0)]
                                
                                let formattedName = name.componentsSeparatedByString("-")
                                BrandManager.sharedInstance.brands.append(Brand(iconText: iconText, name: name, numberOfIncidents: "0", id:id ))
                            }
                        }
                    }
                    self.mainTableView.reloadData()
                }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BrandManager.sharedInstance.brands.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let brand = BrandManager.sharedInstance.brands[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("brand") {
            cell.textLabel?.text = brand.iconText
            cell.textLabel?.layer.masksToBounds = true
            cell.textLabel?.layer.cornerRadius = (cell.textLabel?.frame.size.height)!/2
            
            cell.detailTextLabel?.text = brand.name + " "
                //+ brand.numberOfIncidents
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedCellFrame = tableView.convertRect(tableView.cellForRowAtIndexPath(indexPath)!.frame, toView: tableView.superview)
        self.selectedBrand = BrandManager.sharedInstance.brands[indexPath.row]
        
        self.performSegueWithIdentifier(.DetailVC , sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .DetailVC:
            let vc = segue.destinationViewController as! DetailVC
            vc.brand = self.selectedBrand

            self.navigationController?.delegate = self
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == UINavigationControllerOperation.Push {
            transtition.operation = UINavigationControllerOperation.Push
            transtition.duration = 0.40
            transtition.selectedCellFrame = self.selectedCellFrame
            
            return transtition
        }
        
        if operation == UINavigationControllerOperation.Pop {
            transtition.operation = UINavigationControllerOperation.Pop
            transtition.duration = 0.20
            
            return transtition
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

