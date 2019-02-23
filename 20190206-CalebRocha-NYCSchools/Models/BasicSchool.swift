//
//  BasicSchool.swift
//  20190206-CalebRocha-NYCSchools
//
//  Created by Caleb Admin on 2/18/19.
//  Copyright © 2019 Caleb Admin. All rights reserved.
//

import Foundation

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
    
    init(json : [String:Any]) {
        
        // Basic info
        name            = json["school_name"] as? String ?? ""
        dbn             = json["dbn"] as? String ?? ""
        id              = json["dbn"] as? String ?? ""
        finalgrades     = getGradeLevel(fromFinalGrades:json["finalgrades"] as? String)
        location        = json["location"] as? String
        latitude        = json["latitude"] as? String
        longitude       = json["longitude"] as? String
        address         = getAddress(fromLocation: location)
        // check, because total_students value is being serialized into a String
        if let studentCount = json["total_students"] as? Int  {
            total_students  = studentCount
        } else if let studentCountString = json["total_students"] as? String {
            total_students = Int(studentCountString)
        }
        
        // Additional school data
        overview_description        = json["overview_paragraph"] as? String
        phone_number                = json["phone_number"] as? String
        email                       = json["school_email"] as? String
        website                     = json["website"] as? String
        extracurricular_activities  = json["extracurricular_activities"] as? String
        academic_opportunities      = getAcademicOpportunities(fromJson: json)
    }
    
    //func setSATDataWithJson (json : JSON) {
    func setSATDataWithJson (json : [String:Any]) {
        sat_data = SATData()
        sat_data?.num_test_takers = json["num_of_sat_test_takers"] as? String
        sat_data?.math_score =      json["sat_math_avg_score"] as? String
        sat_data?.reading_score =   json["sat_critical_reading_avg_score"] as? String
        sat_data?.writing_score =   json["sat_writing_avg_score"] as? String
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

func getAcademicOpportunities (fromJson json : [String:Any]) -> [String]? {
    
    // create the key for the first index
    let baseKey = "academicopportunities"
    var currentIndex : Int = 1
    var academicOpportunityKey = baseKey + String(currentIndex)
    var opportunityArray : [String] = [] // to store all the academic opportunity strings
    
    // check if there is a match for the current key at index,
    // if so add it the array and incriment the index
    
    var academicOpportunity : String?
    academicOpportunity = json[academicOpportunityKey] as? String
    
    while (academicOpportunity != nil && !academicOpportunity!.isEmpty) {
        opportunityArray.append(academicOpportunity!)
        currentIndex += 1
        academicOpportunityKey = baseKey + String(currentIndex)
        academicOpportunity = json[academicOpportunityKey] as? String
    }
    
    return opportunityArray
}
