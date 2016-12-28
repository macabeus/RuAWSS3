import Foundation
import AWSCore
import AWSS3
import PromiseKit

public class AmazonS3 {
    
    public static let shared = AmazonS3()
    
    let deviceDirectoryForUploads: URL
    let deviceDirectoryForDownloads: URL
    let fileManager = FileManager.default
    
    enum CacheErros: Int {
        case miss
        case noSuchKey
    }
    
    init() {
        // create temporary directory
        func createLocalTmpDirectory(_ directoryName: String) -> URL? {
            do {
                let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(directoryName)
                try
                    FileManager.default.createDirectory(
                        at: url,
                        withIntermediateDirectories: true,
                        attributes: nil)
                return url
            } catch let error as NSError {
                print("Creating \(directoryName) directory failed. Error: \(error)")
                return nil
            }
        }
        
        // a temporary directory is needed to upload photos,
        // because the Amazon's API does not work directly with NSData, but rather with URL
        self.deviceDirectoryForUploads = createLocalTmpDirectory("upload")!
        
        // we will also create a temporary directory for download,
        // because we will use as cache
        self.deviceDirectoryForDownloads = createLocalTmpDirectory("download")!
    }
    
    public func performCredentials(regionType: AWSRegionType, identityPoolId: String) {
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: regionType,
            identityPoolId: identityPoolId)
        let configuration = AWSServiceConfiguration(
            region: regionType,
            credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    fileprivate func checkDownloadCache(bucket: String, key: String) -> Promise<String> {
        let keyFullPath = key.components(separatedBy: "/")
        let keyDirectories = keyFullPath[0..<keyFullPath.count-1]
        var url = deviceDirectoryForDownloads
        keyDirectories.forEach { path in
            url.appendPathComponent(path)
        }
        
        return Promise { fulfill, reject -> Void in
            // create cache folder if needed
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("RuAWSS3 ERROR: Could not create cache folder")
                print(error.localizedDescription)
                return reject(error)
            }
            
            // check if the file exists in cache
            let fileCachePath = url.appendingPathComponent(keyFullPath.last!).systemPath()
            if fileManager.fileExists(atPath: fileCachePath) {
                // the file exists,
                // but we still need to check if it is not obsolete
                let attr = try! fileManager.attributesOfItem(atPath: url.path)
                let modDate = attr[FileAttributeKey.modificationDate] as! Date
                
                let request = AWSS3HeadObjectRequest()!
                request.bucket = bucket
                request.key = key
                AWSS3.default().headObject(request).continue({
                    task -> Any? in
                    
                    if let result = task.result,
                        ((result as AWSS3HeadObjectOutput) != nil) {
                        let servDate = result.lastModified!
                        if modDate < servDate {
                            // obsolete cache file; cache miss
                            return reject(NSError(domain: "miss", code: CacheErros.miss.rawValue, userInfo: nil))
                        }
                        
                        // cache hit
                        fulfill(fileCachePath)
                    } else {
                        // file has been deleted from S3; no such key
                        do {
                            try self.fileManager.removeItem(atPath: fileCachePath)
                        } catch let error as NSError {
                            print("RuAWSS3 ERROR: Could not delete old cache file")
                            print(error.localizedDescription)
                        }
                        return reject(NSError(domain: "no such key", code: CacheErros.noSuchKey.rawValue, userInfo: nil))
                    }
                    
                    return nil
                })
            } else {
                // file does not exist in cache; cache miss
                return reject(NSError(domain: "miss", code: CacheErros.miss.rawValue, userInfo: nil))
            }
        }
    }
    
    /**
     Download a file from S3
     - Parameter bucket: Bucket's name that you want get a file
     - Parameter key: Full file's path on bucket
     - Returns: Promise with string of the path of the downloaded file
    */
    public func download(bucket: String, key: String) -> Promise<String> {
        return Promise { fulfill, reject in
            firstly {
                checkDownloadCache(bucket: bucket, key: key)
            }.then { downloadPath -> Void in
                // cache hit; send cache file
                fulfill(downloadPath)
            }.catch { error in
                // cache miss
                let errorCode = CacheErros.init(rawValue: (error as NSError).code)!
                
                switch errorCode {
                case .noSuchKey:
                    // file does not exist in S3
                    reject(NSError(domain: "no such key", code: 0, userInfo: nil))
                case .miss:
                    // was cache miss; make download
                    let downloadRequest = AWSS3TransferManagerDownloadRequest()!
                    downloadRequest.bucket = bucket
                    downloadRequest.key = key
                    
                    let transferManager = AWSS3TransferManager.default()!
                    transferManager.download(downloadRequest).continue({
                        task in
                        
                        // error
                        if let error = task.error {
                            let errorCode = (error._userInfo as! [String: String])["Code"]!
                            
                            return reject(NSError(domain: errorCode, code: 0, userInfo: nil))
                        }
                        
                        // succes
                        let results = task.result! as! AWSS3TransferManagerDownloadOutput
                        let body = results.body as! URL
                        do {
                            let cachePath = self.deviceDirectoryForDownloads.appendingPathComponent(key)
                            if self.fileManager.fileExists(atPath: cachePath.systemPath()) {
                                try self.fileManager.removeItem(at: cachePath)
                            }
                            try self.fileManager.moveItem(at: body as URL, to: cachePath)
                            fulfill(cachePath.systemPath())
                        } catch let error as NSError {
                            print("RuAWSS3 ERROR: Error trying to move the file to the cache folder!")
                            print(error.localizedDescription)
                            fulfill(body.systemPath())
                        }
                        
                        return nil
                    })
                }
            }
        }
    }
    
    func imageToUrl(image: UIImage, fileName: String) -> URL {
        let fileURL = deviceDirectoryForUploads.appendingPathComponent(fileName)
        try! UIImagePNGRepresentation(image)?.write(to: fileURL, options: .atomic)
        return fileURL
    }
    
    /**
     Upload a file to S3
     - Parameter bucket: Bucket's name that you want upload a file
     - Parameter key: Path on S3 where the file will be stored
     - Parameter filePath: Path local of the file that you want to upload
     - Returns: Promise without parameters
    */
    public func upload(bucket: String, key: String, filePath: URL) -> Promise<Void> {
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = filePath
        uploadRequest.key = key
        uploadRequest.bucket = bucket
        
        let transferManager = AWSS3TransferManager.default()!
        
        return Promise { fulfill, reject in
            transferManager.upload(uploadRequest).continue({
                task in
                if let error = task.error {
                    let errorCode = (error._userInfo as! [String: String])["Code"]!
                    
                    reject(NSError(domain: errorCode, code: 0, userInfo: nil))
                } else {
                    fulfill()
                }
                
                return nil
            })
        }
    }
    
    /**
     Upload a image to S3
     - Parameter bucket: Bucket's name that you want upload a file
     - Parameter key: Path on S3 where the file will be stored
     - Parameter image: Image that you want to upload
     - Returns: Promise without parameters
    */
    public func uploadImage(bucket: String, key: String, image: UIImage) -> Promise<Void> {
        return self.upload(
            bucket: bucket,
            key: key,
            filePath: imageToUrl(image: image, fileName: key.components(separatedBy: "/").last!)
        )
    }
    
    public func delete(bucket: String, key: String) -> Promise<Void> {
        let deleteRequest = AWSS3DeleteObjectRequest()!
        deleteRequest.bucket = bucket
        deleteRequest.key = key
        
        return Promise { fulfill, reject in
            AWSS3.default().deleteObject(deleteRequest).continue({
                task -> Any? in
                
                if let error = task.error {
                    return reject(error)
                }
                
                fulfill()
                return nil
            })
        }
    }
}

extension URL {
    func systemPath() -> String {
        return self.absoluteString.replacingOccurrences(of: "file://", with: "")
    }
}

