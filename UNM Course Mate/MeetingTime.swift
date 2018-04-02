import Foundation

class MeetingTime: NSObject {
    var startDate:String = ""
    var endDate:String = ""
    var days = [String]() // M T W R F S U
    var startTime:Int = 0
    var endTime:Int = 0
    var building:String = ""
    var buildingCode:String = ""
    var room:String = ""
    
    override init() {}
    
    func isEquivalentTo(comparison: MeetingTime) -> Bool {
        guard days.count == comparison.days.count else {
            return false
        }
        // if there are the same amount of days, check days
        if days.count > 0 {
            for i in 0...(days.count - 1) {
                if !(days[i] == comparison.days[i]) {
                    return false
                }
            }
        }
        // if false was not returned, that means days are equivalent, so check times
        if startTime == comparison.startTime && endTime == comparison.endTime {
            return true
        } else {
            return false //different times
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.startDate = aDecoder.decodeObject(forKey: "startDate") as! String
        self.endDate = aDecoder.decodeObject(forKey: "endDate") as! String
        self.days = aDecoder.decodeObject(forKey: "days") as! [String]
        self.startTime = aDecoder.decodeInteger(forKey: "startTime")
        self.endTime = aDecoder.decodeInteger(forKey: "endTime")
        self.building = aDecoder.decodeObject(forKey: "building") as! String
        self.buildingCode = aDecoder.decodeObject(forKey: "buildingCode") as! String
        self.room = aDecoder.decodeObject(forKey: "room") as! String
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(startDate, forKey: "startDate")
        aCoder.encode(endDate, forKey: "endDate")
        aCoder.encode(days, forKey: "days")
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
        aCoder.encode(building, forKey: "building")
        aCoder.encode(buildingCode, forKey: "buildingCode")
        aCoder.encode(room, forKey: "room")
        
    }
}
