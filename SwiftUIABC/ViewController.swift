//
//  ViewController.swift
//  SwiftUIABC
//
//  Created by TrucPham on 10/06/2022.
//

import UIKit
import SwiftUI
import QuartzCore
class ViewController: UIViewController {
    private lazy var button : UIButton = {
        let v = UIButton()
        v.backgroundColor = .green
        v.setTitle("Navigate", for: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(buttonEnd), for: .touchUpInside)
        v.addTarget(self, action: #selector(buttonTap), for: .touchDown)
        return v
    }()
    fileprivate lazy var pulsator : Pulsator = {
        let pulsator = Pulsator()
        pulsator.numPulse = 5
        pulsator.radius = 200
        pulsator.animationDuration = 3
        pulsator.backgroundColor = UIColor(red: 0, green: 0.455, blue: 0.756, alpha: 1).cgColor
        return pulsator
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        //        // Do any additional setup after loading the view.
        //        self.view.backgroundColor = .red
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        let swiftUIView = ContentView() // swiftUIView is View
        //        let swiftUIControler = UIHostingController(rootView: swiftUIView)
        //        self.addChild(swiftUIControler)
        //        swiftUIControler.view.frame = view.bounds
        //        view.addSubview(swiftUIControler.view)
        //        swiftUIControler.didMove(toParent: self)
        //        let deviceId = getUUID()
        //        print("deviceId: \(deviceId)")
        
    }
    
    func getUUID() -> String? {
        
        // create a keychain helper instance
        let keychain = KeychainAccess()
        
        // this is the key we'll use to store the uuid in the keychain
        let uuidKey = "dev.ftel.cmr.camera.unique_uuid"
        
        // check if we already have a uuid stored, if so return it
        if let uuid = try? keychain.queryKeychainData(itemKey: uuidKey) {
            return uuid
        }
        
        // generate a new id
        let newId = UUID().uuidString
        
        // store new identifier in keychain
        try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)
        
        // return new id
        return newId
    }
    
    let viewRecorder : ViewRecorder = .init()
    @objc private func buttonTap(){
        pulsator.position = self.button.center
        self.view.layer.addSublayer(pulsator)
        pulsator.start()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let tempPath = paths[0] + "/exprotvideo.mp4"
        viewRecorder.startRecording(self.view, videoPath: tempPath, videoSize: self.view.bounds.size) { url in
            guard let url = url else { return }
            print(url)
            let videoURL = url
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    @objc func buttonEnd(){
        pulsator.removeFromSuperlayer()
        
        viewRecorder.stop()
    }
    
}

class Pulsator: CAReplicatorLayer {
    let kPulsatorAnimationKey = "pulsator"
    fileprivate let pulse = CALayer()
    fileprivate var animationGroup: CAAnimationGroup!
    
    
    var numPulse: Int = 1
    
    var radius: CGFloat = 200
    
    var animationDuration: TimeInterval = 3
    
    var fromValueForRadius: Float = 0.0
    
    var pulseInterval: TimeInterval = 0
    
    var timingFunction: CAMediaTimingFunction? = CAMediaTimingFunction(name: .default)
    
    /// private properties for resuming
    fileprivate weak var prevSuperlayer: CALayer?
    fileprivate var prevLayerIndex: Int?
    
    // MARK: - Initializer
    override init() {
        super.init()
        setupPulse()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(save),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resume),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    open override func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupPulse() {
        repeatCount = MAXFLOAT
        instanceCount = self.numPulse
        instanceDelay = max((animationDuration + pulseInterval) / Double(numPulse), 1)
        pulse.contentsScale = UIScreen.main.scale
        pulse.opacity = 0
        addSublayer(pulse)
        updatePulse()
    }
    
    fileprivate func setupAnimationGroup() {
        animationGroup = CAAnimationGroup()
        animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
        animationGroup.duration = animationDuration + pulseInterval
        animationGroup.repeatCount = repeatCount
        if let timingFunction = timingFunction {
            animationGroup.timingFunction = timingFunction
        }
    }
    
    fileprivate func createScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = fromValueForRadius
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = animationDuration
        return scaleAnimation
    }
    
    fileprivate func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.values = [1, 0.5, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.2, 1.0]
        return opacityAnimation
    }
    
    fileprivate func updatePulse() {
        let diameter: CGFloat = radius * 2
        pulse.bounds = CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: diameter, height: diameter))
        pulse.cornerRadius = radius
        pulse.backgroundColor = backgroundColor
    }
    
    // MARK: - Internal Methods
    
    @objc internal func save() {
        prevSuperlayer = superlayer
        prevLayerIndex = prevSuperlayer?.sublayers?.firstIndex(where: {$0 === self})
    }
    
    @objc private func resume() {
        if let prevSuperlayer = prevSuperlayer, let prevLayerIndex = prevLayerIndex {
            prevSuperlayer.insertSublayer(self, at: UInt32(prevLayerIndex))
        }
        if pulse.superlayer == nil {
            addSublayer(pulse)
        }
        let isAnimating = pulse.animation(forKey: kPulsatorAnimationKey) != nil
        // if the animationGroup is not nil, it means the animation was not stopped
        if let animationGroup = animationGroup, !isAnimating {
            pulse.add(animationGroup, forKey: kPulsatorAnimationKey)
        }
    }
    func start() {
        setupPulse()
        setupAnimationGroup()
        pulse.add(animationGroup, forKey: kPulsatorAnimationKey)
    }
    
    func stop() {
        pulse.removeAllAnimations()
        animationGroup = nil
    }
    
}
class KeychainAccess {
    
    func addKeychainData(itemKey: String, itemValue: String) throws {
        guard let valueData = itemValue.data(using: .utf8) else {
            print("Keychain: Unable to store data, invalid input - key: \(itemKey), value: \(itemValue)")
            return
        }
        
        //delete old value if stored first
        do {
            try deleteKeychainData(itemKey: itemKey)
        } catch {
            print("Keychain: nothing to delete...")
        }
        
        let queryAdd: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject,
            kSecValueData as String: valueData as AnyObject,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        let resultCode: OSStatus = SecItemAdd(queryAdd as CFDictionary, nil)
        
        if resultCode != 0 {
            print("Keychain: value not added - Error: \(resultCode)")
        } else {
            print("Keychain: value added successfully")
        }
    }
    
    func deleteKeychainData(itemKey: String) throws {
        let queryDelete: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject
        ]
        
        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)
        
        if resultCodeDelete != 0 {
            print("Keychain: unable to delete from keychain: \(resultCodeDelete)")
        } else {
            print("Keychain: successfully deleted item")
        }
    }
    
    func queryKeychainData (itemKey: String) throws -> String? {
        let queryLoad: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if resultCodeLoad != 0 {
            print("Keychain: unable to load data - \(resultCodeLoad)")
            return nil
        }
        
        guard let resultVal = result as? NSData, let keyValue = NSString(data: resultVal as Data, encoding: String.Encoding.utf8.rawValue) as String? else {
            print("Keychain: error parsing keychain result - \(resultCodeLoad)")
            return nil
        }
        return keyValue
    }
}

import AVKit
import AVFoundation

final class ViewRecorder: NSObject {
    
    // The array of screenshot images that go become the video
    var images = [UIImage]()
    
    // Let's hook into when the screen will be refreshed
    var displayLink: CADisplayLink?
    
    // Called when we're done writing the video
    var completion: ((URL?) -> Void)?
    
    // The view we're actively recording
    var sourceView: UIView?
    
    var videoPath : String = ""
    
    var videoSize : CGSize = .zero
    
    // Called to start the recording with the view to be recorded and completion closure
    func startRecording(_ view: UIView, videoPath : String, videoSize : CGSize = .init(width: 1280, height: 720), _ completion: @escaping (URL?) -> Void) {
        self.images = []
        self.videoSize = videoSize
        self.videoPath = videoPath
        self.completion = completion
        self.sourceView = view
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    // Called to stop recording and kick off writing of asset
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        writeToVideo(images: images, videoPath: videoPath, videoSize: videoSize, withCompletion: {[weak self] url in
            guard let _self = self else { return }
            _self.completion?(url)
        })
    }
    // Called every screen refresh to capture current visual state of the view
    @objc private func tick(_ displayLink: CADisplayLink) {
        guard let sourceView = sourceView else {
            return
        }
        let render = UIGraphicsImageRenderer(size: videoSize)
        let image = render.image { (ctx) in
            // Important to capture the presentation layer of the view for animation to be recorded
            sourceView.layer.presentation()?.render(in: ctx.cgContext)
        }
        images.append(image)
    }
    
    // Would contain code for async writing of video
    private func writeToVideo(images: [UIImage], videoPath : String, videoSize: CGSize, withCompletion: @escaping TPImagesToVideo.TPMovieMakerCompletion) {
        // Setup AVAsset pipeline and write to video and call completion...
        TPImagesToVideo().createMovieFrom(images: images, videoPath: videoPath, videoSize: videoSize, withCompletion: withCompletion)
        
    }
    
}




class TPImagesToVideo: NSObject{
    typealias TPMovieMakerCompletion = (URL) -> Void
    typealias TPMovieMakerUIImageExtractor = (AnyObject) -> UIImage?
    var assetWriter:AVAssetWriter!
    var writeInput:AVAssetWriterInput!
    var bufferAdapter:AVAssetWriterInputPixelBufferAdaptor!
    var videoSettings:[String : Any]!
    var frameTime:CMTime!
    var fileURL:URL!
    
    var completionBlock: TPMovieMakerCompletion?
    var movieMakerUIImageExtractor:TPMovieMakerUIImageExtractor?
    
    func videoSettings(width:Int, height:Int) -> [String: Any]{
        if(Int(width) % 16 != 0){
            print("warning: video settings width must be divisible by 16")
        }
        
        let videoSettings:[String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264,
                                           AVVideoWidthKey: width,
                                          AVVideoHeightKey: height]
        
        return videoSettings
    }
    
    func configVideo(_ path : String, size : CGSize, videoFPS: Int32 = 30) {
        if(FileManager.default.fileExists(atPath: path)){
            guard (try? FileManager.default.removeItem(atPath: path)) != nil else {
                print("remove path failed")
                return
            }
        }
        self.fileURL = URL(fileURLWithPath: path)
        self.videoSettings = videoSettings(width: Int(size.width), height: Int(size.height))
        
        self.assetWriter = try! AVAssetWriter(url: self.fileURL, fileType: AVFileType.mp4)
        self.writeInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        assert(self.assetWriter.canAdd(self.writeInput), "add failed")
        
        self.assetWriter.add(self.writeInput)
        let bufferAttributes:[String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)]
        self.bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.writeInput, sourcePixelBufferAttributes: bufferAttributes)
        self.frameTime = CMTimeMake(value: 1, timescale: videoFPS)
    }
    
    func createMovieFrom(urls: [URL], videoPath : String, videoSize: CGSize, withCompletion: @escaping TPMovieMakerCompletion){
        configVideo(videoPath, size: videoSize)
        self.createMovieFromSource(images: urls as [AnyObject], extractor:{(inputObject:AnyObject) ->UIImage? in
            return UIImage(data: try! Data(contentsOf: inputObject as! URL))}, withCompletion: withCompletion)
    }
    
    func createMovieFrom(images: [UIImage], videoPath : String, videoSize: CGSize, withCompletion: @escaping TPMovieMakerCompletion){
        configVideo(videoPath, size: videoSize)
        self.createMovieFromSource(images: images, extractor: {(inputObject:AnyObject) -> UIImage? in
            return inputObject as? UIImage}, withCompletion: withCompletion)
    }
    
    func createMovieFromSource(images: [AnyObject], extractor: @escaping TPMovieMakerUIImageExtractor, withCompletion: @escaping TPMovieMakerCompletion){
        self.completionBlock = withCompletion
        
        self.assetWriter.startWriting()
        self.assetWriter.startSession(atSourceTime: CMTime.zero)
        
        let mediaInputQueue = DispatchQueue(label: "mediaInputQueue")
        var i = 0
        let frameNumber = images.count
        
        self.writeInput.requestMediaDataWhenReady(on: mediaInputQueue){
            while(true){
                if(i >= frameNumber){
                    break
                }
                
                if (self.writeInput.isReadyForMoreMediaData){
                    var sampleBuffer:CVPixelBuffer?
                    autoreleasepool{
                        let img = extractor(images[i])
                        if img == nil{
                            i += 1
                            print("Warning: counld not extract one of the frames")
                            //continue
                        }
                        sampleBuffer = img!.convertToBuffer()//self.newPixelBufferFrom(image: img!)
                    }
                    if (sampleBuffer != nil){
                        if(i == 0){
                            self.bufferAdapter.append(sampleBuffer!, withPresentationTime: CMTime.zero)
                        }else{
                            let value = i - 1
                            let lastTime = CMTimeMake(value: Int64(value), timescale: self.frameTime.timescale)
                            let presentTime = CMTimeAdd(lastTime, self.frameTime)
                            self.bufferAdapter.append(sampleBuffer!, withPresentationTime: presentTime)
                        }
                        i = i + 1
                    }
                }
            }
            self.writeInput.markAsFinished()
            self.assetWriter.finishWriting {
                DispatchQueue.main.sync {
                    self.completionBlock!(self.fileURL)
                }
            }
        }
    }
}
extension UIImage {
        
    func convertToBuffer() -> CVPixelBuffer? {
        
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
