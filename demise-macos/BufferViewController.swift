import Cocoa
import SnapKit
import SwiftSocket

func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
}

func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
    return value.withUnsafeBytes {
        $0.baseAddress!.load(as: T.self)
    }
}

class FlippedNSClipView : NSClipView {
    override var isFlipped: Bool {
        get {
            return true
        }
    }
}

class FlippedNSView : NSView {
    override var isFlipped: Bool {
        get {
            return true
        }
    }
}

class BufferViewController : NSViewController {
    var bufferView: BufferView!
    var scrollView: NSScrollView!

    override func viewDidLoad() {
        print("viewDidLoad()")

        scrollView = NSScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            make -> Void in
            make.edges.equalToSuperview()
        }
        scrollView.contentView = FlippedNSClipView()
        scrollView.hasVerticalScroller = true

        let contentView = NSView()
        scrollView.documentView = contentView
        contentView.snp.makeConstraints {
            make -> Void in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(600)
        }

        bufferView = BufferView()
        contentView.addSubview(bufferView)
        bufferView.snp.makeConstraints {
            make -> Void in
            make.edges.equalToSuperview()
        }

        bufferView.wantsLayer = true
        bufferView.layer!.backgroundColor = NSColor.blue.cgColor

        bufferView.lines.append(contentsOf: [
            LineWrapper(line: CTLineCreateWithAttributedString(
                NSAttributedString(string: "test string",
                                   attributes: [
                                    NSFontAttributeName: NSFont(name: "Source Code Pro", size: 11)!
                    ])), x: 100, y: 100)
            ])

        let client = TCPClient(address: "localhost", port: 8765)
        var result = client.connect(timeout: 1)
        if result.isFailure {
            print("Client connection error: \(result.error!)")
            return
        }
        let bytes = toByteArray(123 as Int32)
        print(bytes)
        result = client.send(data: bytes)
        if result.isFailure {
            print("Send data error: \(result.error!)")
            return
        }
    }
}
