import Foundation

class Instructor: NSObject {
    var primary = true
    var first:String = ""
    var last:String = ""
    
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        self.primary = aDecoder.decodeBool(forKey: "primary")
        self.first = aDecoder.decodeObject(forKey: "first") as! String
        self.last = aDecoder.decodeObject(forKey: "last") as! String
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(primary, forKey: "primary")
        aCoder.encode(first, forKey: "first")
        aCoder.encode(last, forKey: "last")
    }
}
