//
//  SpotlightViewController.swift
//  Spotlight
//
//  Created by Lekshmi Raveendranathapanicker on 2/5/18.
//  Copyright © 2018 Lekshmi Raveendranathapanicker. All rights reserved.
//

import Foundation
import UIKit

final class SpotlightViewController: UIViewController {

    var spotlightNodes: [SpotlightNode] = []
    weak var delegate: SpotlightDelegate?

    // MARK: - View Controller Life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpotlightView()
        setupInfoView()
        setupTapGestureRecognizer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nextSpotlight()
        timer = Timer.scheduledTimer(timeInterval: Spotlight.delay, target: self, selector: #selector(nextSpotlight), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        spotlightView.isHidden = true
        timer.invalidate()
    }

    let spotlightView = SpotlightView()
    var infoLabel: UILabel!
    var infoStackView: UIStackView!
    var infoStackTopConstraint: NSLayoutConstraint!
    var infoStackBottomConstraint: NSLayoutConstraint!
    fileprivate var timer = Timer()
    fileprivate var currentNodeIndex: Int = -1
}

// MARK: - User Actions

extension SpotlightViewController {

    @objc func buttonPressed(_ button: UIButton) {
        timer.invalidate()
        let title = button.titleLabel?.text ?? ""
        switch title {
        case ButtonTitles.next.rawValue:
            nextSpotlight()
        case ButtonTitles.back.rawValue:
            previousSpotlight()
        default:
            dismissSpotlight()
        }
    }

    @objc func viewTapped(_: UITapGestureRecognizer) {
        timer.invalidate()
        nextSpotlight()
    }

    @objc func nextSpotlight() {
        if currentNodeIndex == spotlightNodes.count - 1 {
            dismissSpotlight()
            return
        }
        currentNodeIndex += 1
        showSpotlight()
    }

    func previousSpotlight() {
        if currentNodeIndex == 0 {
            dismissSpotlight()
            return
        }
        currentNodeIndex -= 1
        showSpotlight()
    }

    func showSpotlight() {
        let node = spotlightNodes[currentNodeIndex]
        let targetRect: CGRect
        switch currentNodeIndex {
        case 0:
            targetRect = spotlightView.appear(node)
        case let index where index == spotlightNodes.count:
            targetRect = spotlightView.disappear(node)
        default:
            targetRect = spotlightView.move(node)
        }

        delegate?.didAdvance(to: currentNodeIndex + 1, of: spotlightNodes.count)

        infoLabel.text = node.text

        // Animate the info box around if intersects with spotlight
        view.layoutIfNeeded()
        UIView.animate(withDuration: Spotlight.animationDuration, animations: { [weak self] in
            guard let `self` = self else { return }
            if targetRect.intersects(self.infoStackView.frame) {
                if self.infoStackTopConstraint.priority == .defaultLow {
                    self.infoStackTopConstraint.priority = .defaultHigh
                    self.infoStackBottomConstraint.priority = .defaultLow
                } else {
                    self.infoStackTopConstraint.priority = .defaultLow
                    self.infoStackBottomConstraint.priority = .defaultHigh
                }
            }
            self.view.layoutIfNeeded()
        })
    }

    func dismissSpotlight() {
        dismiss(animated: true, completion: nil)
        delegate?.didDismiss()
    }

}
