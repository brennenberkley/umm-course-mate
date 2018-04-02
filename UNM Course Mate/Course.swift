import Foundation

class Course:NSObject {
    var courseID: String = ""
    var subjectID: String = ""
    var sections = [Section]()
    var catalogDescription = ""
    var title: String = ""
    var credits = 0
    var note = ""
    var preRequisites = [String]()
    var coRequisites = [String]()
    var restrictions = ""
    var semestersOffered = ""
    
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        self.courseID = aDecoder.decodeObject(forKey: "courseID") as! String
        self.subjectID = aDecoder.decodeObject(forKey: "subjectID") as! String
        self.sections = aDecoder.decodeObject(forKey: "sections") as! [Section]
        self.catalogDescription = aDecoder.decodeObject(forKey: "catalogDescription") as! String
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.credits = aDecoder.decodeInteger(forKey: "credits")
        self.note = aDecoder.decodeObject(forKey: "note") as! String
        self.preRequisites = aDecoder.decodeObject(forKey: "preRequisites") as! [String]
        self.coRequisites = aDecoder.decodeObject(forKey: "coRequisites") as! [String]
        self.restrictions = aDecoder.decodeObject(forKey: "restrictions") as! String
        self.semestersOffered = aDecoder.decodeObject(forKey: "semestersOffered") as! String
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(courseID, forKey: "courseID")
        aCoder.encode(subjectID, forKey: "subjectID")
        aCoder.encode(sections, forKey: "sections")
        aCoder.encode(catalogDescription, forKey: "catalogDescription")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(credits, forKey: "credits")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(preRequisites, forKey: "preRequisites")
        aCoder.encode(coRequisites, forKey: "coRequisites")
        aCoder.encode(restrictions, forKey: "restrictions")
        aCoder.encode(semestersOffered, forKey: "semestersOffered")
    }
}
