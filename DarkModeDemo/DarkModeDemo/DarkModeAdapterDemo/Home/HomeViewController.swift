//
//  SYJHomeViewController.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/6/28.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

private let collectLessionTableViewCellReusedID = "collectLessionTableViewCellReusedID"

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionLessionTableView: UITableView!
    
    var loginInfo: [String: Any]?
    var collectLessions: Array<[String: Any]>?

    override func viewDidLoad() {
        super.viewDidLoad()
         title = "收藏课程"
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        
        InfoManager.shared.updateToken(newToken:"")
        login()
        collectionLessionTableView.register(UINib.init(nibName: "LessionIntroductionCell", bundle: nil), forCellReuseIdentifier: collectLessionTableViewCellReusedID)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "刷新", style: .done, target: self, action: #selector(refreshCollectLesson))
    }
    
    @objc func refreshCollectLesson() {
        getCollectLessions()
    }
}

extension HomeViewController {
    
    /// 登录
    func login() -> Void {
//        var linkstr = "https://www.bjjnts.cn/api/mobile/user/center"
//        linkstr = linkstr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
//        let url = URL.init(string: linkstr)
//        var request = URLRequest.init(url: url!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
//        request.addValue("www.bjjnts.cn", forHTTPHeaderField: "Host")
//        request.addValue("https://servicewechat.com/wxf2bc5d182269cdf1/8/page-frame.html", forHTTPHeaderField: "Referer")
//        request.addValue("Bearer \(InfoManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
//        request.addValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.14(0x17000e25) NetType/4G Language/zh_CN", forHTTPHeaderField: "User-Agent")
//        let task = URLSession.shared.dataTask(with: request) { [weak self] ( data, urlRespone, error) in
//            guard let resData = data else {
//                return
//            }
//            guard case let res as [String: Any] = try? JSONSerialization.jsonObject(with: resData, options: .mutableContainers) else {
//                return;
//            }
//
//            guard let resCode = res["code"],
//                let data = res["data"],
//                let message = res["msg"] else {
//                    print("解析字段失败")
//                    return
//            }
//
//            print("请求响应码: \(resCode)")
//            print("返回message: \(message)")
//            self?.loginInfo = data as? [String : Any]
//            print("data: \(String(describing: self?.loginInfo))")
//
//            if resCode as! Int == 200 {
//                self?.getCollectLessions()
//            }
//
//        }
//        task.resume()
        
        // AF
        let url = "https://www.bjjnts.cn/api/mobile/user/center"
        var header = [String: String]()
        header.updateValue("www.bjjnts.cn", forKey: "Host")
        header.updateValue("https://servicewechat.com/wxf2bc5d182269cdf1/8/page-frame.html", forKey: "Referer")
        header.updateValue("Bearer \(InfoManager.shared.accessToken ?? "")", forKey: "Authorization")
        header.updateValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.14(0x17000e25) NetType/4G Language/zh_CN", forKey: "User-Agent")
        Alamofire.request(url, method: .get, headers: header).responseData { (response) in
            print(response)
        }
    }
    
    /// 收藏列表
    func getCollectLessions() -> Void {
        var linkstr = "https://www.bjjnts.cn/api/mobile/user/collects"
        linkstr = linkstr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL.init(string: linkstr)
        var request = URLRequest.init(url: url!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.addValue("www.bjjnts.cn", forHTTPHeaderField: "Host")
        request.addValue("https://servicewechat.com/wxf2bc5d182269cdf1/8/page-frame.html", forHTTPHeaderField: "Referer")
        request.addValue("Bearer \(InfoManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.14(0x17000e25) NetType/4G Language/zh_CN", forHTTPHeaderField: "User-Agent")
        let task = URLSession.shared.dataTask(with: request) { [weak self] ( data, urlRespone, error) in
            guard let resData = data else {
                return
            }
            guard case let res as [String: Any] = try? JSONSerialization.jsonObject(with: resData, options: .mutableContainers) else {
                return;
            }
            
            guard let resCode = res["code"],
                let data = res["data"],
                let message = res["msg"] else {
                    print("解析字段失败")
                    return
            }
            
            print("请求响应码: \(resCode)")
            print("返回message: \(message)")
            self?.collectLessions = data as? Array<[String : Any]>
            print("data: \(String(describing: self?.collectLessions))")
            OperationQueue.main.addOperation {
                self?.collectionLessionTableView.reloadData()
            }
        }
        task.resume()
    }
}


extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.collectLessions?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LessionIntroductionCell = tableView.dequeueReusableCell(withIdentifier: collectLessionTableViewCellReusedID, for: indexPath) as! LessionIntroductionCell
        let lession = self.collectLessions?[indexPath.row]
        cell.lessionInfo = lession
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let lession = self.collectLessions?[indexPath.row] else {
            return
        }
        let storyboard = UIStoryboard.init(name: "Lessions", bundle: nil)
//        let lessionsVC: LessionsController = storyboard.instantiateInitialViewController() as! LessionsController
        let lessionsVC: LessionsController = storyboard.instantiateViewController(withIdentifier: "Lessions") as! LessionsController
        lessionsVC.lessionInfo = lession;
        self.navigationController?.pushViewController(lessionsVC, animated: true)
    }
}
