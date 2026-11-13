import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// Windows runner ile aynı sabit içerik boyutu.
  private static let fixedContentSize = NSSize(width: 1280, height: 720)

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Sabit boyutlu pencere: boyutlandırma ve tam ekran yok, yalnızca
    // küçült ve kapat. Büyüt (yeşil) düğmesi devre dışı kalır.
    self.styleMask.remove(.resizable)
    self.collectionBehavior.insert(.fullScreenNone)
    self.setContentSize(MainFlutterWindow.fixedContentSize)
    self.contentMinSize = MainFlutterWindow.fixedContentSize
    self.contentMaxSize = MainFlutterWindow.fixedContentSize
    self.standardWindowButton(.zoomButton)?.isEnabled = false
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
