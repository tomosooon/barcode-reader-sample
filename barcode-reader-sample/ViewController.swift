//
//  ViewController.swift
//  barcode-reader-sample
//
//  Created by tomoaki saito on 2015/07/28.
//  Copyright (c) 2015年 tomoaki. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let captureSession = AVCaptureSession();
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    
    // 読み取り範囲（0 ~ 1.0の範囲で指定）
    let x: CGFloat = 0.1
    let y: CGFloat = 0.4
    let width: CGFloat = 0.8
    let height: CGFloat = 0.2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // カメラがあるか確認し，取得する
        self.captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        let inputDevice = AVCaptureDeviceInput(device: self.captureDevice, error: &error)
        if let inp = inputDevice {
            self.captureSession.addInput(inp)
        } else {
            println(error)
        }
        
        // カメラからの取得映像を画面全体に表示する
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer?.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.view.layer.insertSublayer(self.previewLayer, atIndex: 0)

        // metadata取得に必要な初期設定
        let metaOutput = AVCaptureMetadataOutput();
        metaOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue());
        self.captureSession.addOutput(metaOutput);
        
        // どのmetadataを取得するか設定する
        metaOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code];
        
        // どの範囲を解析するか設定する
        metaOutput.rectOfInterest = CGRectMake(y, 1-x-width, height, width)
        
        // 解析範囲を表すボーダービューを作成する
        let borderView = UIView(frame: CGRectMake(x * self.view.bounds.width, y * self.view.bounds.height, width * self.view.bounds.width, height * self.view.bounds.height))
        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = UIColor.redColor().CGColor
        self.view.addSubview(borderView)
        
        // capture session をスタートする
        self.captureSession.startRunning()
    }
    
    // 映像からmetadataを取得した場合に呼び出されるデリゲートメソッド
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // metadataが複数ある可能性があるためfor文で回す
        for data in metadataObjects {
            if data.type == AVMetadataObjectTypeEAN13Code {
                // 読み取りデータの全容をログに書き出す
                println("読み取りデータ：\(data)")
                println("データの文字列：\(data.stringValue)")
                println("データの位置：\(data.bounds)")
            }
        }
    }
}


