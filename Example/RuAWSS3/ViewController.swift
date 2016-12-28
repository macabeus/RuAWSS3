//
//  ViewController.swift
//  RuAWSS3
//
//  Created by Macabeus on 12/25/2016.
//  Copyright (c) 2016 Macabeus. All rights reserved.
//

import UIKit
import PromiseKit
import RuAWSS3

class ViewController: UIViewController {

    @IBOutlet weak var txtViewLogs: UITextView!
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        txtViewLogs.appendLine(text: "WARNING: You need uncomment code on AppDelegat(_:didFinishLaunchingWithOptions) at AppDelegate.swift! Otherwise, this example will not work!!")
    }
    
    @IBAction func btnUploadImage(_ sender: Any) {
        txtViewLogs.appendLine(text: "------------------------------")
        txtViewLogs.appendLine(text: "Iniciando upload da imagem...")
        
        firstly {
            AmazonS3.shared.uploadImage(
                bucket: "eventbeeapp",
                key: "image.jpg",
                image: #imageLiteral(resourceName: "example")
            )
        }.then {
            self.txtViewLogs.appendLine(text: "... success! 😄")
        }.catch { error in
            self.txtViewLogs.appendLine(text: "... error 😧")
            self.txtViewLogs.appendLine(text: (error as NSError).localizedDescription)
        }
    }
    
    @IBAction func btnDownloadImage(_ sender: Any) {
        txtViewLogs.appendLine(text: "------------------------------")
        txtViewLogs.appendLine(text: "Iniciando download...")
        
        firstly {
            AmazonS3.shared.download(
                bucket: "eventbeeapp",
                key: "image.jpg"
            )
        }.then { filePath -> Void in
            self.imgView.image = UIImage(contentsOfFile: filePath)!
            self.txtViewLogs.appendLine(text: "... success! 😄")
            self.txtViewLogs.appendLine(text: "Imagem baixada no diretório \(filePath)")
        }.catch { error in
            self.txtViewLogs.appendLine(text: "... error 😧")
            self.txtViewLogs.appendLine(text: (error as NSError).localizedDescription)
        }
    }
    
    @IBAction func btnDeleteImage(_ sender: Any) {
        txtViewLogs.appendLine(text: "------------------------------")
        txtViewLogs.appendLine(text: "Deletando imagem...")
        
        firstly {
            AmazonS3.shared.delete(
                bucket: "eventbeeapp",
                key: "image.jpg"
            )
        }.then {
            self.txtViewLogs.appendLine(text: "... success! 😄")
        }.catch { error in
            self.txtViewLogs.appendLine(text: "... error 😧")
            self.txtViewLogs.appendLine(text: (error as NSError).localizedDescription)
        }
    }
    
    @IBAction func btnUploadText(_ sender: Any) {
        txtViewLogs.appendLine(text: "------------------------------")
        txtViewLogs.appendLine(text: "Iniciando upload do arquivo de texto...")
        
        let textFilePath = createExampleTextFile()
        
        firstly {
            AmazonS3.shared.upload(
                bucket: "eventbeeapp",
                key: "text.txt",
                filePath: textFilePath
            )
        }.then {
            self.txtViewLogs.appendLine(text: "... success! 😄")
        }.catch { error in
            self.txtViewLogs.appendLine(text: "... error 😧")
            self.txtViewLogs.appendLine(text: (error as NSError).localizedDescription)
        }
    }
    
    @IBAction func btnDownloadText(_ sender: Any) {
        txtViewLogs.appendLine(text: "------------------------------")
        txtViewLogs.appendLine(text: "Iniciando download do arquivo de texto...")

        firstly {
            AmazonS3.shared.download(
                bucket: "eventbeeapp",
                key: "text.txt"
            )
        }.then { filePath -> Void in
            self.txtViewLogs.appendLine(text: "... success on download! 😄")
            do {
                let text = try String(contentsOfFile: filePath)
                self.txtViewLogs.appendLine(text: "Text on file: '\(text)'")
            } catch {
                print("Falha ao tentar ler o arquivo de texto baixado... 😕, Error: " + error.localizedDescription)
            }
        }.catch { error in
            self.txtViewLogs.appendLine(text: "... error 😧")
            self.txtViewLogs.appendLine(text: (error as NSError).localizedDescription)
        }
    }
    
    @IBAction func btnDeleteText(_ sender: Any) {
        txtViewLogs.appendLine(text: "------------------------------")
        txtViewLogs.appendLine(text: "Deletando texto...")
        
        firstly {
            AmazonS3.shared.delete(
                bucket: "eventbeeapp",
                key: "text.txt"
            )
            }.then {
                self.txtViewLogs.appendLine(text: "... success! 😄")
            }.catch { error in
                self.txtViewLogs.appendLine(text: "... error 😧")
                self.txtViewLogs.appendLine(text: (error as NSError).localizedDescription)
        }
    }
    
    // função não muito importante...
    func createExampleTextFile() -> URL {
        let docDirectory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let fileURL = docDirectory!.appendingPathComponent("someText").appendingPathExtension("txt")
        let outString = "It is work =)"
        do {
            try outString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed writing in text file example! Error: " + error.localizedDescription)
        }
        
        return fileURL
    }
}

extension UITextView {
    func appendLine(text: String) {
        self.text = text + "\n" + self.text
    }
}
