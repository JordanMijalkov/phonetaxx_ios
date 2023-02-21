//
//  CallDetailModel.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 27/05/21.
//

import Foundation

struct Call_LogDataModel {
    var documentID : [Call_LogData]?
}
struct Call_LogData{
    var callCategory : String?
    var  callDate : String?
    var callDateTimeLocal : String?
    var callDateTimeUTC : String?
    var callDurationInSecond : String?
    var callMonth : String?
    var callType : String?
    var callWeek : String?
    var callYear : String?
    var createdAt : String?
    var deleted : String?
    var name : String?
    var phoneNumber : String?
    var userUuid: String?
    var uuId : String?
}
