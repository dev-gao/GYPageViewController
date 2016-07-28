# GYPageViewController
A page view controller instead of UIPageViewController. It manages the child controllers' life cycles as same as UIPageViewController.<br>
[Solve UIPageViewController bug which child controller is navigated to a wrong index](http://stackoverflow.com/questions/14220289/removing-a-view-controller-from-uipageviewcontroller/16308151)<br>

一个简单的UIPageViewController替代方案，主要目的是解决UIPageViewController的[bug]及其不完善解决方案导致的线上偶现崩溃顽疾(http://stackoverflow.com/questions/14220289/removing-a-view-controller-from-uipageviewcontroller/16308151)。
能够完全模拟UIPageViewController对child controllers的生命周期管理，区分开will、did的调用时机。并且可以在快速连续切换时也保证生命周期的正常调用（UIPageViewController有bug，快速连续切换生命周期顺序错乱）

Support cache function to maintain child controllers usually used in order to avoid adding/removing child controllers frequently and make a lower CPU resource occupation. Cache limit can be set freely.
支持缓存方案，避免没必要调用dataSource方法；保证内存占用量可控。即降低页面切换add/remove child controllers带来的性能损耗。

Support animation between two pages which are nonadjacent like UIPageViewController. Also do some work about frequent changing and animation interrupting. Most third party page view controller do not support this function.
支持非相邻页面间的非交互切换动画，并且处理了动画过程中连续操作出现的动画打断等问题。一般的第三方框架都规避了这个实现。

Support fast continous interactive or non-interactive page changing with perfect life cycle management and cache cleaning. UIPageViewController can not do well at this point.
快速连续交互、非交互切换时，UIPageViewController存在页面闪白、生命周期管理错乱、内存波动等问题。本方案针对这些都做了相应优化和解决。

- GYPageViewController can manages the child controllers and support navigation with invoking method and user interaction.
- GYTabPageViewController adds a segmented control bar to the page view for the user to change index.

## ScreenShot

![img](https://github.com/dev-gao/GYPageViewController/blob/master/Example/GYTabPageViewController-ScreenShot.png)

## Example
```objc
GYPageViewController:
            let vc = GYPageViewController(nibName: nil, bundle: nil)
            vc.showPageAtIndex(2, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)

GYTabPageViewController:
            let vc = GYTabPageViewController(pageTitles: titlesArray)
            vc.showPageAtIndex(2, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
```

## Requirements

iOS >= 7

## Installation
Copy codes now, will add to git specs soon.

## Contact
Email:fightrain@126.com GaoYu
