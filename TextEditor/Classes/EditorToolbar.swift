import UIKit

open class EditorButton: UIBarButtonItem {
    open var actionHandler: (() -> Void)?
    open var isSelected : Bool = false
    open var option : EditorOption? = nil
    
    public convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
        self.init(image: image, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(EditorButton.buttonWasTapped)
        actionHandler = handler
    }
    
    public convenience init(title: String = "", handler: (() -> Void)? = nil) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(EditorButton.buttonWasTapped)
        actionHandler = handler
    }
    
    @objc func buttonWasTapped() {
        isSelected = !isSelected
        image = isSelected == true ? option?.activeImage : option?.image
        actionHandler?()
    }
}

open class EditorToolbar: UIView {

    open weak var delegate: EditorToolbarDelegate?
    open weak var actionDelegate: AttachDelegate? {
        didSet {
            updateDelegate()
        }
    }
    open weak var editor: EditorView?
    
    open var options: [EditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    private var toolbar: UIToolbar
    private var actionView: ActionView
    
    public override init(frame: CGRect) {
        toolbar = UIToolbar(frame: frame)
        toolbar.clipsToBounds = true
        actionView = ActionView.configure(with: frame.size)
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbar = UIToolbar()
        toolbar.clipsToBounds = true
        actionView = ActionView()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
        toolbar.autoresizingMask = .flexibleWidth
        toolbar.backgroundColor = .clear
        shouldOpen(open: false)
        addSubview(toolbar)
        addSubview(actionView)
        updateToolbar()
    }
    
    private func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        let width : CGFloat = toolbar.frame.size.width / CGFloat(options.count)
        for option in options {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }
            let button = option.image != nil ? EditorButton(image: option.image!, handler: handler) : EditorButton(title: option.title, handler: handler)
            button.option = option
            button.width = width
            buttons.append(button)
        }
        toolbar.items = buttons
        toolbar.frame.size.height = 44
    }
    
    private func updateDelegate () {
        actionView.delegate = actionDelegate
    }
    
    public func disable(typingAttribute : String) {
        var button : EditorButton? = nil
        for item in toolbar.items ?? [] {
            if item is EditorButton {
                let b : EditorButton = item as! EditorButton
                if b.option?.title != typingAttribute {continue}
                button = b
            }
        }
        button?.isSelected = false
        button?.image = button?.option?.image
    }
    
    public func shouldOpen(open : Bool) {
        var rect = toolbar.frame
        rect.origin.y = open == true ? 0 : 44
        toolbar.frame = rect
    }
    
    public func hideTools(hide : Bool) {
        UIView.animate(withDuration: 0.3) {
            self.toolbar.alpha = hide == true ? 0.0 : 1.0
            self.actionView.alpha = hide == true ? 0.0 : 1.0
        }
    }
    
}
