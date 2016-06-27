# GYPageViewController
A page view controller instead of UIPageViewController. It manages the child controllers' life cycles as same as UIPageViewController.<br>
[Solve UIPageViewController bug which child controller is navigated to a wrong index](http://stackoverflow.com/questions/14220289/removing-a-view-controller-from-uipageviewcontroller/16308151)<br>

- GYPageViewController can manages the child controllers and support navigation with invoking method and user interaction.
- GYTabPageViewController adds a segmented control bar to the page view for the user to change index.

## Example
GYPageViewController:
            let vc = GYPageViewController(pageControllers: pageControllers)
            vc.showPageAtIndex(2, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)

GYTabPageViewController:
            let vc = GYTabPageViewController(pageTitles: titlesArray, pageControllers: pageControllers)
            vc.showPageAtIndex(2, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)

## ScreenShot

## Requirements

iOS >= 7

## Installation
Copy codes now, will add to git specs soon.

## Contact
Email:fightrain@126.com GaoYu
