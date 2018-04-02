import Foundation

class Semester:NSObject, NSCoding {
    var semesterID: String = ""
    var subjects = [Subject]()
    
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        self.semesterID = aDecoder.decodeObject(forKey: "semesterID") as! String
        self.subjects = aDecoder.decodeObject(forKey: "subjects") as! [Subject]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(semesterID, forKey: "semesterID")
        aCoder.encode(subjects, forKey: "subjects")
    }
}

