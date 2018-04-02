import Foundation

struct LoadStatus: OptionSet {
    let rawValue: Int
    static let notLoaded            = LoadStatus(rawValue: 1 << 0)
    static let downloading          = LoadStatus(rawValue: 1 << 1)
    static let processingDownload   = LoadStatus(rawValue: 1 << 2)
    static let downloadFailed       = LoadStatus(rawValue: 1 << 3)
    static let updating             = LoadStatus(rawValue: 1 << 4)
    static let processingUpdate     = LoadStatus(rawValue: 1 << 5)
    static let updateFailed         = LoadStatus(rawValue: 1 << 6)
    static let upToDate             = LoadStatus(rawValue: 1 << 7)
    
    static let loaded: LoadStatus = [.updating, .processingUpdate, .updateFailed, .upToDate]
    static let currentlyDownloading: LoadStatus = [.downloading, .processingDownload, .updating, .processingUpdate]
}
