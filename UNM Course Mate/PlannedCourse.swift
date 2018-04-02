import Foundation

class PlannedCourse: NSObject, NSCoding {
    var subjectID: String = ""
    var courseID: String = ""
    var title: String = ""
    var credits: Int = 0
    
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        subjectID = aDecoder.decodeObject(forKey: "subjectID") as! String
        courseID = aDecoder.decodeObject(forKey: "courseID") as! String
        title = aDecoder.decodeObject(forKey: "title") as! String
        credits = aDecoder.decodeInteger(forKey: "credits")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(subjectID, forKey: "subjectID")
        aCoder.encode(courseID, forKey: "courseID")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(credits, forKey: "credits")
    }
}
