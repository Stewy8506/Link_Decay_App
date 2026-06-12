import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    
    // Set widescreen default dimensions (1000x700) and center the window
    let defaultSize = NSSize(width: 1000, height: 700)
    var newFrame = windowFrame
    newFrame.size = defaultSize
    if let screen = NSScreen.main {
      let screenFrame = screen.visibleFrame
      newFrame.origin.x = screenFrame.origin.x + (screenFrame.width - defaultSize.width) / 2
      newFrame.origin.y = screenFrame.origin.y + (screenFrame.height - defaultSize.height) / 2
    }
    self.setFrame(newFrame, display: true)
    
    // Enforce a minimum size so it can resize down to phone view but not smaller
    self.minSize = NSSize(width: 360, height: 500)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
