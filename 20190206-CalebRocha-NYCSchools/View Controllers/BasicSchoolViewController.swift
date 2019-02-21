//
//  BasicSchoolViewController.swift
//  20190206-CalebRocha-NYCSchools
//
//  Created by Caleb Admin on 2/18/19.
//  Copyright © 2019 Caleb Admin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

// I would probably put this custom cell in its own file so it can easily be reused
class BasicSchoolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var grade_range: UILabel!
    @IBOutlet weak var num_students: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
        
        // set label alignment
        name.textAlignment = NSTextAlignment.left
        address.textAlignment = NSTextAlignment.left
        grade_range.textAlignment = NSTextAlignment.left
        num_students.textAlignment = NSTextAlignment.right
        
        // set the text style for the labels
        name.textColor = UIColor.init(red: 0.0, green: 0.6, blue: 0.6, alpha: 1)
        name.font = UIFont.boldSystemFont(ofSize: 20.0)
        address.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        grade_range.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        num_students.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        // let the school name and address grow in height
        name.lineBreakMode = .byWordWrapping
        name.numberOfLines = 0
        address.lineBreakMode = .byWordWrapping
        address.numberOfLines = 0
    }
    
}

class BasicSchoolViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    @IBOutlet weak var schoolTableView: UITableView!
    
    var schoolData: [BasicSchool] = []
    var isSchoolDataBeingFetched = false;
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        schoolTableView.dataSource = self
        schoolTableView.delegate = self
        
        // remove tableview lines
        //schoolTableView.separatorStyle = .none
        
        // letting the cells grow to fit the whole school name and address
        schoolTableView.rowHeight = UITableView.automaticDimension
        schoolTableView.estimatedRowHeight = 300
        
        // fetch the school data
        getSchoolData()
        
        schoolTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // normally, I'd put this network code in another class and pass a closure
    // to return the school data and reload the tableivew.
    // I would also not hardcode the url or query strings.
    
    func getSchoolData() {
        
        // don't fetch data if we're already fetching
        if (isSchoolDataBeingFetched) {
            return
        }
        
        isSchoolDataBeingFetched = true;
        
        // construct the url, adding query strings
        // limiting results to 12 schools at a time, offset and ordering allows for "paging" through results.
        // when the user has scrolled to the bottom of the list, we fetch the next 12 schools after the offset
        let limitParam = "$limit=12"
        let offsetParam = "$offset=\(self.schoolData.count)"
        let orderParam = "$order=:id"
        let url = "https://data.cityofnewyork.us/resource/97mf-9njv.json?\(limitParam)&\(offsetParam)&\(orderParam)"
        
        // I could have just used an NSURLSession, but I wanted to familiarize myself
        // with the swift version of AFNetworking (which I have used in objective-c projects)
        
        // check the response was a success and pass the resulting value to a const "value"
        Alamofire.request(url, parameters: nil, headers: nil)
            .responseJSON { response in
                guard response.result.isSuccess,
                    let value = response.result.value else {
                        print("Error while fetching school data: \(String(describing: response.result.error))")
                        DispatchQueue.main.async {
                            self.schoolTableView.reloadData()
                            self.isSchoolDataBeingFetched = false
                        }
                        return
                }
             
                // uncomment to print raw json value
                //print("raw value: \(value)");
                
                // map the each array item (school json) into a Basic school object and add it an array
                let nyc_schools : [BasicSchool]? = JSON(value).array?.map { school_json in
                    BasicSchool(json: school_json)
                }
                
                // add the newly created array of BasicSchool objects to my tableview data array
                if let schools = nyc_schools {
                    self.schoolData += schools
                }
                
                // reload the tableview to display the new results
                DispatchQueue.main.async {
                    self.schoolTableView.reloadData()
                    self.isSchoolDataBeingFetched = false
                }
        }
    }
    
    // MARK: - TableView delegate functions

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.schoolData.count // your number of cells here
    }
    
    // when a school is clicked, create an instance of the DetailedSchoolViewController,
    // pass it the BasicSchool object, and push the controller on the navigation stack.
    // The DetailedSchoolViewController will show additional details about the school,
    // and also fetch and display the SAT data (if the school has it available)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get the school clicked
        let school : BasicSchool = schoolData[indexPath.row]
        
        // pass it to the detailed school view controller
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DetailedSchoolViewController") as! DetailedSchoolViewController
        nextViewController.setInitialSchool(school)
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // if we are approaching the bottom of our school data list, fetch more
        if (indexPath.row >= self.schoolData.count - 3) {
            getSchoolData()
        }
        
        let school : BasicSchool = self.schoolData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicSchoolTableViewCell", for: indexPath) as! BasicSchoolTableViewCell
        
        cell.name.text = school.name
        cell.address.text = school.address
        
        // this formatting is not very percise or beautiful
        if let grade_range = school.finalgrades {
            cell.grade_range.text = "Grades : "
            cell.grade_range.text?.append(grade_range)
            cell.grade_range.text?.append("   | ") // border
        } else {
            cell.grade_range.text = ""
        }
        
        if let total_students = school.total_students {
            cell.num_students.text = "\(String(total_students)) students"
        } else {
            cell.num_students.text = ""
        }
        
        return cell
    }
    
}
