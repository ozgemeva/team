//
//  FilterModel.swift
//  iFlat
//
//  Created by Eren AY on 9.12.2016.
//  Copyright © 2016 SE 301. All rights reserved.
//

import Foundation

class FilterModel {
    
    var city : String?
    //var dateFrom : String?
    //var dateTo : String?
    var capacity : Int?
    
    var bathroomCount : Int?
    var bedCount : Int?
    var bedroomCount : Int?
    var smoking: Bool?
    var pool : Bool?
    var internet : Bool?
    var cooling : Bool?
    var heating : Bool?
    var tv : Bool?
    var washingMachine : Bool?
    var elevator : Bool?
    var parking : Bool?
    var gateKeeper : Bool?
    
    var priceFrom : Double?
    var priceTo : Double?

    var fromDate: Date?
    var toDate: Date?
    
    var fromDateTimeStamp:String?
    var toDateTimeStamp:String?
    
    
    init(){
        // will be removed
    }
    init(city:String?, capacity:Int?, bathroomcount:Int?, bedcount:Int?, bedroomcount:Int?,pool:Bool?,internet:Bool?,cooling:Bool?,heating:Bool?,tv:Bool?,washingMachine:Bool?,elevator:Bool?,parking:Bool?,gateKeeper:Bool?,priceFrom:Double?, priceTo:Double?, smoking:Bool?, fromDate:Date?, toDate:Date?) {
        
        self.city = city
        self.capacity = capacity
        self.bathroomCount = bathroomcount
        self.bedCount = bedcount
        self.bedroomCount = bedroomcount
        self.pool = pool
        self.internet = internet
        self.cooling = cooling
        self.heating = heating
        self.tv = tv
        self.washingMachine = washingMachine
        self.elevator = elevator
        self.parking = parking
        self.gateKeeper = gateKeeper
        self.priceFrom = priceFrom
        self.priceTo = priceTo
        self.smoking = smoking
        self.fromDate = fromDate
        self.toDate = toDate
    }
}
