//
//  SidebarContainerViewController.swift
//
// Copyright (c) 2015 apploft GmbH (http://www.apploft.de)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public class AdaptiveSidebarViewController : UIViewController {
    
    //MARK: Public

    public var mainViewController : UIViewController?
    public var sideViewController : UIViewController?
    public var sideViewWidth : CGFloat = 320 {
        didSet {
            sideViewWidthConstraint.constant = sideViewWidth
        }
    }
    public var bottomViewHeight : CGFloat = 320 {
        didSet {
            bottomViewBottomConstraint.constant = bottomViewHeight
        }
    }
    
    public func showSideView(animated: Bool) {
        updateSideView(visible: true, animated: animated)
    }
    
    public func hideSideView(animated: Bool) {
        updateSideView(visible: false, animated: animated)
    }
    
    public var sideViewVisible: Bool {
      get {
        return sideViewRightConstraint.constant == 0 || bottomViewBottomConstraint.constant == 0
      }
    }
    
    public var resizeMainViewWhenSideViewVisible: Bool = false
    
    //MARK: Private
    
    private var mainViewContainer: UIView!
    private var sideViewContainer: UIView!
    private var bottomViewContainer: UIView!
    private var currentSideViewContainer : UIView!
    
    private var sideViewWidthConstraint : NSLayoutConstraint!
    private var sideViewRightConstraint : NSLayoutConstraint!
    private var mainRightConstraint : NSLayoutConstraint!
    
    private var bottomViewHeightConstraint : NSLayoutConstraint!
    private var bottomViewBottomConstraint : NSLayoutConstraint!
    private var mainBottomConstraint : NSLayoutConstraint!
    
    private var toggleAnimationInProgress = false
    
    private func updateSideView(visible: Bool, animated: Bool) {
        guard toggleAnimationInProgress == false else { return }
                
        if isRegularSize() {
            let constant = visible ? 0 : sideViewWidth
            sideViewRightConstraint.constant = constant
            bottomViewBottomConstraint.constant = bottomViewHeight
            
            if (resizeMainViewWhenSideViewVisible) {
                mainBottomConstraint.constant = 0
                mainRightConstraint.constant = constant - sideViewWidth
            }
        } else {
            let constant = visible ? 0 : bottomViewHeight
            bottomViewBottomConstraint.constant = constant
            sideViewRightConstraint.constant = bottomViewHeight
            
            if (resizeMainViewWhenSideViewVisible) {
                mainRightConstraint.constant = 0
                mainBottomConstraint.constant = constant - bottomViewHeight
            }
        }
        
        view.setNeedsUpdateConstraints()
        
        if animated {
            toggleAnimationInProgress = true
            
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.view.layoutIfNeeded()
                }, completion: { [weak self] finished in
                    self?.toggleAnimationInProgress = false
                })
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupContainerViews()
        
        if let mainViewController = mainViewController {
            addViewControllerToContainer(mainViewController, container: mainViewContainer)
        }
        
        if let sideViewController = sideViewController {
            if isRegularSize() {
                addViewControllerToContainer(sideViewController, container: sideViewContainer)
            } else {
                addViewControllerToContainer(sideViewController, container: bottomViewContainer)
            }
        }
    }
    
    private func addViewControllerToContainer(_ viewController: UIViewController, container: UIView) {
        addChild(viewController)
        let subview = viewController.view!
        subview.translatesAutoresizingMaskIntoConstraints = false
        viewController.beginAppearanceTransition(true, animated: false)
        container.addSubview(subview)
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|", options: [], metrics: nil, views: ["subview" : subview])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|", options: [], metrics: nil, views: ["subview" : subview])
        container.addConstraints(hConstraints)
        container.addConstraints(vConstraints)
        
        viewController.endAppearanceTransition()
        viewController.didMove(toParent: self)
        
        if viewController == sideViewController {
            self.currentSideViewContainer = container
        }
    }

    private func removeViewControllerFromContainer(viewController: UIViewController, container: UIView) {
        viewController.willMove(toParent: nil)
        viewController.beginAppearanceTransition(false, animated: false)
        viewController.view.removeConstraints()
        viewController.view.removeFromSuperview()
        viewController.view.translatesAutoresizingMaskIntoConstraints = true
        viewController.endAppearanceTransition()
        viewController.removeFromParent()
    }
    
    private func setupContainerViews() {
        mainViewContainer = UIView()
        mainViewContainer.translatesAutoresizingMaskIntoConstraints = false
        mainViewContainer.backgroundColor = UIColor.blue
        view.addSubview(mainViewContainer)
        let mainLeftConstraint = NSLayoutConstraint(item: mainViewContainer!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
        mainRightConstraint = NSLayoutConstraint(item: mainViewContainer!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        mainBottomConstraint = NSLayoutConstraint(item: mainViewContainer!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let mainTopConstraint = NSLayoutConstraint(item: mainViewContainer!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        view.addConstraint(mainLeftConstraint)
        view.addConstraint(mainRightConstraint)
        view.addConstraint(mainBottomConstraint)
        view.addConstraint(mainTopConstraint)
        
        sideViewContainer = UIView()
        sideViewContainer.translatesAutoresizingMaskIntoConstraints = false
        sideViewContainer.backgroundColor = UIColor.red
        view.addSubview(sideViewContainer)
        
        sideViewWidthConstraint = NSLayoutConstraint(item: sideViewContainer!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: sideViewWidth)
        sideViewRightConstraint = NSLayoutConstraint(item: sideViewContainer!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: sideViewWidth)
        let sVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[sideView]|", options: [], metrics: nil, views: ["sideView" : sideViewContainer!])
        view.addConstraint(sideViewWidthConstraint)
        view.addConstraint(sideViewRightConstraint)
        view.addConstraints(sVConstraints)
        
        bottomViewContainer = UIView()
        bottomViewContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomViewContainer.backgroundColor = UIColor.red
        view.addSubview(bottomViewContainer)
        
        bottomViewHeightConstraint = NSLayoutConstraint(item: bottomViewContainer!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: bottomViewHeight)
        bottomViewBottomConstraint = NSLayoutConstraint(item: bottomViewContainer!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: bottomViewHeight)
        let sHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomView]|", options: [], metrics: nil, views: ["bottomView" : bottomViewContainer!])
        view.addConstraint(bottomViewHeightConstraint)
        view.addConstraint(bottomViewBottomConstraint)
        view.addConstraints(sHConstraints)
    }
    
    
    private func isRegularSize(traitCollection : UITraitCollection = UIScreen.main.traitCollection) -> Bool {
        return traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
    }
    
    private func hideViewController(_ viewController: UIViewController, animated: Bool) {
        if let navigationController = navigationController {
            if (navigationController.topViewController === sideViewController) {
                navigationController.popViewController(animated: animated)
            }
        } else {
            viewController.dismiss(animated: animated, completion: nil)
        }
    }
    
    override public func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        if let sideViewController = sideViewController {
            hideSideView(animated: false)
            if isRegularSize(traitCollection: newCollection) {
                removeViewControllerFromContainer(viewController: sideViewController, container: currentSideViewContainer)
                addViewControllerToContainer(sideViewController, container: sideViewContainer)
            } else {
                removeViewControllerFromContainer(viewController: sideViewController, container: currentSideViewContainer)
                addViewControllerToContainer(sideViewController, container: bottomViewContainer)
            }
        }
    }
}

private extension UIView {
    func removeConstraints() {
        var list = [NSLayoutConstraint]()
        if let constraints = superview?.constraints {
            for c in constraints {
                if c.firstItem as? UIView == self || c.secondItem as? UIView == self {
                    list.append(c)
                }
            }
            self.superview!.removeConstraints(list)
        }
    }
}
