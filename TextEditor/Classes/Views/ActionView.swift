//
//  ActionView.swift
//  TextEditor
//
//  Created by Woxapp on 20.11.17.
//  Copyright © 2017 Woxapp. All rights reserved.
//

import UIKit

class ActionView: UIView {

    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var attributesButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!

    weak var delegate: AttachDelegate? = nil

    static func configure(with size: CGSize) -> ActionView {
        let view = Bundle.main.loadNibNamed("ActionView", owner: nil, options: nil)?.first as? ActionView ?? ActionView()
        view.frame = CGRect(x: 0, y: 44, width: size.width, height: 44)
        return view
    }

    @IBAction func redo(_ sender: UIButton?) {
        (self.superview as? EditorToolbar)?.editor?.redo()
    }

    @IBAction func undo(_ sender: UIButton?) {
        (self.superview as? EditorToolbar)?.editor?.undo()
    }

    @IBAction func hideKeyboard(_ sender: UIButton?) {
        (self.superview as? EditorToolbar)?.editor?.blur()
    }

    @IBAction func showAttributes(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UIView.animate(withDuration: 0.3) {
            (self.superview as? EditorToolbar)?.shouldOpen(open: sender.isSelected)
        }
    }

    @IBAction func attachFiles(_ sender: UIButton) {
        hideKeyboard(nil)
        delegate?.attachViewShouldShow(show: true)
    }

}
