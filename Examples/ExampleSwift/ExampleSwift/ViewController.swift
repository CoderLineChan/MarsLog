//
//  ViewController.swift
//  ExampleSwift
//
//  Created by CoderChan on 10/31/25.
//

import UIKit
import MarsLog

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        AppLog.log("viewDidLoad")
    }


}

struct AppLog {
    static func log(_ message: String, file: String = #file, line: Int32 = #line, function: String = #function) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        
        MarsLogger.shared().log(with: .info, moduleName: "999", fileName: file, lineNumber: line, funcName: function, message: message)
    }
}
