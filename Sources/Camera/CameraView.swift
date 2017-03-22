import UIKit
import AVFoundation

extension UIDeviceOrientation {
    
    func toAVCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeRight
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .unknown: fallthrough
        case .faceUp: fallthrough
        case .faceDown: return AVCaptureVideoOrientation.portrait
        }
    }
    
    func toRotatedDeviceOrientation() -> UIDeviceOrientation {
        
        let orientation: UIDeviceOrientation
        switch self {
        case .landscapeLeft: orientation = .landscapeRight
        case .landscapeRight: orientation = .landscapeLeft
        case .portrait: orientation = .portrait
        case .portraitUpsideDown: orientation = .portraitUpsideDown
        default: orientation = .portrait
        }
        return orientation
    }
}

protocol CameraViewDelegate: class {
  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint)
}

class CameraView: UIView, UIGestureRecognizerDelegate {

  lazy var closeButton: UIButton = self.makeCloseButton()
  lazy var flashButton: TripleButton = self.makeFlashButton()
  lazy var rotateButton: UIButton = self.makeRotateButton()
  fileprivate lazy var bottomContainer: UIView = self.makeBottomContainer()
  lazy var bottomView: UIView = self.makeBottomView()
  lazy var stackView: StackView = self.makeStackView()
  lazy var shutterButton: ShutterButton = self.makeShutterButton()
  lazy var doneButton: UIButton = self.makeDoneButton()
  lazy var focusImageView: UIImageView = self.makeFocusImageView()
  lazy var tapGR: UITapGestureRecognizer = self.makeTapGR()
  lazy var rotateOverlayView: UIView = self.makeRotateOverlayView()
  lazy var shutterOverlayView: UIView = self.makeShutterOverlayView()
  lazy var blurView: UIVisualEffectView = self.makeBlurView()
    
    lazy var navigationBar: UINavigationBar = self.makeNavigationBar()
    lazy var navigationItem: UINavigationItem = self.makeNavigationItem()
    lazy var closeBarButton: UIBarButtonItem = self.makeCloseBarButton()
    lazy var rotateBarButton: UIBarButtonItem = self.makeRotateBarButton()

  var timer: Timer?
  var previewLayer: AVCaptureVideoPreviewLayer?
  weak var delegate: CameraViewDelegate?

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.black
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  // MARK: - Setup

  func setup() {
    addGestureRecognizer(tapGR)

    switch Config.Camera.showNavigationBar {
    case true:
        [navigationBar, bottomContainer].forEach {
            addSubview($0)
        }
        navigationBar.pushItem(navigationItem, animated: false)
        navigationBar.g_pinUpward()
        navigationBar.g_pin(height: Config.Camera.NavigationBar.height)
        
        flashButton.g_pin(size: CGSize(width: 60, height: 44))
        
        
        
    case false:
        [closeButton, flashButton, rotateButton, bottomContainer].forEach {
            addSubview($0)
        }
        
        [closeButton, flashButton, rotateButton].forEach {
            $0.g_addShadow()
        }
        
        closeButton.g_pin(on: .top)
        closeButton.g_pin(on: .left)
        closeButton.g_pin(size: CGSize(width: 44, height: 44))
        
        flashButton.g_pin(on: .centerY, view: closeButton)
        flashButton.g_pin(on: .centerX)
        flashButton.g_pin(size: CGSize(width: 60, height: 44))
        
        rotateButton.g_pin(on: .top)
        rotateButton.g_pin(on: .right)
        rotateButton.g_pin(size: CGSize(width: 44, height: 44))
    }

    [bottomView, shutterButton].forEach {
      bottomContainer.addSubview($0)
    }

    [stackView, doneButton].forEach {
      bottomView.addSubview($0 as! UIView)
    }

    
    rotateOverlayView.addSubview(blurView)
    switch Config.Camera.showNavigationBar {
    case true:
        insertSubview(rotateOverlayView, belowSubview: navigationBar)
    case false:
        insertSubview(rotateOverlayView, belowSubview: rotateButton)
    }
    insertSubview(focusImageView, belowSubview: bottomContainer)
    insertSubview(shutterOverlayView, belowSubview: bottomContainer)

    bottomContainer.g_pinDownward()
    bottomContainer.g_pin(height: 80)
    bottomView.g_pinEdges()

    stackView.g_pin(on: .centerY, constant: -4)
    stackView.g_pin(on: .left, constant: 38)
    stackView.g_pin(size: CGSize(width: 56, height: 56))

    shutterButton.g_pinCenter()
    shutterButton.g_pin(size: CGSize(width: 60, height: 60))
    
    doneButton.g_pin(on: .centerY)
    doneButton.g_pin(on: .right, constant: -38)

    rotateOverlayView.g_pinEdges()
    blurView.g_pinEdges()
    shutterOverlayView.g_pinEdges()
  }

  func setupPreviewLayer(_ session: AVCaptureSession) {
    guard previewLayer == nil else { return }

    let layer = AVCaptureVideoPreviewLayer(session: session)
    layer?.autoreverses = true
    layer?.videoGravity = AVLayerVideoGravityResizeAspectFill

    self.layer.insertSublayer(layer!, at: 0)
    layer?.frame = self.layer.bounds

    if (layer?.connection.isVideoOrientationSupported)! {
        layer?.connection.videoOrientation = UIDevice.current.orientation.toRotatedDeviceOrientation().toAVCaptureVideoOrientation()
    }
    
    previewLayer = layer
  }
    
    func updateVideoOrientation(from orientation: UIDeviceOrientation) {
        guard let previewLayer = previewLayer, previewLayer.connection.isVideoOrientationSupported == true else {
            return
        }
        previewLayer.connection.videoOrientation = orientation.toAVCaptureVideoOrientation()
    }

  // MARK: - Action

  func viewTapped(_ gr: UITapGestureRecognizer) {
    let point = gr.location(in: self)

    focusImageView.transform = CGAffineTransform.identity
    timer?.invalidate()
    delegate?.cameraView(self, didTouch: point)

    focusImageView.center = point

    UIView.animate(withDuration: 0.5, animations: {
      self.focusImageView.alpha = 1
      self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }, completion: { _ in
      self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
        selector: #selector(CameraView.timerFired(_:)), userInfo: nil, repeats: false)
    })
  }

  // MARK: - Timer

  func timerFired(_ timer: Timer) {
    UIView.animate(withDuration: 0.3, animations: {
      self.focusImageView.alpha = 0
    }, completion: { _ in
      self.focusImageView.transform = CGAffineTransform.identity
    })
  }

  // MARK: - UIGestureRecognizerDelegate
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    let point = gestureRecognizer.location(in: self)

    return point.y > closeButton.frame.maxY
      && point.y < bottomContainer.frame.origin.y
  }

  // MARK: - Controls

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(Bundle.image("gallery_close"), for: UIControlState())

    return button
  }

  func makeFlashButton() -> TripleButton {
    let states: [TripleButton.State] = [
      TripleButton.State(title: "Gallery.Camera.Flash.Off".g_localize(fallback: "OFF"), image: Bundle.image("gallery_camera_flash_off")!),
      TripleButton.State(title: "Gallery.Camera.Flash.On".g_localize(fallback: "ON"), image: Bundle.image("gallery_camera_flash_on")!),
      TripleButton.State(title: "Gallery.Camera.Flash.Auto".g_localize(fallback: "AUTO"), image: Bundle.image("gallery_camera_flash_auto")!)
    ]

    let button = TripleButton(states: states)

    return button
  }

  func makeRotateButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(Bundle.image("gallery_camera_rotate"), for: UIControlState())

    return button
  }

  func makeBottomContainer() -> UIView {
    let view = UIView()

    return view
  }

  func makeBottomView() -> UIView {
    let view = UIView()
    view.backgroundColor = Config.Camera.BottomContainer.backgroundColor
    view.alpha = 0

    return view
  }

  func makeStackView() -> StackView {
    let view = StackView()

    return view
  }

  func makeShutterButton() -> ShutterButton {
    let button = ShutterButton()
    button.g_addShadow()

    return button
  }

  func makeDoneButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.setTitleColor(UIColor.lightGray, for: .disabled)
    button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
    button.setTitle("Gallery.Done".g_localize(fallback: "Done"), for: UIControlState())

    return button
  }

  func makeFocusImageView() -> UIImageView {
    let view = UIImageView()
    view.frame.size = CGSize(width: 110, height: 110)
    view.image = Bundle.image("gallery_camera_focus")
    view.backgroundColor = .clear
    view.alpha = 0

    return view
  }

  func makeTapGR() -> UITapGestureRecognizer {
    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
    gr.delegate = self

    return gr
  }

  func makeRotateOverlayView() -> UIView {
    let view = UIView()
    view.alpha = 0

    return view
  }

  func makeShutterOverlayView() -> UIView {
    let view = UIView()
    view.alpha = 0
    view.backgroundColor = UIColor.black

    return view
  }

  func makeBlurView() -> UIVisualEffectView {
    let effect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: effect)

    return blurView
  }
    
    func makeNavigationBar() -> UINavigationBar {
        let bar = UINavigationBar()
        bar.tintColor = Config.Camera.NavigationBar.tintColor
        
        if Config.Camera.NavigationBar.isTransparent {
            bar.setBackgroundImage(UIImage(), for: .default)
            bar.shadowImage = UIImage()
            bar.isTranslucent = true
        } else {
            bar.backgroundColor = Config.Camera.NavigationBar.backgroundColor
        }
        
        return bar
    }
    
    func makeNavigationItem() -> UINavigationItem {
        let navItem = UINavigationItem(title: "")
        navItem.leftBarButtonItem = closeBarButton
        navItem.titleView = flashButton
        navItem.rightBarButtonItem = rotateBarButton
        return navItem
    }
    
    func makeCloseBarButton() -> UIBarButtonItem {
        if let title = Config.Camera.NavigationBar.CloseBarButton.title {
            return UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        } else {
            return UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        }
        
    }
    
    func makeRotateBarButton() -> UIBarButtonItem {
        let image = Bundle.image("gallery_camera_rotate")
        let rotateBtn = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        return rotateBtn
    }

}
