import UIKit

open class EditorView: UIView, UIScrollViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate {

    open weak var delegate: EditorDelegate?
    open private(set) var webView: UIWebView

    open override var inputAccessoryView: UIView? {
        get {
            return webView.cjw_inputAccessoryView
        }
        set {
            webView.cjw_inputAccessoryView = newValue
        }
    }

    open var isScrollEnabled: Bool = true {
        didSet {
            webView.scrollView.isScrollEnabled = isScrollEnabled
        }
    }

    open var isEditingEnabled: Bool {
        get {
            return isContentEditable
        }
        set {
            isContentEditable = newValue
        }
    }

    open private(set) var contentHTML: String = "" {
        didSet {
            delegate?.richEditor?(self, contentDidChange: contentHTML)
        }
    }

    open private(set) var editorHeight: Int = 0 {
        didSet {
            delegate?.richEditor?(self, heightDidChange: editorHeight)
        }
    }

    private var innerLineHeight: Int = 28

    open private(set) var lineHeight: Int {
        get {
            if isEditorLoaded, let lineHeight = Int(runJS("RE.getLineHeight();")) {
                return lineHeight
            } else {
                return innerLineHeight
            }
        }
        set {
            innerLineHeight = newValue
            runJS("RE.setLineHeight('\(innerLineHeight)px');")
        }
    }


    private var isEditorLoaded = false
    private var editingEnabledVar = true
    private let tapRecognizer = UITapGestureRecognizer()
    private var placeholderText: String = "Введите текст..."

    private var clientHeight: Int {
        let heightString = runJS("document.getElementById('editor').clientHeight;")
        return Int(heightString) ?? 0
    }

    // MARK: Initialization

    public override init(frame: CGRect) {
        webView = UIWebView()
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        webView = UIWebView()
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .red
        webView.frame = bounds
        webView.delegate = self
        webView.scrollView.contentInset = UIEdgeInsetsMake(20, 20, 0, 20)
        webView.keyboardDisplayRequiresUserAction = false
        webView.scalesPageToFit = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.dataDetectorTypes = UIDataDetectorTypes()
        webView.backgroundColor = .white
        webView.scrollView.isScrollEnabled = isScrollEnabled
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        webView.scrollView.clipsToBounds = false
        webView.cjw_inputAccessoryView = nil
        self.addSubview(webView)
        if let filePath = Bundle(for: EditorView.self).path(forResource: "rich_editor", ofType: "html") {
            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
        tapRecognizer.addTarget(self, action: #selector(viewWasTapped))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }

    public var html: String {
        get {
            return runJS("RE.getHtml();")
        }
        set {
            contentHTML = newValue
            if isEditorLoaded {
                runJS("RE.setHtml('\(newValue.escaped)');")
                updateHeight()
            }
        }
    }

    public var text: String {
        return runJS("RE.getText()")
    }

    open var placeholder: String {
        get {
            return placeholderText
        }
        set {
            placeholderText = newValue
            runJS("RE.setPlaceholderText('\(newValue.escaped)');")
        }
    }

    public var selectedHref: String? {
        if !hasRangeSelection {
            return nil
        }
        let href = runJS("RE.getSelectedHref();")
        if href == "" {
            return nil
        } else {
            return href
        }
    }

    public var hasRangeSelection: Bool {
        return runJS("RE.rangeSelectionExists();") == "true" ? true : false
    }

    public var hasRangeOrCaretSelection: Bool {
        return runJS("RE.rangeOrCaretSelectionExists();") == "true" ? true : false
    }

    // MARK: Methods

    public func removeFormat() {
        runJS("RE.removeFormat();")
    }

    public func setFontSize(_ size: Int) {
        runJS("RE.setFontSize('\(size)px');")
    }

    public func setEditorBackgroundColor(_ color: UIColor) {
        runJS("RE.setBackgroundColor('\(color.hex)');")
    }

    public func undo() {
        runJS("RE.undo();")
    }

    public func redo() {
        runJS("RE.redo();")
    }

    public func bold() {
        runJS("RE.setBold();")
    }

    public func italic() {
        runJS("RE.setItalic();")
    }

    public func strikethrough() {
        disable(typingAttribute: "Underline")
        runJS("RE.setStrikeThrough();")
    }

    public func underline() {
        disable(typingAttribute: "Strike")
        runJS("RE.setUnderline();")
    }

    public func setTextColor(_ color: UIColor) {
        runJS("RE.prepareInsert();")
        runJS("RE.setTextColor('\(color.hex)');")
    }

    public func orderedList() {
        disable(typingAttribute: "Unordered List")
        runJS("RE.setOrderedList();")
    }

    public func unorderedList() {
        disable(typingAttribute: "Ordered List")
        runJS("RE.setUnorderedList();")
    }

    public func insertImage(_ url: String, alt: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertImage('\(url.escaped)', '\(alt.escaped)');")
    }

    public func insertLink(_ href: String, title: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertLink('\(href.escaped)', '\(title.escaped)');")
    }

    public func focus() {
        runJS("RE.focus();")
    }

    public func focus(at: CGPoint) {
        runJS("RE.focusAtPoint(\(at.x), \(at.y));")
    }

    public func blur() {
        runJS("RE.blurFocus();")
    }

    @discardableResult
    public func runJS(_ js: String) -> String {
        let string = webView.stringByEvaluatingJavaScript(from: js) ?? ""
        return string
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isScrollEnabled {
            scrollView.bounds = webView.bounds
        }
    }


    // MARK: UIWebViewDelegate

    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let callbackPrefix = "re-callback://"
        if request.url?.absoluteString.hasPrefix(callbackPrefix) == true {
            let commands = runJS("RE.getCommandQueue();")
            if let data = commands.data(using: .utf8) {
                let jsonCommands: [String]
                do {
                    jsonCommands = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
                } catch {
                    jsonCommands = []
                    NSLog("EditorView: Failed to parse JSON Commands")
                }
                jsonCommands.forEach(performCommand)
            }
            return false
        }

        if navigationType == .linkClicked {
            if let
                url = request.url,
                let shouldInteract = delegate?.richEditor?(self, shouldInteractWith: url) {
                return shouldInteract
            }
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    private var isContentEditable: Bool {
        get {
            if isEditorLoaded {
                let value = runJS("RE.editor.isContentEditable")
                editingEnabledVar = Bool(value) ?? false
                return editingEnabledVar
            }
            return editingEnabledVar
        }
        set {
            editingEnabledVar = newValue
            if isEditorLoaded {
                let value = newValue ? "true" : "false"
                runJS("RE.editor.contentEditable = \(value);")
            }
        }
    }

    private var relativeCaretYPosition: Int {
        let string = runJS("RE.getRelativeCaretYPosition();")
        return Int(string) ?? 0
    }

    private func updateHeight() {
        let heightString = runJS("document.getElementById('editor').clientHeight;")
        let height = Int(heightString) ?? 0
        if editorHeight != height {
            editorHeight = height
        }
    }

    private func scrollCaretToVisible() {
        let scrollView = self.webView.scrollView
        let contentHeight = clientHeight > 0 ? CGFloat(clientHeight) : scrollView.frame.height
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
        let lineHeight = CGFloat(self.lineHeight)
        let cursorHeight = lineHeight - 4
        let visiblePosition = CGFloat(relativeCaretYPosition)
        var offset: CGPoint?
        if visiblePosition + cursorHeight > scrollView.bounds.size.height {
            offset = CGPoint(x: 0, y: (visiblePosition + lineHeight) - scrollView.bounds.height + scrollView.contentOffset.y)
        } else if visiblePosition < 0 {
            var amount = scrollView.contentOffset.y + visiblePosition
            amount = amount < 0 ? 0 : amount
            offset = CGPoint(x: scrollView.contentOffset.x, y: amount)
        }
        if let offset = offset {
            scrollView.setContentOffset(offset, animated: true)
        }
    }

    private func performCommand(_ method: String) {
        if method.hasPrefix("ready") {
            if !isEditorLoaded {
                isEditorLoaded = true
                html = contentHTML
                isContentEditable = editingEnabledVar
                placeholder = placeholderText
                lineHeight = innerLineHeight
                delegate?.richEditorDidLoad?(self)
            }
            updateHeight()
        }
        else if method.hasPrefix("input") {
            scrollCaretToVisible()
            let content = runJS("RE.getHtml()")
            contentHTML = content
            updateHeight()
        }
        else if method.hasPrefix("updateHeight") {
            updateHeight()
        }
        else if method.hasPrefix("focus") {
            hideTools(hide: false)
            delegate?.richEditorTookFocus?(self)
        }
        else if method.hasPrefix("blur") {
            hideTools(hide: true)
            delegate?.richEditorLostFocus?(self)
        }
        else if method.hasPrefix("action/") {
            let content = runJS("RE.getHtml()")
            contentHTML = content
            let actionPrefix = "action/"
            let range = method.range(of: actionPrefix)!
            let action = method.replacingCharacters(in: range, with: "")
            delegate?.richEditor?(self, handle: action)
        }
    }

    @objc private func viewWasTapped() {
        if !webView.containsFirstResponder {
            let point = tapRecognizer.location(in: webView)
            focus(at: point)
        }
    }

    private func hideTools(hide: Bool) {
        if inputAccessoryView is EditorToolbar {
            let editorToolbar = inputAccessoryView as? EditorToolbar
            editorToolbar?.hideTools(hide: hide)
        }
    }

    private func disable(typingAttribute: String) {
        if inputAccessoryView is EditorToolbar {
            let editorToolbar = inputAccessoryView as? EditorToolbar
            editorToolbar?.disable(typingAttribute: typingAttribute)
        }
    }

}
