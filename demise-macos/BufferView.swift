import Cocoa

class LineWrapper {
    var line: CTLine
    var x: CGFloat
    var y: CGFloat

    init(line: CTLine, x: CGFloat, y: CGFloat) {
        self.line = line
        self.x = x
        self.y = y
    }
}

class PointView : NSView {
    var animation: CAKeyframeAnimation?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        animation = CAKeyframeAnimation.init(keyPath: "opacity")
        animation!.values = [1, 0]
        animation!.duration = 0.7
        animation!.keyTimes = [0, 0.5, 1]
        animation!.autoreverses = true
        animation!.repeatCount = Float.infinity
        animation!.calculationMode = kCAAnimationDiscrete
        layer!.add(animation!, forKey: "animateOpacity")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if bounds.size.equalTo(CGSize(width: 50, height: 50)) {
            bounds.size = CGSize(width: 50, height: 50)
        }
        NSColor.black.setFill()
        NSRectFill(bounds)
    }

    func stopAnimation() {
        layer?.removeAnimation(forKey: "animateOpacity")
        alphaValue = 1
        layer?.setNeedsDisplay()
    }

    func startAnimation() {
        layer?.add(animation!, forKey: "animateOpacity")
    }
}

class BufferView : NSView {
    var lines: [LineWrapper] = []
    var font: CTFont?
    var point = 0
    var pointView: PointView?

    override func draw(_ dirtyRect: NSRect) {
        Swift.print("BufferView draw()")
        let context = NSGraphicsContext.current()!.cgContext
        context.saveGState()
        for l in lines {
            let line = l.line;
            context.textPosition = CGPoint(x: l.x, y: 600 - l.y);
            CTLineDraw(line, context)
        }
        context.restoreGState();
        super.draw(dirtyRect)
    }

    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
}
