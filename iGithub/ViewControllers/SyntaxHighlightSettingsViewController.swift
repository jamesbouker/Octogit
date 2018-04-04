//
//  SyntaxHighlightSettingsViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/4/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class SyntaxHighlightSettingsViewController: UITableViewController {
    @IBOutlet var themeLabel: UILabel!
    @IBOutlet var lineNumbersSwitch: UISwitch!
    let webViewCell = WebViewCell()

    let userDefaults = UserDefaults.standard

    let disposeBag = DisposeBag()

    lazy var themes: [String] = {
        let path = Bundle.main.path(forResource: "themes", ofType: "plist")
        return NSArray(contentsOfFile: path!) as! [String]
    }()

    let sample: String = {
        let path = Bundle.main.path(forResource: "sample", ofType: "")
        return try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    }()

    var rendering: String {
        return Renderer.render(sample, language: "c", theme: themeLabel.text, showLineNumbers: lineNumbersSwitch.isOn)
    }

    lazy var pickerView: OptionPickerView = OptionPickerView(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        themeLabel.text = userDefaults.object(forKey: Constants.kTheme) as? String
        lineNumbersSwitch.isOn = userDefaults.bool(forKey: Constants.kLineNumbers)

        webViewCell.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 230)
        webViewCell.webView.isOpaque = false
        tableView.tableFooterView = webViewCell

        pickerView.selectedRows[0] = themes.index(of: themeLabel.text!) ?? 0

        lineNumbersSwitch.rx.value.asDriver()
            .drive(onNext: { [unowned self] _ in
                self.renderSample()
            })
            .addDisposableTo(disposeBag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        userDefaults.set(themeLabel.text, forKey: Constants.kTheme)
        userDefaults.set(lineNumbersSwitch.isOn, forKey: Constants.kLineNumbers)
        super.viewDidDisappear(animated)
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else {
            return
        }

        pickerView.show()
    }

    func renderSample() {
        webViewCell.webView.loadHTMLString(rendering, baseURL: Bundle.main.resourceURL)
    }
}

extension SyntaxHighlightSettingsViewController: OptionPickerViewDelegate {
    func doneButtonClicked(_ pickerView: OptionPickerView) {
        themeLabel.text = themes[pickerView.selectedRows[0]]

        renderSample()
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return themes.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return themes[row]
    }
}
