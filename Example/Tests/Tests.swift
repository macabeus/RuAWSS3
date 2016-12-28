// https://github.com/Quick/Quick

import Quick
import Nimble
import RuAWSS3
import PromiseKit

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("these will fail") {
            beforeEach {
                // IMPORTANT: Set your AWS S3 credentials
                /*AmazonS3.shared.performCredentials(
                    regionType: ** YOUR REGION **,
                    identityPoolId: ** YOUR POOL ID **
                )*/
            }

            it("upload image") {
                let testBundle = Bundle(for: type(of: self))
                let filePath = testBundle.path(forResource: "example", ofType: "jpg")!
                let image = UIImage(contentsOfFile: filePath)!
                
                waitUntil(timeout: 10) { done in
                    firstly {
                        AmazonS3.shared.uploadImage(
                            bucket: "eventbeeapp",
                            key: "image.jpg",
                            image: image
                        )
                    }.then {
                        done()
                    }.catch { error in
                        fail("Error when try upload the image: \((error as NSError).localizedDescription)")
                        done()
                    }
                }
            }
            
            it("download image") {
                waitUntil(timeout: 10) { done in
                    firstly {
                        AmazonS3.shared.download(
                            bucket: "eventbeeapp",
                            key: "image.jpg"
                        )
                    }.then { filePath -> Void in
                        done()
                    }.catch { error in
                        fail("Error when try download the image: \((error as NSError).localizedDescription)")
                        done()
                    }
                }
            }
            
            it("delete image") {
                waitUntil(timeout: 10) { done in
                    firstly {
                        AmazonS3.shared.delete(
                            bucket: "eventbeeapp",
                            key: "image.jpg"
                        )
                    }.then {
                        done()
                    }.catch { error in
                        fail("Error when try delete the image: \((error as NSError).localizedDescription)")
                        done()
                    }
                }
            }
        }
    }
}
