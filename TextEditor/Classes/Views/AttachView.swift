//
//  AttachView.swift
//  TextEditor
//
//  Created by Woxapp on 20.11.17.
//  Copyright © 2017 Woxapp. All rights reserved.
//

import UIKit

public struct AttachOptionItem: EditorAttach {

    public var image: UIImage?
    public var title: String?
    public var description: String?

    public init(image: UIImage?, title: String) {
        self.image = image
        self.title = title
    }

}

public enum AttachType: EditorAttach {

    case galleryPhoto
    case cameraPhoto
    case link
    case video

    public static let all: [AttachType] = [.galleryPhoto, .cameraPhoto, .link, .video]

    public var image: UIImage? {
        var name: String = ""
        switch self {
        case .galleryPhoto: name = "photo_pictogram"
        case .cameraPhoto: name = "camera_pictogram"
        case .link: name = "link_pictogram"
        case .video: name = "video_pictogram"
        }

        let bundle = Bundle(for: AttachView.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }

    public var title: String? {
        switch self {
        case .galleryPhoto: return NSLocalizedString("Фото", comment: "")
        case .cameraPhoto: return NSLocalizedString("Фото", comment: "")
        case .link: return NSLocalizedString("Ссылка", comment: "")
        case .video: return NSLocalizedString("Видео", comment: "")
        }
    }

    public var description: String? {
        switch self {
        case .galleryPhoto: return NSLocalizedString("Выбрать из галереи", comment: "")
        case .cameraPhoto: return NSLocalizedString("Сделать новое", comment: "")
        case .link: return nil
        case .video: return nil
        }
    }

}

open class AttachView: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: AttachDelegate?
    private var attachAction: UIAlertAction? = nil
    private var validURL: String? = nil

    open var options: [AttachType] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var applicationName: String? {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
    }

    private var rowHeight: CGFloat {
        return 44
    }

    private var headerHeight: CGFloat {
        return UIScreen.main.bounds.size.height - CGFloat(options.count) * rowHeight
    }

    static func configure(with size: CGSize) -> AttachView {
        let view = Bundle.main.loadNibNamed("AttachView", owner: nil, options: nil)?.first as? AttachView ?? AttachView()
        view.frame = CGRect(origin: CGPoint.zero, size: size)
        return view
    }

// MARK: - UITableView methods

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight))
        let white: UIView = UIView(frame: CGRect(x: 0, y: headerHeight - 22, width: tableView.frame.size.width, height: 22))
        white.backgroundColor = .white
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        headerView.addSubview(white)
        return headerView
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let option = options[indexPath.row]
        cell.imageView?.image = option.image
        cell.textLabel?.text = option.title
        cell.detailTextLabel?.text = option.description
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14.0)
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 10.0)
        cell.detailTextLabel?.textColor = .lightGray
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = options[indexPath.row]
        switch option {
        case .galleryPhoto: openGallery()
        case .cameraPhoto: openCamera()
        case .link: addLink()
        case .video: addVideo()
        }
    }

    private func openGallery() {
        delegate?.selectPhoto?()
    }

    private func openCamera() {
        delegate?.takePhoto?()
    }

    private func addLink() {
        addLink(youtube: false)
    }

    private func addVideo() {
        addLink(youtube: true)
    }

    private func addLink(youtube: Bool) {
        let alert = UIAlertController(title: applicationName, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Отмена", comment: ""), style: .cancel, handler: nil))
        attachAction = UIAlertAction(title: NSLocalizedString("Прикрепить", comment: ""), style: .default, handler: { _ in
            self.delegate?.insert(link: self.validURL ?? "")
        })
        attachAction?.isEnabled = false
        alert.addAction(attachAction!)
        alert.addTextField { (textfield: UITextField) in
            textfield.tag = youtube == true ? 0 : 1
            textfield.addTarget(self, action: #selector(self.textFieldTextDidChange(_:)), for: .editingChanged)
            textfield.placeholder = NSLocalizedString("Ссылка", comment: "")
        }
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }

    @objc private func textFieldTextDidChange(_ textField: UITextField) {
        validURL = textField.text
        attachAction?.isEnabled = textField.tag == 1 ? isValidLink(textField.text) : isValidYouTubeLink(textField.text)
    }

    @objc private func handleTap() {
        delegate?.attachViewShouldShow(show: false)
    }

    public func animateAppearance(appear: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = appear == true ? 1.0 : 0.0
        }
    }

    private func isValidLink(_ link: String?) -> Bool {
        if link == nil {
            return false
        }
        if let url = URL(string: link!) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    private func isValidYouTubeLink(_ link: String?) -> Bool {
        if link == nil {
            return false
        }
        let ranges: [NSRange]
        do {
            let regex = try NSRegularExpression(pattern: "^((?:https?:)?\\/\\/)?((?:www|m)\\.)?((?:youtube\\.com|youtu.be))(\\/(?:[\\w\\-]+\\?v=|embed\\/|v\\/)?)([\\w\\-]+)(\\S+)?$", options: .caseInsensitive)
            ranges = regex.matches(in: link!, options: [], range: NSMakeRange(0, link!.count)).map {$0.range}
        } catch {
            ranges = []
        }
        return ranges.count > 0
    }

}
