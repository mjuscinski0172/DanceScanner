//
//  Student.swift
//  DanceScanner
//
//  Created by Jimmy Rodriguez on 1/12/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import Foundation

class Student {
    var firstName: String
    var lastName: String
    var altIDNumber: String
    var idNumber: String
    var checkedInOrOut: String
    var checkInTime: String
    var checkOutTime: String
    
    init(firstName f: String, lastName l: String, altIDNumber a: String, idNumber i: String, checkedInOrOut c: String, checkInTime t: String, checkOutTime o: String) {
        firstName = f
        lastName = l
        altIDNumber = a
        idNumber = i
        checkedInOrOut = c
        checkInTime = t
        checkOutTime = o
    }
}
