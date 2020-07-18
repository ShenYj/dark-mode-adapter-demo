//
//  LessionVideoPlayerController.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/7/14.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import Foundation
import UIKit
import AVKit

private let LessionTableViewCellReusedID = "LessionTableViewCellReusedID"

class LessionsController: UIViewController {
    
    var requestTimeInterVal: Double {
        get {
            return InfoManager.shared.offsetSeconds
        }
    }
    
    @IBOutlet weak var lessionsTableView: UITableView!
    private lazy var thread: Thread = {
        let thread = Thread(target: self, selector: #selector(loop), object: nil)
        return thread
    }()
    
    private lazy var autoLearnTimer: DispatchSourceTimer? = {
        let timer: DispatchSourceTimer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: requestTimeInterVal)
        timer.setEventHandler {
            self.loop()
        }
        return timer
    }()
    
    // Timer Suspend 状态记录
    private var isSusspended: Bool = true
    
    // 统计当前已阅时长 单位s
    private var seconds: Int = 0
    // 当前章节总时长  单位s
    private var totaolS: Int = 0
    // course_id
    private var course_id: Int = 0
    // lesson_id
    private var lesson_id: Int = 0
    // 当前章节读完
    private var currCourseChapterFinished: Bool = false
    // 课程列表切片
    private var unLearnedLessons: Array<[String: Any]> = []
    
    public var lessionInfo: [String: Any]? {
        didSet {
            print("课程详情:")
            print("\(String(describing: lessionInfo))")
            getLessionList()
        }
    }
    
    private var lessionList: Array<[String: Any]>? {
        didSet {
            print("更新列表: \(lessionList?.count ?? 0)")
            
        }
    }
    
    deinit {
        print("析构函数")
        releaseTimer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "课程列表"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "开始", style: .done, target: self, action: #selector(start))
        self.lessionsTableView.register(UINib.init(nibName: "LessionsListCell", bundle: nil), forCellReuseIdentifier: LessionTableViewCellReusedID)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    @objc func start() {
        guard let courseChapterList = self.lessionList else { return }
        let unLearned = courseChapterList.filter { (element) -> Bool in
            if let hasLearn: Int = element["statistic_status"] as? Int, hasLearn == 1 {
                return false
            }
            return true
        }
        print("=====>: 总章节数: [\(courseChapterList.count)] 已学习: [\(courseChapterList.count - unLearned.count)] 未学习章节数: [\(unLearned.count)]")
        
        var unLearnedReversed = Array(unLearned.reversed())
        guard let currWillBeLearned = unLearnedReversed.popLast() else {
            print("   >>>>>   已经全部学习完  <<<<<")
            return
        }
        self.unLearnedLessons = unLearnedReversed
        
        setProperty(lesson: currWillBeLearned)
        startTimer()
    }
    
    func setProperty(lesson: [String: Any]) -> Void {
        print("点击课程:[\(lesson["lesson_name"] ?? "--")] ")
        guard let lesson_id = lesson["lesson_id"] as? Int,
            let totalDuration = lesson["duration"] as? Int,
            let course_id = self.lessionInfo?["course_id"] as? Int else {
                return
        }
        print(" lesson_id: \(lesson_id)  course_id: \(course_id)")
        print(" 参数提取- - 本节时长:  \(totalDuration)")
        
        self.seconds = 60
        self.totaolS = totalDuration
        self.lesson_id = lesson_id
        self.course_id = course_id
    }
    
    // 设置一个未学习课程
    func setCurrentLesson() -> Void {

        print("自动切换下一门课程")
        guard let currWillBeLearned = self.unLearnedLessons.popLast() else {
            print("   >>>>>   已经全部学习完  <<<<<")
            AudioTool.sharedManager.playSystemSound()
            getLessionList()
            stopTimer()
            return
        }
        print("剩余未学习课程: [\(self.unLearnedLessons.count)]")
        
        // 初始化当前这门课程的进度
        setProperty(lesson: currWillBeLearned)
    }
    
    
    @objc func loop() -> Void {
        // print("==========================线程: \(Thread.current)")
        guard self.totaolS != 0 else {
            print(" < 当前章节学习完成 > ")
            AudioTool.sharedManager.vibrate()
            setCurrentLesson()
            return
        }
        self.lerningRecord(courseID: course_id, lessionID: lesson_id, lessionDuration: seconds) { [weak self] (result) in
            let progress: Float = Float(self!.seconds) / Float(self!.totaolS)
            // \(String(describing: self?.seconds))s/\(String(describing: self?.totaolS)) 上报进度成功
            print("============>: [ 【\(Date.init(timeIntervalSinceNow: 0))】 当前观看进度: \(progress * 100) %]")
            
            guard var sec = self?.seconds, let total = self?.totaolS else {
                return
            }
            if sec >= total {
                print("最后一次上报结束")
                self?.course_id = 0
                self?.lesson_id = 0
                self?.seconds = 0
                self?.totaolS = 0
                return
            }
            
            sec += 60
            if sec > total {
                sec = total
            }
            self?.seconds = sec
        }
    }
}

// MARK: timer 接口
extension LessionsController {
    private func startTimer() {
        if isSusspended {
            self.autoLearnTimer?.resume()
        }
        isSusspended = false
    }

    private func stopTimer() {
        if isSusspended {
            return
        }
        isSusspended = true
        DispatchQueue.main.async {
            self.autoLearnTimer?.suspend()
        }
        print("停止定时器")
    }
    private func releaseTimer() {
        if isSusspended {
            self.autoLearnTimer?.resume()
        }
        self.autoLearnTimer?.cancel()
    }
}

extension LessionsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.lessionList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LessionsListCell = tableView.dequeueReusableCell(withIdentifier: LessionTableViewCellReusedID, for: indexPath) as! LessionsListCell
        let lession = self.lessionList?[indexPath.row]
        cell.lessionNameLabel.text = lession?["lesson_name"] as? String
        if let durationSec: Int = lession?["duration"] as? Int {
            let minutes = durationSec / 60
            cell.durationLabel.text = "\(minutes) 分钟"
        }
        if let hasLearn: Int = lession?["statistic_status"] as? Int {
            if hasLearn == 1 {
                cell.hasLearned = true
            }
            else {
                cell.hasLearned = false
            }
        }

        cell.serialNumberLabel.text = "\(indexPath.row + 1)"
        return cell
    }
}
extension LessionsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let lession = self.lessionList?[indexPath.row] else {
            return
        }
        print("点击课程:[\(lession["lesson_name"] ?? "--")] ")
        getVideoRealPath()
    }
}


extension LessionsController {
    
    /// 指定课程列表
    func getLessionList() -> Void {
        let course_id = self.lessionInfo?["course_id"] ?? 0
        var linkstr = "https://www.bjjnts.cn/api/mobile/courses/\((course_id))?course_id=\(course_id)"
        
        print("请求接口: \(linkstr)")
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
            print("data: \(data)")
 
            
            if let jsonData = data as? [String: Any],
                let list = jsonData["chapter_list"] as? Array<[String: Any]> {
                
                print(" \(list.count) 节课程")
                self?.lessionList = list
                
                DispatchQueue.main.async {
                    print("全部课程: \(String(describing: self?.lessionList))")
                    self?.lessionsTableView.reloadData()
                }
            }
        }
        task.resume()
    }
}


extension LessionsController {
    func lerningRecord(courseID: Int, lessionID: Int, lessionDuration: Int, callback: ((_ isSuccess: Bool) -> ())?) -> Void {
        var urlString = "https://www.bjjnts.cn/api/mobile/user/learning-record"
        // print("请求接口: \(urlString)")
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL.init(string: urlString)
        var request = URLRequest.init(url: url!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: requestTimeInterVal)
        request.httpMethod = "POST"
        request.addValue("www.bjjnts.cn", forHTTPHeaderField: "Host")
        request.addValue("https://servicewechat.com/wxf2bc5d182269cdf1/8/page-frame.html", forHTTPHeaderField: "Referer")
        request.addValue("Bearer \(InfoManager.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.14(0x17000e25) NetType/4G Language/zh_CN", forHTTPHeaderField: "User-Agent")
        
        var list: Array<String> = Array()
        list.append("course_id=\(courseID)")
        list.append("lesson_id=\(lessionID)")
        list.append("duration=\(lessionDuration)")
        list.append("learn_duration=\(lessionDuration)")
        let stringBody: String = list.joined(separator: "&")
        
        do {
            request.httpBody = stringBody.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { ( data, urlRespone, error) in
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
                
                // print("请求响应码: \(resCode) 返回message: \(message)")
                // print("data: \(data)")
                
                if (callback != nil) && message as! String == "添加成功" {
                    callback!(true)
                }
                
            }
            task.resume()
        } catch  {
            print("二进制处理失败")
        }
    }
}


extension LessionsController {
    func getVideoRealPath() -> Void {
        let videoPath = "https://www.bjjnts.cn/api/mobile/courses/url/\(course_id)/\(lesson_id)"
        print("视频地址: \(videoPath)")
        guard let url = URL(string: videoPath) else {
            return
        }
        var request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
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
            print("data: \(data)")
            
            if let jsonData = data as? [String: Any],
                let realPath = jsonData["url"] as? String {
                
                guard let realVideoURL = URL(string: realPath)  else {
                    return
                }
                print(" 播放地址: \(realPath)")
                DispatchQueue.main.async {
                    let avplayerController = AVPlayerViewController()
                    avplayerController.player = AVPlayer(url: realVideoURL)
                    self?.present(avplayerController, animated: true, completion: {
                        avplayerController.player?.play()
                    })
                }
            }
        }
        task.resume()
    }
}
