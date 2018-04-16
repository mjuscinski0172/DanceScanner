//
//  Student.swift
//  DanceScanner
//
//  Created by Jimmy Rodriguez on 1/12/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import Foundation

class Student {
    //Student information
    var firstName: String
    var lastName: String
    var altIDNumber: String
    var idNumber: String
    //Checking in/out information
    var checkedInOrOut: String
    var checkInTime: String
    var checkOutTime: String
    //Guest information
    var guestName: String
    var guestSchool: String
    var guestParentPhone: String
    var guestCheckIn: String
    //Student's parent information
    var studentParentPhone: String
    var studentParentName: String
    var studentParentCell: String
    
    init(firstName f: String, lastName l: String, altIDNumber a: String, idNumber i: String, checkedInOrOut c: String, checkInTime t: String, checkOutTime o: String, guestName g: String, guestSchool s: String, guestParentPhone n: String, guestCheckIn gci: String, studentParentName spn: String, studentParentPhone spp: String, studentParentCell spc: String) {
        firstName = f
        lastName = l
        altIDNumber = a
        idNumber = i
        checkedInOrOut = c
        checkInTime = t
        checkOutTime = o
        guestName = g
        guestParentPhone = n
        guestSchool = s
        guestCheckIn = gci
        studentParentName = spn
        studentParentPhone = spp
        studentParentCell = spc
    }
}
