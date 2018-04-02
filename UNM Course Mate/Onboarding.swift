import Foundation
import UIKit

class Onboarding: UIPageViewController, UIPageViewControllerDataSource {
    
    let onboardingViews = [Onboarding1(), Onboarding2(), Onboarding3()]
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        
        dataSource = self
        setViewControllers(
            [onboardingViews[0]],
            direction: .forward,
            animated: true,
            completion: nil
        )
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.view.bringSubview(toFront: subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return onboardingViews.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return onboardingViews.index(of: viewControllers![0])!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = onboardingViews.index(of: viewController)!
        if index > 0 {
            return onboardingViews[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = onboardingViews.index(of: viewController)!
        if index < onboardingViews.count - 1 {
            return onboardingViews[index + 1]
        }
        return nil
    }
}
