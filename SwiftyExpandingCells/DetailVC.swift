//
//  DetailVC.swift
//  SwiftyExpandingCells
//
//  Created by Fischer, Justin on 11/19/15.
//  Copyright © 2015 Fischer, Justin. All rights reserved.
//

import UIKit
import Alamofire

class DetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var iconLabel: UILabel!
    
    var brand: Brand?
    var selectedStopIndex: Int?
    
    @IBOutlet weak var stationPickerView: UIPickerView!
    
    @IBOutlet weak var delayStatusLabel: UILabel!
    @IBOutlet weak var cancellationStatusLabel: UILabel!
    @IBOutlet weak var localStatusLabel: UILabel!
    @IBOutlet weak var skippingStatusLabel: UILabel!
    
    @IBOutlet weak var delaySwitch: UISwitch!
    @IBOutlet weak var localSwitch: UISwitch!
    @IBOutlet weak var cancellationSwitch: UISwitch!
    @IBOutlet weak var skippingSwitch: UISwitch!
    
    var delayFlag : Bool = false
    var localFlag : Bool = false
    var cancellationFlag : Bool = false
    var skippingFlag : Bool = false
    
    var waitedTime : String = ""
    
    @IBOutlet weak var timeWaitedText: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    let GET_STATIONS_URL: String = "http://192.168.1.5:5000/getTrainStops?id="
    let GET_INCIDENT_URL : String = "http://192.168.1.5:5000/getIncidentReasonCount?"
    let SET_INCIDENT_URL : String = "http://192.168.1.5:5000/addNewStatus?"
    
    @IBOutlet weak var submitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stationPickerView.delegate = self
        self.stationPickerView.dataSource = self
        StopManager.sharedInstance.stationListData = [""]
        selectedStopIndex = 1
        
        delaySwitch.on = false
        cancellationSwitch.on = false
        localSwitch.on = false
        skippingSwitch.on = false
        
        loadStationsForTrain()
        resetIncidentCounts()
        getFirstIncident()
        self.setup()
    }
    
    func getFirstIncident()
    {
        
    }
    
    func submitIncident()
    {
        if(validate())
        {
            let stopId : String = StopManager.sharedInstance.ids[selectedStopIndex!]
            let delay : String = waitedTime
            let reason: String = getReasons()
            let url : String = SET_INCIDENT_URL + "stopId="+stopId+"&delay="+delay+"&reason="+reason
            Alamofire.request(.GET, url)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print(JSON)
                }
            }
        
            resetData();
        }
    }
    
    
    @IBAction func reportButtonClick(sender: UIButton) {
        submitIncident()
    }
    
    func getIncidentForStation(let stopId: String)
    {
        resetIncidentCounts()
        let url : String = GET_INCIDENT_URL + "stopId="+stopId+"&dummy=2"
        Alamofire.request(.GET, url)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let items = JSON["data"] as? [[String: AnyObject]] {
                        for item in items {
                            if let reason = item["reason"] as? String {
                                let countInt : Int = (item["count"] as? Int)!
                                let count : String = String(countInt)
                                switch reason {
                                case "DELAY":
                                    self.delayStatusLabel.text = count
                                case "CANCELLATION":
                                    self.cancellationStatusLabel.text = count
                                case "LOCAL":
                                    self.localStatusLabel.text = count
                                case "SKIPPING":
                                    self.skippingStatusLabel.text = count
                                default:
                                    print("Invalid Disruption received")
                                }
                                
                                
                            }
                            self.stationPickerView.reloadAllComponents()
                            
                        }
                    }
                    
                }
        }
        
        
        
    }
    
    func loadStationsForTrain()
    {
        StopManager.sharedInstance.stationListData.removeAll()
        StopManager.sharedInstance.stops.removeAll()
        StopManager.sharedInstance.ids.removeAll()
        
        let url : String = GET_STATIONS_URL+(brand?.id)!
        Alamofire.request(.GET, url)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let items = JSON["data"] as? [[String: AnyObject]] {
                        for item in items {
                            if let name = item["stopName"] as? String {
                                let idInt : Int = (item["stopId"] as? Int)!
                                let id : String = String(idInt)
                                StopManager.sharedInstance.ids.append(id);
                                StopManager.sharedInstance.stops.append(Stop(name:name,id:id));
                                StopManager.sharedInstance.stationListData.append(name);
                            }
                            self.stationPickerView.reloadAllComponents()
                            
                        }
                    }
                    
                }
        }
        
        stationPickerView.reloadAllComponents()
    }
    
    func setup() {
        self.view.frame.origin.y = UIApplication.sharedApplication().statusBarFrame.size.height
        
        if let brand = self.brand {
            self.title = brand.name
            
            self.iconLabel.text = brand.iconText
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func timeWaitedSliderAction(sender: UISlider) {
        let selectedValue = Int(sender.value)
        self.timeWaitedText.text = String(stringInterpolationSegment: selectedValue)+" Minutes Delayed"
        self.waitedTime = String(stringInterpolationSegment: selectedValue)
        
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return StopManager.sharedInstance.stationListData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return StopManager.sharedInstance.stationListData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        getIncidentForStation(StopManager.sharedInstance.ids[row])
        self.selectedStopIndex = row
    }
    
    func getReasons()-> String
    {
        var reasons: String = ""
        if(delayFlag)
        {
            reasons = reasons+"DELAY"
        }
        if(localFlag)
        {
            reasons = reasons+"LOCAL"
        }
        if(cancellationFlag)
        {
            reasons = reasons+"CANCELLATION"
        }
        if(skippingFlag)
        {
            reasons = reasons+"SKIPPING"
        }
        
        return reasons;
    }
    
    func resetData()
    {
        delaySwitch.on = false
        cancellationSwitch.on = false
        localSwitch.on = false
        skippingSwitch.on = false
    }
    
    
    @IBAction func delaySwitchChange(switchState: UISwitch) {
        if switchState.on {
            delayFlag = true;
        } else {
            delayFlag = false;
        }
    }
    
    @IBAction func localSwitchChange(switchState: UISwitch) {
        if switchState.on {
            localFlag = true;
        } else {
            localFlag = false;
        }
    }
    
    @IBAction func cancellationSwitchChange(switchState: UISwitch) {
        if switchState.on {
            delayFlag = true;
        } else {
            delayFlag = false;
        }
    }
    
    @IBAction func skippingSwitchChange(switchState: UISwitch) {
        if switchState.on {
            delayFlag = true;
        } else {
            delayFlag = false;
        }
    }
    
    func validate()-> Bool{
        if(delayFlag && localFlag && skippingFlag && cancellationFlag)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func resetIncidentCounts()
    {
        self.delayStatusLabel.text = "0"
        self.cancellationStatusLabel.text = "0"
        self.localStatusLabel.text = "0"
        self.skippingStatusLabel.text = "0"
    }
}

