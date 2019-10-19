//
//  main.swift
//  qrcf
//
//  Created by ku KUMAGAI Kentaro on 2019/10/19.
//  Copyright © 2019 ku KUMAGAI. All rights reserved.
//

import Foundation
import CoreImage
import Darwin


// https://dev.classmethod.jp/smartphone/iphone/ios-8ciqrcodefeature/
//
class QRCF {
    let version = "0.0.1"
    let detector: CIDetector

    init?() {
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]) else { return nil }
        self.detector = detector
    }

    func run() -> Int {
        let args = Array<String>(CommandLine.arguments.dropFirst())
        guard args.count > 0 else {
            fputs("usage: qrcf fileToRead ...", stderr)
            return 1
        }

        let showFilename = true
        for arg in args {
            let texts = detect(arg)
            if showFilename {
                fputs("\(arg)\t", stdout)
            }
            fputs(
                texts.map({ (text: String?) -> String in
                    if let text = text {
                        return text
                    } else {
                        return ""
                    }
                }).joined(separator: "\t"), stdout)
            fputs("\n", stdout)
        }
        return 0
    }

    func detect(_ file: String) -> [String?] {
        let url = URL(fileURLWithPath: file)
        guard let image = CIImage(contentsOf: url) else { return [] }

        let features = detector.features(in: image)
        return features.map { (feature) -> String? in
            guard let qr = feature as? CIQRCodeFeature else { return nil }
            return qr.messageString
        }
    }
}
//
//
guard let app = QRCF() else {
    fputs("failed to initialize CIDetector\n", stderr)
    exit(1)
}

app.run()
