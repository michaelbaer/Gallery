import UIKit
import Lightbox
import AVFoundation
import AVKit
import Gallery

class ViewController: UIViewController, LightboxControllerDismissalDelegate, GalleryControllerDelegate {

  var button: UIButton!
  var gallery: GalleryController!
  let editor: VideoEditing = VideoEditor()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white

    Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
    Gallery.Config.Grid.TopView.backgroundColor = UIColor.yellow
    Gallery.Config.Grid.TopView.height += UIApplication.shared.statusBarFrame.height
    Gallery.Config.Grid.TopView.isNavigationBar = true
    Gallery.Config.Grid.NavigationBar.CloseBarButton.title = "Schließen"
    Gallery.Config.Grid.NavigationBar.tintColor = UIColor.red
    Gallery.Config.Grid.ArrowButton.tintColor = UIColor.red
    
    Gallery.Config.Camera.showNavigationBar = true
    Gallery.Config.Camera.NavigationBar.height = Gallery.Config.Grid.TopView.height
    Gallery.Config.Camera.NavigationBar.CloseBarButton.title = "Schließen"
    Gallery.Config.Camera.NavigationBar.backgroundColor = UIColor(red: 109/255, green: 107/255, blue: 132/255, alpha: 0)
    Gallery.Config.Camera.NavigationBar.tintColor = UIColor.red
    
    Gallery.Config.Grid.FrameView.borderColor = UIColor.blue
    Gallery.Config.Grid.FrameView.fillColor = UIColor.red

    button = UIButton(type: .system)
    button.frame.size = CGSize(width: 200, height: 50)
    button.setTitle("Open Gallery", for: UIControlState())
    button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)

    view.addSubview(button)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    button.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
  }

  func buttonTouched(_ button: UIButton) {
    gallery = DemoGalleryViewController()
    gallery.pages = [GalleryController.Page.images, GalleryController.Page.camera]
    gallery.firstShownPage = .images
    gallery.delegate = self

    present(gallery, animated: true, completion: nil)
  }

  // MARK: - LightboxControllerDismissalDelegate

  func lightboxControllerWillDismiss(_ controller: LightboxController) {
    gallery.reload(controller.images.flatMap({ $0.image }))
  }

  // MARK: - GalleryControllerDelegate

  func galleryControllerDidCancel(_ controller: GalleryController) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }

  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil


    editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
      DispatchQueue.main.async {
        print(editedVideo)
        if let tempPath = tempPath {
          let data = NSData(contentsOf: tempPath)
          print(data?.length)
          let controller = AVPlayerViewController()
          controller.player = AVPlayer(url: tempPath)

          self.present(controller, animated: true, completion: nil)
        }
      }
    }
  }

  func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }

  func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage]) {
    LightboxConfig.DeleteButton.enabled = true

    let lightbox = LightboxController(images: images.map({ LightboxImage(image: $0) }), startIndex: 0)
    lightbox.dismissalDelegate = self

    controller.dismiss(animated: true, completion: nil)
  }
}

