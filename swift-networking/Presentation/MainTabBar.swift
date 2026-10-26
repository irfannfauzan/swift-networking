//
//  MainTabBar.swift
//  swift-networking
//
//  Created by Vokal-Ican on 25/10/26.
//

import UIKit

class MainTabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupUITabBar()
    }
    
    private func setupUITabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemIndigo
    }
    
    private func setupNavbar() {
        let github = makeNavbar(
            root: GithubViewController(),
            title: "Github",
            icon: "house",
            selectedIcon: "house.fill"
        )

        let picsum = makeNavbar(
            root: PicsumViewController(),
            title: "Picsum",
            icon: "person",
            selectedIcon: "person.fill"
        )
        
        let download = makeNavbar(
            root: DownloadViewController(),
            title: "Download",
            icon: "arrow.down.circle",
            selectedIcon: "arrow.down.circle.fill"
        )

        viewControllers = [github, picsum, download]

    }
    
    private func makeNavbar(root: UIViewController, title: String, icon: String, selectedIcon: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: UIImage(systemName: selectedIcon))
        root.title = title
        return nav
    }
}
