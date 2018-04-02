import Foundation

class Subject:NSObject {
    var subjectID:String = ""
    var courses = [Course]()
    var name:String = ""
    
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        self.subjectID = aDecoder.decodeObject(forKey: "subjectID") as! String
        self.courses = aDecoder.decodeObject(forKey: "courses") as! [Course]
        self.name = aDecoder.decodeObject(forKey: "name") as! String
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(subjectID, forKey: "subjectID")
        aCoder.encode(courses, forKey: "courses")
        aCoder.encode(name, forKey: "name")
    }
}
