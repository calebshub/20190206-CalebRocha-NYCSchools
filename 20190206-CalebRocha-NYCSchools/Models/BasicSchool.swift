//
//  BasicSchool.swift
//  20190206-CalebRocha-NYCSchools
//
//  Created by Caleb Admin on 2/18/19.
//  Copyright © 2019 Caleb Admin. All rights reserved.
//

import Foundation
import SwiftyJSON

class BasicSchool {
    
    // Basic school data
    var name : String
    var dbn : String                   // ID for the school
    var id : String                    // easier to remember
    var finalgrades : String?          // grades 6-12 or "School is structured on credit needs, not grade"
    var location : String?             // contains full address followed by (latitude, longitude)
    var latitude : String?
    var longitude : String?
    var address : String?              // will parse this from the location
    var total_students : Int?
    
    // Additional school data
    var overview_description : String?
    var phone_number : String?
    var email : String?
    var website : String?
    var extracurricular_activities : String?
    var academic_opportunities : [String]?
    
    // SAT data
    struct SATData {
        var num_test_takers : String?         // num_of_sat_test_takers
        var math_score : String?              // sat_math_avg_score
        var reading_score : String?           // sat_critical_reading_avg_score
        var writing_score : String?           // sat_writing_avg_score
    }
    
    var sat_data : SATData?
    
    init(json : JSON) {
        
        // Basic info
        name            = json["school_name"].stringValue
        dbn             = json["dbn"].stringValue
        id              = json["dbn"].stringValue
        finalgrades     = getGradeLevel(fromFinalGrades:json["finalgrades"].stringValue)
        location        = json["location"].stringValue
        latitude        = json["latitude"].stringValue
        longitude       = json["longitude"].stringValue
        address         = getAddress(fromLocation: location)
        total_students  = json["total_students"].intValue
        
        // Additional school data
        overview_description        = json["overview_paragraph"].stringValue
        phone_number                = json["phone_number"].stringValue
        email                       = json["school_email"].stringValue
        website                     = json["website"].stringValue
        extracurricular_activities  = json["extracurricular_activities"].stringValue
        academic_opportunities      = getAcademicOpportunities(fromJson: json)
    }
    
    func setSATDataWithJson (json : JSON) {
        sat_data = SATData()
        sat_data?.num_test_takers = json["num_of_sat_test_takers"].stringValue
        sat_data?.math_score =      json["sat_math_avg_score"].stringValue
        sat_data?.reading_score =   json["sat_critical_reading_avg_score"].stringValue
        sat_data?.writing_score =   json["sat_writing_avg_score"].stringValue
    }
}


 // if the first character of the string is a number (example: "6" in "6-12")
 // just return this value, otherwise, the school is based on credits, not grade level.
 // Create a simplified string to reflect this.

func getGradeLevel (fromFinalGrades finalGrades : String?) -> String? {
    
    var gradeLevel = finalGrades
    
    if let firstCharacter = finalGrades?.prefix(1) {
        let isANumber = Int(firstCharacter)
        if (isANumber == nil) {
            gradeLevel = "based on credits"
        } else {
        }
    }
    
    return gradeLevel
}

// getAddress takes a location string, and parses the address and stores it
//
// Example of a passed location:
// "143-10 Springfield Boulevard, Springfield Gardens NY 11413 (40.66903, -73.757744)

func getAddress (fromLocation location : String?) -> String? {
    return location?.components(separatedBy: "(").first
}

// getAcademicOpportunities takes a the json object, and parses each academic opportunity
// and places it an an array. The keys appear as academicopportunities1, academicopportunities2, ...
// The function searches the json for a match for a created indexed key and stops when there are
// no more matches.

func getAcademicOpportunities (fromJson json : JSON) -> [String]? {
    
    // create the key for the first index
    let baseKey = "academicopportunities"
    var currentIndex : Int = 1
    var academicOpportunityKey = baseKey + String(currentIndex)
    var opportunityArray : [String] = [] // to store all the academic opportunity strings
    
    // check if there is a match for the current key at index,
    // if so add it the array and incriment the index
    
    var academicOpportunity : String?
    academicOpportunity = json[academicOpportunityKey].stringValue
    
    while (academicOpportunity != nil && !academicOpportunity!.isEmpty) {
        opportunityArray.append(academicOpportunity!)
        currentIndex += 1
        academicOpportunityKey = baseKey + String(currentIndex)
        academicOpportunity = json[academicOpportunityKey].stringValue
    }
    
    return opportunityArray
}
