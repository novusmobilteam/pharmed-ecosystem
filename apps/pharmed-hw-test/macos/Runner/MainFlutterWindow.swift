import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// Açılış ve en küçük içerik boyutu (Windows runner ile aynı — #272).
  private static let initialContentSize = NSSize(width: 1280, height: 720)
  private static let minContentSize = NSSize(width: 1024, height: 640)

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Boyutlandırılabilir pencere (#272); en küçük boyut sınırlı.
    self.styleMask.insert(.resizable)
    self.setContentSize(MainFlutterWindow.initialContentSize)
    self.contentMinSize = MainFlutterWindow.minContentSize
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
