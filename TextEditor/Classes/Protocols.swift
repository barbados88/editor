import UIKit

public protocol EditorAttach {

    var image: UIImage? { get }
    var title: String? { get }
    var description: String? { get }

}

public protocol EditorOption {

    var image: UIImage? { get }
    var activeImage: UIImage? { get }
    var title: String { get }
    func action(_ editor: EditorToolbar)
}

@objc public protocol EditorToolbarDelegate: class {

    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: EditorToolbar)
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: EditorToolbar)
    @objc optional func richEditorToolbarInsertImage(_ toolbar: EditorToolbar)
    @objc optional func richEditorToolbarInsertLink(_ toolbar: EditorToolbar)
}

@objc public protocol EditorDelegate: class {

    @objc optional func richEditor(_ editor: EditorView, heightDidChange height: Int)
    @objc optional func richEditor(_ editor: EditorView, contentDidChange content: String)
    @objc optional func richEditorTookFocus(_ editor: EditorView)
    @objc optional func richEditorLostFocus(_ editor: EditorView)
    @objc optional func richEditorDidLoad(_ editor: EditorView)
    @objc optional func richEditor(_ editor: EditorView, shouldInteractWith url: URL) -> Bool
    @objc optional func richEditor(_ editor: EditorView, handle action: String)
}

@objc public protocol AttachDelegate: class {

    func attachViewShouldShow(show: Bool)
    func insert(link: String)
    @objc optional func selectPhoto()
    @objc optional func takePhoto()

}

class Protocols: NSObject {

}
