//
//  DetailedSchoolViewController.swift
//  20190206-CalebRocha-NYCSchools
//
//  Created by Caleb Admin on 2/18/19.
//  Copyright © 2019 Caleb Admin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import MapKit

class DetailedSchoolViewController: UIViewController {
    
    // MARK: - View Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Main Info Container
    @IBOutlet weak var mainTitleContainer: UIView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteContainer: UIView!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    // Map Container
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    // SAT Container
    @IBOutlet weak var satContainer: UIView!
    @IBOutlet weak var satLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var satTitle: UILabel!
    @IBOutlet weak var satDescription: UILabel!
    @IBOutlet weak var mathContainer: UIView!
    @IBOutlet weak var mathScoreBar: UIView!
    @IBOutlet weak var mathScore: UILabel!
    @IBOutlet weak var readingContainer: UIView!
    @IBOutlet weak var readingScoreBar: UIView!
    @IBOutlet weak var readingScore: UILabel!
    @IBOutlet weak var writingScoreBar: UIView!
    @IBOutlet weak var writingScore: UILabel!
    @IBOutlet weak var writingContainer: UIView!
    
    // Additional School Info Container (School Overview)
    @IBOutlet weak var additionalSchoolInfoContainer: UIView!
    @IBOutlet weak var additionalSchoolInfoTitle: UILabel!
    @IBOutlet weak var overviewParagraph: UITextView!
    @IBOutlet weak var extraCarricularTextView: UITextView!
    @IBOutlet weak var academicOpportunitiesTextView: UITextView!
    
    // MARK: - Private Properties
    private var initialSchool : BasicSchool?
    private var didSetSATViews : Bool = false
    private var themeColor = UIColor.init(red: 0.0, green: 0.6, blue: 0.6, alpha: 1)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupViewDefaults()
    }
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
       
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // setup the view with the basic school data
        if let initialSchoolData = self.initialSchool {
            self.setViewWithSchool(initialSchoolData)
        }
    }
    
    func setupViewDefaults() {
        
        // create the font used for the main titles
        let mainTitleFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        // Main Data
        self.schoolName.font = mainTitleFont
        
        // add gesture recognizers for clicking basic info
        self.websiteContainer.isUserInteractionEnabled = true
        let webTap = UITapGestureRecognizer(target: self, action: #selector(self.navigateToWebView(_:)))
        self.websiteContainer.addGestureRecognizer(webTap)
        // long press on website
        let webLongPress = UILongPressGestureRecognizer(target: self, action: #selector(self.websiteLongPressed(_:)))
        self.websiteContainer.addGestureRecognizer(webLongPress)

        self.phoneContainer.isUserInteractionEnabled = true
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(self.phoneTapped(_:)))
        self.phoneContainer.addGestureRecognizer(phoneTap)
        
        self.emailContainer.isUserInteractionEnabled = true
        let emailTap = UITapGestureRecognizer(target: self, action: #selector(self.emailTapped(_:)))
        self.emailContainer.addGestureRecognizer(emailTap)
        
        self.locationContainer.isUserInteractionEnabled = true
        let locationTap = UITapGestureRecognizer(target: self, action: #selector(self.locationTapped(_:)))
        self.locationContainer.addGestureRecognizer(locationTap)
        // the address container will grow as more lines are needed to display the text
        self.locationLabel.numberOfLines = 0
        self.locationLabel.lineBreakMode = .byWordWrapping
        
        // SAT Data
        self.satTitle.font = mainTitleFont
        // start animating the SAT loading indicator
        self.satLoadingIndicator.hidesWhenStopped = true
        self.satLoadingIndicator.startAnimating()
        // round the edges of the score bars, adjust the fill color
        let scoreBarCornerRadius : CGFloat = 8.0 // half the hieght (wouldn't hardcode this)
        self.mathScoreBar.layer.cornerRadius = scoreBarCornerRadius
        self.mathScoreBar.clipsToBounds = true
        self.readingScoreBar.layer.cornerRadius = scoreBarCornerRadius
        self.readingScoreBar.clipsToBounds = true
        self.writingScoreBar.layer.cornerRadius = scoreBarCornerRadius
        self.writingScoreBar.clipsToBounds = true
        
        // Additional School Info
        self.additionalSchoolInfoTitle.font = mainTitleFont
        
        // 1) rounded corners
        self.overviewParagraph.layer.cornerRadius = 5
        self.overviewParagraph.clipsToBounds = true
        // 2) let the textview heights grow with the text by disabling scroll
        self.overviewParagraph.isScrollEnabled = false
        // 3) disable editing
        self.overviewParagraph.isEditable = false
        
        self.extraCarricularTextView.layer.cornerRadius = 5
        self.extraCarricularTextView.clipsToBounds = true
        self.extraCarricularTextView.isScrollEnabled = false
        self.extraCarricularTextView.isEditable = false
        
        self.academicOpportunitiesTextView.layer.cornerRadius = 5
        self.academicOpportunitiesTextView.clipsToBounds = true
        self.academicOpportunitiesTextView.isScrollEnabled = false
        self.academicOpportunitiesTextView.isEditable = false
    }
    
    func setViewWithSchool(_ school: BasicSchool) {
        
        // Main data
        self.schoolName.text = school.name
        self.emailLabel.text = school.email
        self.phoneLabel.text = school.phone_number
        self.websiteLabel.text = school.website
        self.locationLabel.text = school.address
        
        // Map View
        if let latitude = Double(school.latitude!), let longitude = Double(school.longitude!) {
           
            // center the map on the school
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let center = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion.init(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
            
            // add a marker on the actual school location
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView.addAnnotation(annotation)
        }
        
        // SAT data
        if let satData = school.sat_data {
            // once this school's SAT data has been fetched, we add it to the Basic School object.
            // That way, we don't have to keep fetching the SAT data from the server.
            self.setSatViews(withSATData:satData)
            self.satLoadingIndicator.stopAnimating()
        } else {
            // we haven't fetched the SAT data for this school yet
            // show loading indicator and fetch the data
            self.satLoadingIndicator.startAnimating()
            self.getSATData(forSchool:self.initialSchool!)
        }
        
        // Additional School Info
        self.setAdditionalSchoolInfoViews(school) 
    }
    
    func setSatViews(withSATData satData : BasicSchool.SATData) {
        
        if (self.didSetSATViews) {
            return
        }
        
        self.didSetSATViews = true
        
        self.satDescription.text = self.satDescription.text?.replacingOccurrences(of: "#", with: satData.num_test_takers ?? "")
        
        self.setSATScore(forScoreBar: self.mathScoreBar,
                         forScoreLabel: self.mathScore,
                         withScore: satData.math_score!)
        self.setSATScore(forScoreBar: self.readingScoreBar,
                         forScoreLabel: self.readingScore,
                         withScore: satData.reading_score!)
        self.setSATScore(forScoreBar: self.writingScoreBar,
                         forScoreLabel: self.writingScore,
                         withScore: satData.writing_score!)
        
        self.satLoadingIndicator.stopAnimating()
    }
    
    // function will update the score label and score bar for an SAT stat (math, reading, writing)
    func setSATScore(forScoreBar scoreBar: UIView,
                     forScoreLabel scoreLabel: UILabel,
                     withScore score : String)
    {
        guard let scoreNumber = Double(score) else {
            print("Error - sat score \"\(score)\" not convertable")
            return
        }
        
        // the score bar is made of a container view (unfilled portion) and a subview (filled portion)
        if let scoreBarFill : UIView = scoreBar.subviews.first {
            
            // set the fill color
            scoreBarFill.backgroundColor = themeColor
            
            // if we can find the width contriant,
            // illustrate the score (0 - 700) by adjusting the fill bar width
            if let constraint = (scoreBarFill.constraints.filter {
                $0.firstAttribute == .width && $0.secondAttribute == .notAnAttribute}.first)
            {
                let maxScore : Double = 700.0
                let maxBarWidth = Double(scoreBar.frame.size.width)
                let fillWidth = (scoreNumber/maxScore) * maxBarWidth
                
                // animate the constraint change
                constraint.constant = CGFloat(fillWidth)
                UIView.animate(withDuration: 1.75) {
                    scoreBar.layoutIfNeeded()
                }
                
                // set score label
                scoreLabel.text = score
            }
        }
    }
    
    func setAdditionalSchoolInfoViews(_ school: BasicSchool) {
        
        // set the overview and extra carricular text
        self.overviewParagraph.text = school.overview_description
        self.extraCarricularTextView.text = school.extracurricular_activities
        
        // clear placeholder text for academic opportunities.
        // Next, add each academic opportunities to the textview, prefixed with an index
        self.academicOpportunitiesTextView.text = ""
        var index = 1
        let total = school.academic_opportunities?.count ?? 0
        for opportunities in school.academic_opportunities! {
            self.academicOpportunitiesTextView.text += "\(index)) \(opportunities)"
            if (index < total) {
                // add a new line after each opportunity (except last)
                self.academicOpportunitiesTextView.text += "\n"
            }
            index += 1
        }
    }
    
    // network code would normally be in a network class
    
    // !!NOTE!! - some schools do not have SAT data,
    // or there is an issue with the API fetching results filted by "dbn".
    // This results in a successful request, but an empty result array
    func getSATData(forSchool school : BasicSchool) {
        
        // fetch the SAT data, specifying a school using the id or "dbn"
        let schoolIDParam = "dbn=\(school.id)"
        let url = "https://data.cityofnewyork.us/resource/f9bf-2cp4.json?\(schoolIDParam)"
        print("sat-url: \(url)");
        
        AF.request(url, parameters: nil, headers: nil)
            .responseJSON { response in
                guard response.result.isSuccess,
                    let value = response.result.value else {
                        print("Error while fetching SAT school data: \(String(describing: response.result.error))")
                        DispatchQueue.main.async {
                            // SAT data error
                            self.showSATError(errorMsg: nil)
                        }
                        return
                }
                
                print("raw json value: \(value)");
                
                self.satLoadingIndicator.stopAnimating()
                
                if let jsonSAT = JSON(value).array?.first {
                   
                    // set the SAT data for the school
                    self.initialSchool?.setSATDataWithJson(json: jsonSAT)
                    
                    if let satData : BasicSchool.SATData = self.initialSchool?.sat_data {
                        DispatchQueue.main.async {
                            if (!self.didSetSATViews) {
                                self.setSatViews(withSATData:satData)
                            }
                        }
                    }
                    
                } else {
                    // there was an empty array returned
                    // when fetching this school's SAT data!
                    self.showSATError(errorMsg: "School has no SAT data posted")
                }
        }
    }
    
    /*
     normally, this func would have an enum argument which
    could dictate how the views and messages are presented
     */
    func showSATError (errorMsg error : String?) {
        // SAT error
        self.satLoadingIndicator.stopAnimating()
        self.satDescription.textColor = UIColor.red
        if let errorToShow = error {
            self.satDescription.text = errorToShow
        } else {
            self.satDescription.text = "Error loading SAT data. Try again Later."
        }
    }
    
    // MARK: - gesture recognizer handlers
    // MARK: - Handle clicking on basic school info elements
    @objc func navigateToWebView(_ sender: UITapGestureRecognizer) {
        
        // launch the school website through the webview
        if let schoolWebsiteString = self.initialSchool?.website {
            
            // would allow the user the chance to copy the website to clipboard
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SingleWebViewController") as! SingleWebViewController
            nextViewController.setSchoolWebsite(schoolWebsiteString)
            self.navigationController?.pushViewController(nextViewController, animated: true)
        
        } else {
            // would show the user an error of some sort
        }
    }
    
    @objc func websiteLongPressed(_ sender: UILongPressGestureRecognizer) {
        // copy website
        if let website = self.initialSchool?.website {
            
            // create an alert controller
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // add an option to copy the phone number
            let copyAction =  UIAlertAction(title: "Copy School Website", style: .default) { (UIAlertAction) in
                UIPasteboard.general.string = website
                print("copied \(website) to pastboard")
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            optionMenu.addAction(copyAction)
            optionMenu.addAction(cancelAction)
            
            // present alert controller
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    // I would have added the chance to call the phone number directly,
    // but I am using the simulator in Xcode and have no way to properly test this.
    // Instead, copy trimmed phone number to pasteboard
    @objc func phoneTapped (_ sender: UITapGestureRecognizer) {
        
        // copy phone number
        if let phoneNumberString = self.initialSchool?.phone_number {
            
            // remove any non digits
            let trimmedPhoneNumber = phoneNumberString.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
            
            // create an alert controller
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // add an option to copy the phone number
            let copyAction =  UIAlertAction(title: "Copy Phone Number", style: .default) { (UIAlertAction) in
                UIPasteboard.general.string = trimmedPhoneNumber
                print("copied \(trimmedPhoneNumber) to pastboard")
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            optionMenu.addAction(copyAction)
            optionMenu.addAction(cancelAction)
            
            // present alert controller
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    // open email app or copy email to paste board
    @objc func emailTapped (_ sender: UITapGestureRecognizer) {
       
        if let email = self.initialSchool?.email {
            
            // create an alert controller
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // add an option to copy the phone number
            let copyAction =  UIAlertAction(title: "Copy Email", style: .default) { (UIAlertAction) in
                UIPasteboard.general.string = email
                print("copied \(email) to pastboard")
            }
            
            let sendEmail = UIAlertAction(title: "Send Email", style: .default) { (UIAlertAction) in
                if let url = URL(string: "mailto:\(email)") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            optionMenu.addAction(copyAction)
            optionMenu.addAction(sendEmail)
            optionMenu.addAction(cancelAction)
            
            // present alert controller
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    // copy address to paste board
    @objc func locationTapped (_ sender: UITapGestureRecognizer) {
        
        // copy address
        if let addressString = self.initialSchool?.address {
            
            // create an alert controller
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // add an option to copy the phone number
            let copyAction =  UIAlertAction(title: "Copy Address", style: .default) { (UIAlertAction) in
                UIPasteboard.general.string = addressString
                print("copied \(addressString) to pastboard")
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            optionMenu.addAction(copyAction)
            optionMenu.addAction(cancelAction)
            
            // present alert controller
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    // function to set the controller's initial basic school object
    func setInitialSchool(_ school: BasicSchool) {
        self.initialSchool = school
    }
}



