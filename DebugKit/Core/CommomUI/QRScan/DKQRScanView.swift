//
//  DKQRScanView.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/30.
//

import UIKit
import AVFoundation
import ImageIO

@objc protocol DKQRScanViewDelegate {
    func pickUp(scanView: DKQRScanView, message: String) -> Void
    func aroundBrigtness(scanView: DKQRScanView, brightnessValue: String) -> Void
}

class DKQRScanView: UIView {
    
    var scanRect: CGRect = .zero
    var isShowScanLine = true {
        didSet {
            showScanLine()
        }
    }
    var isShowCornerLine = true
    var isShowBorderLine = false
    
    let scanLineColor = UIColor(hex: 0xFF8903)
    let cornerLineColor = UIColor(hex: 0xFF8903)
    let borderLineColor = UIColor.white
    
    var forbidCameraAuth: (() -> Void)?
    var unopenCameraAuth: (() -> Void)?
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var deviceInput: AVCaptureDeviceInput?
    var dataOutput: AVCaptureMetadataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoDataOutput: AVCaptureVideoDataOutput?
    
    private let scanTime = 3.0
    private let borderLineWidth: CGFloat = 0.5
    private let cornerLineWidth: CGFloat = 1.5
    private let scanLineWidth: CGFloat = 42
    private let scanLineAnimationName = "scanLineAnimation"
    
    weak var delegate: DKQRScanViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupData()
    }
    
    func setupData() {
        let scanSize = CGSize(width: frame.size.width * 3/4, height: frame.size.width * 3/4)
        scanRect = CGRect(x: (frame.size.width - scanSize.width) / 2,
                          y: (frame.size.height - scanSize.height) / 2,
                          width: scanSize.width,
                          height: scanSize.height)
    }
    
    func setupViews() {
        addSubview(middleView)
        addSubview(_maskView)
        middleView.addSubview(scanLine)
        if isShowCornerLine {
            addCounerLines()
        }
        
        if isShowBorderLine {
            addScanBorderLine()
        }
    }
    
    // MARK: - Lazy
    lazy var middleView: UIView = {
        let middleView = UIView(frame: scanRect)
        middleView.clipsToBounds = true
        return middleView
    }()
    
    lazy var _maskView: UIView = {
        let maskView = UIView(frame: bounds)
        maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let fullBezierPath = UIBezierPath(rect: bounds)
        let scanBezierPath = UIBezierPath(rect: scanRect)
        fullBezierPath.append(scanBezierPath.reversing())
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = fullBezierPath.cgPath
        maskView.layer.mask = shapeLayer
        return maskView
    }()
    
    lazy var scanLine: UIView = {
        let scanLine = UIView(frame: CGRect(x: 0, y: 0, width: scanRect.size.width, height: scanLineWidth))
        scanLine.isHidden = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = scanLine.bounds
        gradientLayer.colors = [scanLineColor.withAlphaComponent(0).cgColor,
                                scanLineColor.withAlphaComponent(0.4).cgColor,
                                scanLineColor.cgColor]
        gradientLayer.locations = [0, 0.96, 0.97]
        scanLine.layer.addSublayer(gradientLayer)
        return scanLine
    }()

    
}

extension DKQRScanView {
    
    // MARK: - PrivateMethod
    func configCameraAndStart() {
        // 默认使用后置摄像头进行扫描,使用AVMediaTypeVideo表示视频
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        self.device = device
        //设备输入 初始化
        guard let deviceInput = try? AVCaptureDeviceInput.init(device: device) else { return }
        self.deviceInput = deviceInput
        //设备输出 初始化，并设置代理和回调，当设备扫描到数据时通过该代理输出队列，一般输出队列都设置为主队列，也是设置了回调方法执行所在的队列环境
        let dataOutput = AVCaptureMetadataOutput()
        self.dataOutput = dataOutput
        dataOutput.setMetadataObjectsDelegate(self, queue: .main)
        
        //会话 初始化，通过 会话 连接设备的 输入 输出
        let session = AVCaptureSession()
        self.session = session
        // 设置采样质量
        if device.supportsSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        } else {
            session.sessionPreset = .high
        }
        
        //会话添加设备的 输入 输出，建立连接
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
        }
        
        if dataOutput.availableMetadataObjectTypes.contains(.qr) {
            dataOutput.metadataObjectTypes = [.qr]
        }
        
        // 获取光线强弱
        let videoDataOutput = AVCaptureVideoDataOutput()
        self.videoDataOutput = videoDataOutput
        videoDataOutput.setSampleBufferDelegate(self, queue: .main)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer = previewLayer
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.frame
        self.layer.insertSublayer(previewLayer, at: 0)
        session.startRunning()
        dataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: self.scanRect)
        self.showScanLine()
    }
    
    func addScanLineAnimation() {
        scanLine.isHidden = false
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = -scanLineWidth
        animation.toValue = scanRect.size.height - scanLineWidth
        animation.duration = scanTime
        animation.repeatCount = MAXFLOAT
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scanLine.layer.add(animation, forKey: scanLineAnimationName)
    }
    
    func removeScanLineAnimation() {
        scanLine.layer.removeAnimation(forKey: scanLineAnimationName)
        scanLine.isHidden = true
    }
    
    var isCameraAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }
    var isFrontCameraAvailable: Bool { UIImagePickerController.isCameraDeviceAvailable(.front) }
    var isRearCameraAvailable: Bool { UIImagePickerController.isCameraDeviceAvailable(.rear) }
    var isCameraAuthStatusCorrect: Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .authorized {
            return true
        } else if (authStatus == .notDetermined) {
            AVCaptureDevice.requestAccess(for: .video) { grented in
                if !grented {
                    DispatchQueue.main.async {
                        if let forbidCameraAuth = self.forbidCameraAuth {
                            forbidCameraAuth()
                        }
                    }
                }
            }
            return true
        }
        return false
    }
    
    var statusCheck: Bool {
        if !isCameraAvailable {
            DebugKit.alert(message: "设备无相机——设备无相机功能，无法进行扫描", ok: nil, cancel: nil)
            return false
        }
        
        if !isRearCameraAvailable && !isFrontCameraAvailable {
            DebugKit.alert(message: "设备相机错误——无法启用相机，请检查", ok: nil, cancel: nil)
            return false
        }
        
        if !isCameraAuthStatusCorrect {
            DebugKit.alert(message: "相机权限未开启，请到「设置-隐私-相机」中允许DoKit访问您的相机") {
                DebugKit.openAppSetting()
            } cancel: {
                if let unopenCameraAuth = self.unopenCameraAuth {
                    unopenCameraAuth()
                }
            }
            return false
        }
        return true
    }
    
    func showScanLine() {
        if isShowScanLine {
            addScanLineAnimation()
        } else {
            removeScanLineAnimation()
        }
    }
    
    // MARK: bezierPath
    func addScanBorderLine() {
        let borderRect = CGRect(x: scanRect.origin.x + borderLineWidth,
                                y: scanRect.origin.y + borderLineWidth,
                                width: scanRect.size.width - 2 * borderLineWidth,
                                height: scanRect.size.height - 2 * borderLineWidth)
        let scanBezierPath = UIBezierPath(rect: borderRect)
        let lineLayer = CAShapeLayer()
        lineLayer.path = scanBezierPath.cgPath
        lineLayer.lineWidth = borderLineWidth
        lineLayer.strokeColor = borderLineColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(lineLayer)
    }
    
    func addCounerLines() {
        let lineLayer = CAShapeLayer()
        lineLayer.lineWidth = cornerLineWidth
        lineLayer.strokeColor = cornerLineColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        let halfLineLong = scanRect.size.width / 12.0
        let lineBezierPath = UIBezierPath()
        
        let spacing = cornerLineWidth / 2
        
        let leftUpPoint = CGPoint(x: scanRect.origin.x + spacing, y: scanRect.origin.y + spacing)
        lineBezierPath.move(to: CGPoint(x: leftUpPoint.x, y: leftUpPoint.y + halfLineLong))
        lineBezierPath.addLine(to: leftUpPoint)
        lineBezierPath.addLine(to: CGPoint(x: leftUpPoint.x + halfLineLong, y: leftUpPoint.y))
        lineLayer.path = lineBezierPath.cgPath
        layer.addSublayer(lineLayer)
        
        let leftDownPoint = CGPoint(x: scanRect.origin.x + spacing, y: scanRect.origin.y + scanRect.size.height - spacing)
        lineBezierPath.move(to: CGPoint(x: leftDownPoint.x, y: leftDownPoint.y - halfLineLong))
        lineBezierPath.addLine(to: leftDownPoint)
        lineBezierPath.addLine(to: CGPoint(x: leftDownPoint.x + halfLineLong, y: leftDownPoint.y))
        lineLayer.path = lineBezierPath.cgPath
        layer.addSublayer(lineLayer)
        
        let rightUpPoint = CGPoint(x: scanRect.origin.x + scanRect.size.width - spacing,
                                    y: scanRect.origin.y + spacing)
        lineBezierPath.move(to: CGPoint(x: rightUpPoint.x - halfLineLong, y: rightUpPoint.y))
        lineBezierPath.addLine(to: rightUpPoint)
        lineBezierPath.addLine(to: CGPoint(x: rightUpPoint.x, y: rightUpPoint.y + halfLineLong))
        lineLayer.path = lineBezierPath.cgPath
        layer.addSublayer(lineLayer)
        
        
        let rightDownPoint = CGPoint(x: scanRect.origin.x + scanRect.size.width - spacing,
                                    
                                     y: scanRect.origin.y + scanRect.size.height - spacing)
        lineBezierPath.move(to: CGPoint(x: rightDownPoint.x - halfLineLong, y: rightDownPoint.y))
        lineBezierPath.addLine(to: rightDownPoint)
        lineBezierPath.addLine(to: CGPoint(x: rightDownPoint.x, y: rightDownPoint.y - halfLineLong))
        lineLayer.path = lineBezierPath.cgPath
        layer.addSublayer(lineLayer)
        
    }
    
    // MARK: - PublicMethod
    /// 第一次调用会初始化相机相关并开始扫描之后调用，可在暂停后恢复
    func startScanning() {
        if !statusCheck { return }
        
        guard let session = self.session else {
            setupViews()
            configCameraAndStart()
            return
        }
        
        if session.isRunning {
            return
        }
        
        session.startRunning()
        showScanLine()
    }
    
    /// 暂停扫描
    func stopScanning() {
        guard let session = self.session else { return }
        
        if session.isRunning {
            session.stopRunning()
        }
        
        // 自动开启手电筒后，在执行了stopRunning时系统会关闭手电筒，这时重新打开手电筒，效果会闪一下
        if let device = device,
           device.torchMode == .on {
            try? device.lockForConfiguration()
            device.torchMode = .on
            device.unlockForConfiguration()
        }
        
        isShowScanLine = false
        showScanLine()
    }
    
}

extension DKQRScanView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0,
              let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let result = metadataObj.stringValue else {
            return
        }
        
        stopScanning()
        
        DebugKit.log("QR: \(result)")
        guard let delegate = delegate else { return }
        delegate.pickUp(scanView: self, message: result)
    }
}

extension DKQRScanView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let metadataDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate) else { return }
        let metadata = NSMutableDictionary(dictionary: metadataDict)
        
        guard let exifMetadata = metadata[kCGImagePropertyExifDictionary] as? NSDictionary,
              let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue] as? String else {
            return
        }
        
        guard let delegate = delegate else { return }
        delegate.aroundBrigtness(scanView: self, brightnessValue: brightnessValue)
    }
}
