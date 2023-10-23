//
//  ReadSaveDatatoPlist.swift
//  TimeManagerS
//
//  Created by Huafang Zhang on 2023-02-20.
//

import Foundation

class SavedTracks: NSObject,NSCoding {
    var statusIndex: Int32
    var statusName: String
    var startDateTime: Date
    var endDateTime: Date
    var timerInterval: Double
    var startYear: Int32
    var startMonth: Int32
    var startDay: Int32
    var startWeekDay: Int32
    var startWeekOfYear: Int32
    //statusIndex, statusName, startTime, endtime, timerInterval, year, month, day, weekday, weekofyear
    //构造方法
    required init(nIndex : Int32 = -1, strName:String="", startDTime:Date = Date(), endDTime:Date = Date(), dbInterval:Double = 0.0, nYear:Int32 = 0,  nMonth:Int32 = 0, nDay:Int32 = 0, nWeekDay:Int32 = 0, nWeekOfYear:Int32 = 0) {
        self.statusIndex = nIndex
        self.statusName = strName
        self.startDateTime = startDTime
        self.endDateTime = endDTime
        self.timerInterval = dbInterval
        self.startYear = nYear
        self.startMonth = nMonth
        self.startDay = nDay
        self.startWeekDay = nWeekDay
        self.startWeekOfYear = nWeekOfYear
    }
    
    //从object解析回来
    required init(coder decoder: NSCoder) {
        self.statusIndex = decoder.decodeInt32(forKey: keyNSCodingIndex)
        self.statusName = decoder.decodeObject(forKey: keyNSCodingName) as? String ?? ""
        self.startDateTime = decoder.decodeObject(forKey: keyNSCodingStartTime) as? Date ?? Date()
        self.endDateTime = decoder.decodeObject(forKey: keyNSCodingEndTime) as? Date ?? Date()
        
        self.timerInterval = decoder.decodeDouble(forKey: keyNSCodingTimerInterval)
        self.startYear = decoder.decodeInt32(forKey: keyNSCodingStartYear)
        self.startMonth = decoder.decodeInt32(forKey: keyNSCodingStartMonth)
        self.startDay = decoder.decodeInt32(forKey: keyNSCodingStartDay)
        self.startWeekDay = decoder.decodeInt32(forKey: keyNSCodingStartWeekDay)
        self.startWeekOfYear = decoder.decodeInt32(forKey: keyNSCodingStartWeekOfYear)
    }
    
    //编码成object
    func encode(with coder: NSCoder) {
        
        coder.encode(statusIndex, forKey:keyNSCodingIndex)
        coder.encode(statusName, forKey:keyNSCodingName)
        coder.encode(startDateTime, forKey:keyNSCodingStartTime)
        coder.encode(endDateTime, forKey:keyNSCodingEndTime)
        
        coder.encode(timerInterval, forKey:keyNSCodingTimerInterval)
        coder.encode(startYear, forKey:keyNSCodingStartYear)
        coder.encode(startMonth, forKey:keyNSCodingStartMonth)
        coder.encode(startDay, forKey:keyNSCodingStartDay)
        coder.encode(startWeekDay, forKey:keyNSCodingStartWeekDay)
        coder.encode(startWeekOfYear, forKey:keyNSCodingStartWeekOfYear)
    }
}

class DataModel: NSObject {
    
    var saveTrack = [SavedTracks]()
    
    override init(){
        super.init()
//        print("沙盒文件夹路径：\(documentsDirectory())")
//        print("数据文件路径：\(dataFilePath())")
    }
    
    //保存数据
    func saveData() {
        let data = NSMutableData()
        //申明一个归档处理对象
        let archiver = NSKeyedArchiver(forWritingWith: data)
        //将lists以对应Checklist关键字进行编码
        archiver.encode(saveTrack, forKey: "userDailyRecord")
        //编码结束
        archiver.finishEncoding()
        //数据写入
        data.write(toFile: dataFilePath(), atomically: true)
    }
    
    //读取数据
    func loadData() {
        //获取本地数据文件地址
        let path = self.dataFilePath()
        //声明文件管理器
        let defaultManager = FileManager()
        //通过文件地址判断数据文件是否存在
        if defaultManager.fileExists(atPath: path) {
            //读取文件数据
            let url = URL(fileURLWithPath: path)
            let data = try! Data(contentsOf: url)
            //解码器
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            //通过归档时设置的关键字Checklist还原lists
            saveTrack = unarchiver.decodeObject(forKey: "userDailyRecord") as! Array
            //结束解码
            unarchiver.finishDecoding()
        }
    }
    
    //获取沙盒文件夹路径
    func documentsDirectory()->String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)
        let documentsDirectory = paths.first!
        return documentsDirectory
    }
    
    //获取数据文件地址
    func dataFilePath ()->String{
        return self.documentsDirectory().appendingFormat("/userDailyRecord.plist")
    }
}
