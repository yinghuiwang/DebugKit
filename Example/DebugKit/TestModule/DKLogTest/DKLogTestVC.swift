//
//  DKLogTestVC.swift
//  DebugKit_Example
//
//  Created by 王英辉 on 2021/9/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DebugKit

class DKLogTestVC: UIViewController {

    var timer: Timer?
    var randomStr: [String] = "1234567890qwertyuiopasdfghjklzxcvbnm".enumerated().map { String($1) }
    var getKeyword: String {
        var keyword = ""
        let count = Int(arc4random()) % 20
        let randomStrCount = randomStr.count
        for _ in 0...count {
            let index = Int(arc4random()) % randomStrCount
            keyword += randomStr[index]
        }
        return keyword
    }
    deinit {
        timer?.invalidate()
        timer = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addAction(_ sender: Any) {
        stopAddLog(sender)
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) {[weak self] _ in
            self?.addOneLog()
        }
        timer?.fire()
    }
    
    @IBAction func add0_05secondAddOneLog(_ sender: Any) {
        stopAddLog(sender)
        timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) {[weak self] _ in
            self?.addOneLog()
        }
        timer?.fire()
    }
    
    @IBAction func add0_01secondAddOneLog(_ sender: Any) {
        stopAddLog(sender)
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {[weak self] _ in
            self?.addOneLog()
        }
        timer?.fire()
    }
    
    @IBAction func add1SecondAddOneLog(_ sender: Any) {
        stopAddLog(sender)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] _ in
            self?.addOneLog()
        }
        timer?.fire()
    }
    
    @IBAction func stopAddLog(_ sender: Any) {
        timer?.invalidate()
        self.timer = nil
    }
    
    @IBAction func addOneLog(_ sender: Any) {
        addOneLog()
    }
    
    func addOneLog() {
        let level = Int(arc4random() % 4)
        var keyword = ""
        for index in 0...level {
            if index == 0 {
                if level > 1 {
                    keyword +=  "00\(Int(arc4random() % 10))"
                } else {
                    keyword += getKeyword
                }
            } else {
                keyword += "/"
                keyword += getKeyword
            }
        }
                
        let message = """
            {
                "result": {
                    "result": [
                        {
                            "userid": "298967041",
                            "nickname": "诠就e冷月💆🏿",
                            "headphoto": "http://aliimg.changba.com/cache/photo/933556994_100_100.jpg",
                            "gender": "1",
                            "role": "",
                            "isanchor": 0,
                            "ismember": -1,
                            "memberlevel": "1",
                            "userlevel": {
                                "richLevel": 6,
                                "richLevelName": "大富商",
                                "richRank": "10万名以外",
                                "nextRichLevel": 0,
                                "starLevel": 8,
                                "starLevelName": "当红偶像3级",
                                "starRank": "10万名以外",
                                "nextStarLevel": 0,
                                "userid": "298967041",
                                "pop": -1,
                                "weekPop": -1,
                                "monthPop": -1,
                                "cost": -1,
                                "weekCost": -1,
                                "monthCost": -1,
                                "starLevel60": 33,
                                "starLevelName60": "当红偶像3级",
                                "nextStarLevel60": 0,
                                "richLevel50": 16,
                                "richLevelName50": "大富绅",
                                "nextRichLevel50": 0
                            },
                            "usercost": 0,
                            "titlephotoex": "",
                            "viptitle": "",
                            "vip": 0,
                            "personaltag": "",
                            "noble_level_id": 0,
                            "micid": "2000018298967041",
                            "choruslyrictype": 0,
                            "waittype": 0,
                            "song": {
                                "songid": "5222922",
                                "songname": "最后的人",
                                "lyric": "http://upbanzou.sslmp3img.changba.com/vod1/zrc/357af754b7008dbf9095556d6c550f74.zrce",
                                "duration": "248",
                                "escaped": 0,
                                "isChorus": 1
                            },
                            "ktv": {
                                "is_vod": 0
                            },
                            "chorusnum": 0,
                            "isapplychorus": 0
                        }
                    ],
                    "offset": 1,
                    "total": 1
                },
                "errorcode": "ok"
            }
        """
    
        DKLog.share.log(keyword: keyword,
                        message: message)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
