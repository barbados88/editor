import UIKit

public struct EditorOptionItem: EditorOption {

    public var image: UIImage?
    public var activeImage: UIImage?
    public var title: String
    public var handler: ((EditorToolbar) -> Void)

    public init(image: UIImage?, title: String, action: @escaping ((EditorToolbar) -> Void)) {
        self.image = image
        self.title = title
        self.handler = action
    }

    public func action(_ toolbar: EditorToolbar) {
        handler(toolbar)
    }

}

public enum EditorDefaultOption: EditorOption {

    case clear
    case undo
    case redo
    case bold
    case italic
    case strike
    case underline
    case textColor
    case orderedList
    case unorderedList
    case image
    case link

    public static let recent: [EditorDefaultOption] = [.bold, .italic, .strike, .underline, .orderedList, .unorderedList]

    // MARK: RichEditorOption

    public var image: UIImage? {
        var name = ""
        switch self {
        case .clear: name = "clear"
        case .undo: name = "undo"
        case .redo: name = "redo"
        case .bold: name = "bold"
        case .italic: name = "italic"
        case .strike: name = "strike"
        case .underline: name = "underline"
        case .textColor: name = "text_color"
        case .orderedList: name = "ordered_list"
        case .unorderedList: name = "unordered_list"
        case .image: name = "insert_image"
        case .link: name = "insert_link"
        }

        let bundle = Bundle(for: EditorToolbar.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }

    public var activeImage: UIImage? {
        var name = ""
        switch self {
        case .clear: name = "clear_active"
        case .undo: name = "undo_active"
        case .redo: name = "redo_active"
        case .bold: name = "bold_active"
        case .italic: name = "italic_active"
        case .strike: name = "strike_active"
        case .underline: name = "underline_active"
        case .textColor: name = "text_color_active"
        case .orderedList: name = "ordered_list_active"
        case .unorderedList: name = "unordered_list_active"
        case .image: name = "insert_image"
        case .link: name = "insert_link"
        }

        let bundle = Bundle(for: EditorToolbar.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }

    public var title: String {
        switch self {
        case .clear: return NSLocalizedString("Clear", comment: "")
        case .undo: return NSLocalizedString("Undo", comment: "")
        case .redo: return NSLocalizedString("Redo", comment: "")
        case .bold: return NSLocalizedString("Bold", comment: "")
        case .italic: return NSLocalizedString("Italic", comment: "")
        case .strike: return NSLocalizedString("Strike", comment: "")
        case .underline: return NSLocalizedString("Underline", comment: "")
        case .textColor: return NSLocalizedString("Color", comment: "")
        case .orderedList: return NSLocalizedString("Ordered List", comment: "")
        case .unorderedList: return NSLocalizedString("Unordered List", comment: "")
        case .image: return NSLocalizedString("Image", comment: "")
        case .link: return NSLocalizedString("Link", comment: "")
        }
    }

    public func action(_ toolbar: EditorToolbar) {
        switch self {
        case .clear: toolbar.editor?.removeFormat()
        case .undo: toolbar.editor?.undo()
        case .redo: toolbar.editor?.redo()
        case .bold: toolbar.editor?.bold()
        case .italic: toolbar.editor?.italic()
        case .strike: toolbar.editor?.strikethrough()
        case .underline: toolbar.editor?.underline()
        case .textColor: toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar)
        case .orderedList: toolbar.editor?.orderedList()
        case .unorderedList: toolbar.editor?.unorderedList()
        case .image: toolbar.delegate?.richEditorToolbarInsertImage?(toolbar)
        case .link: toolbar.delegate?.richEditorToolbarInsertLink?(toolbar)
        }
    }

}
