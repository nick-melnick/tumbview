//
//  SplashScreenViewController.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit
import OAuthSwift
import RxSwift
import RxCocoa
import NSObject_Rx

class SplashScreenViewController: UIViewController {

    var coodrinator: SplashScreenCoordinator!
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var signInBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RxSetup()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return _viewWillDisappear.asObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func RxSetup() {
        signInBtn.rx.tap.asObservable()
            .takeUntil(viewWillDisappear)
            .flatMapLatest(authorize)
            .subscribe(
                onNext:{ [weak self] (credentials) in
                    self?.authorizationResult(credentials)
                }
            )
            .addDisposableTo(disposeBag)
        
        Observable<Int>.interval(5, scheduler: MainScheduler.asyncInstance)
            .startWith(0)
            .takeUntil(viewWillDisappear)
            .subscribe(onNext: { [weak self] _ in
                self?.setNewBackground()
            })
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func authorize() -> Observable<OAuthSwiftCredential> {
        let tumblrAuth = TumblrAuth(consumerKey: "iC4AkU75AYY4ubklqbcs0x7dXTrAZfhMRXISrLH8eEvT46QAPk",
                                    consumerSecret: "pkzJuYyLRlVoHsrIY1vj9LLnp5lS9NM7i0KtcNFvmIb2O02d3I",
                                    callbackUrl: URL(string:"https://tumblr.com")!)
        return TumblrConnect.with(self, providerOAuth1: tumblrAuth)
    }
    
    // MARK: - Navigation
    
    fileprivate func authorizationResult(_ result: OAuthSwiftCredential) {
        print(result)
        coodrinator.successfulAuthorization()
    }
    
    // MARK: - Customization
    
    func setNewBackground() {
        let list = [#imageLiteral(resourceName: "bg1"), #imageLiteral(resourceName: "bg2"), #imageLiteral(resourceName: "bg3"), #imageLiteral(resourceName: "bg4")]
        let image = list[Int(arc4random_uniform(UInt32(list.count)))]
        UIView.transition(with: backgroundImageView, duration: 1, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.backgroundImageView.image = image
        }, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
