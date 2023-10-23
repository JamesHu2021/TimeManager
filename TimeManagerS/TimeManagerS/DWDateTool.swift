//
//  DWDateTool.swift
//  TimeManagerS
//
//  Created by Huafang Zhang on 2023-02-18.
//

import Foundation
import UIKit

enum TimeFormat: String{
    case YYYYMMDD = "YYYY-MM-dd"
    case YYYYMMDDHH = "YYYY-MM-dd HH"
    case YYYYMMDDHHMM = "YYYY-MM-dd HH:mm"
    case YYYYMMDDHHMMSS = "YYYY-MM-dd HH:mm:ss"
    case YYYYMMDDHHMMSSsss = "YYYY-MM-dd HH:mm:ss.SSS"
}

class DWDateTool: NSObject{

        /// 获取当前时间
        /// - Parameter timeFormat: 时间类型，TimeFormat为枚举
        public static func getCurrentTime(timeFormat:TimeFormat) -> String{
            let formatter = DateFormatter()
            formatter.dateFormat = timeFormat.rawValue
            let timezone = NSTimeZone.system//TimeZone.init(identifier: "Asia/Beijing")
            formatter.timeZone = timezone
            let dateTime = formatter.string(from: Date.init())
            return dateTime
        }
        
        /// 字符串时间转时间戳
        /// - Parameters:
        ///   - timeFormat: 时间格式
        ///   - timeString: 要转的字符串时间
        public static func timeToTimestamp(timeFormat:TimeFormat,timeString:String) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.dateFormat = timeFormat.rawValue
            let timezone = NSTimeZone.system//TimeZone.init(identifier: "Asia/Beijing")
            formatter.timeZone = timezone
            let dateTime = formatter.date(from: timeString)
            return String(dateTime!.timeIntervalSince1970)
        }
        
        /// 将字符串转成NSDate类型
        /// - Parameters:
        ///   - timeFormat: 时间分类
        ///   - date: 时间
        public static func dateFromString(timeFormat:TimeFormat,date:String) -> NSDate {
            let formatter = DateFormatter()
            formatter.locale = NSLocale.system//NSLocale.init(localeIdentifier: "en_US") as Locale
            formatter.dateFormat = timeFormat.rawValue
            let inputDate = formatter.date(from: date)
            let zone = NSTimeZone.system
            let interval = zone.secondsFromGMT(for: inputDate!)
            let localeDate = inputDate?.addingTimeInterval(TimeInterval(interval))
            return localeDate! as NSDate
        }
        
        /// 获取前一天时间
        /// - Parameters:
        ///   - timeFormat: 时间格式
        ///   - dateString: 当前时间
        public static func getLastDay(timeFormat:TimeFormat,dateString:String) -> String {
            let lastDay = NSDate.init(timeInterval: -24 * 60 * 60, since: dateFromString(timeFormat: timeFormat, date: dateString) as Date)
            let formatter = DateFormatter()
            formatter.dateFormat = timeFormat.rawValue
            let strDate = formatter.string(from: lastDay as Date)
            return strDate
        }
        
        /// 获取下一天时间
        /// - Parameters:
        ///   - timeFormat: 时间格式
        ///   - dateString: 当前时间
        public static func getNextDay(timeFormat:TimeFormat,dateString:String) -> String {
            let lastDay = NSDate.init(timeInterval: 24 * 60 * 60, since: dateFromString(timeFormat: timeFormat, date: dateString) as Date)
            let formatter = DateFormatter()
            formatter.dateFormat = timeFormat.rawValue
            let strDate = formatter.string(from: lastDay as Date)
            return strDate
        }
        
        /// 获取当前时间是星期几
        public static func getNowWeekday() -> String {
            let calendar:Calendar = Calendar(identifier: .gregorian)
            var comps:DateComponents = DateComponents()
            comps = calendar.dateComponents([.year,.month,.day,.weekday,.hour,.minute,.second], from: Date())
            let weekDay = comps.weekday! - 1
            //星期
            let array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]//["星期日","星期一","星期二","星期三","星期四","星期五","星期六"]
            return array[weekDay]
        }
    
        //获得给定日期是星期几 //to keep it same as comps.weekday [1-7]
        public static func getWeekDay (_ nYear: Int, _ nMonth: Int, _ nDay: Int ) -> Int {
            let  dateFmt  =  DateFormatter ()
            dateFmt.dateFormat  =  TimeFormat.YYYYMMDD.rawValue
            let  inputDate  =  dateFmt.date( from: "\(nYear)-\(nMonth)-\(nDay)" )
//            print(">>>>>The input data is : \(String(describing: inputDate))")

            let interval = Int(inputDate!.timeIntervalSince1970) + Int(NSTimeZone.local.secondsFromGMT())
            let  days  =  Int ( interval / 86400 )  // 24*60*60
            let  weekday  = (( days  +  4 ) % 7 + 7 ) % 7  //weekday 0:Sunday, 1:Monday, 2: Tuesday, 3: Wednesday, 4: Thursday, 5: Friday, 6: Saturday
            return (weekday+1)//to keep it same as comps.weekday [1-7]
            //            return  weekday  ==  0  ?  7  :  weekday
        }
    
        //获得给定日期所在周的起始日期和结束日期
        //Input: year, month, day
        //return: the start date and end date of the week, such as : 2023/03/05-03/11
        public static func getWeekRangeforDate(_ nYear: Int, _ nMonth: Int, _ nDay: Int)->String
        {
            let curWeekday = DWDateTool.getWeekDay(nYear, nMonth, nDay)
            let firstday = curWeekday-1
            let lastday = 7 - curWeekday
            
            
            let  dateFmt  =  DateFormatter ()
            dateFmt.dateFormat  =  TimeFormat.YYYYMMDD.rawValue
            let  inputDate  =  dateFmt.date( from: "\(nYear)-\(nMonth)-\(nDay)" )
            
            var dateComponent0 = DateComponents()
            dateComponent0.day = firstday*(-1)
            let firstDate = Calendar.current.date(byAdding: dateComponent0, to: inputDate!)
            
            var dateComponent1 = DateComponents()
            dateComponent1.day = lastday
            let lastDate = Calendar.current.date(byAdding: dateComponent1, to: inputDate!)
            
            let calendar = Calendar.current
            let resultString = String(format: "%d/%02d/%02d-%02d/%02d", calendar.component(.year, from: firstDate!), calendar.component(.month, from: firstDate!), calendar.component(.day, from: firstDate!), calendar.component(.month, from: lastDate!), calendar.component(.day, from: lastDate!))
            return resultString
        }

    
        /// 将时间间隔转为时间
        /// - Parameters:
        ///   - curInterval: 间隔
        public static func getTimeStringFromInterval(_ curInterval : Int) -> String {
        
            let nHourTmp = (Int(curInterval))/3600
            let nMinTmp = (Int(curInterval)%3600)/60
            let nSecTmp = ((Int(curInterval)%3600)%60)
            let strDuration = String(format: "%02d:%02d:%02d", nHourTmp, nMinTmp, nSecTmp)
        
            return strDuration
        }
    

        
        /// 将时间戳转为时间
        /// - Parameters:
        ///   - timeFormat: 时间类型
        ///   - timeString: 时间戳
        public static func getTimeFromTimestamp(timeFormat:TimeFormat,timeString:String) -> String {
            let newTime = Int(timeString)! / 1000
            let myDate = NSDate.init(timeIntervalSince1970: TimeInterval(newTime))
            let formatter = DateFormatter()
            formatter.dateFormat = timeFormat.rawValue
            let timeString = formatter.string(from: myDate as Date)
            return timeString
        }
        
        /// 获取当前时间戳
        /// - Parameters:
        ///   - timeFormat: 时间类型
        public static func getNowTimeTimestamp(timeFormat:TimeFormat) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.dateFormat = timeFormat.rawValue
            let timezone = NSTimeZone.system//TimeZone.init(identifier: "Asia/Beijing")
            formatter.timeZone = timezone
            let dateTime = NSDate.init()
            //这里是秒，如果想要毫秒timeIntervalSince1970 * 1000
            let timeSp = String(format: "%d", dateTime.timeIntervalSince1970)
            return timeSp
        }
        
        /// 计算两个时间的差值
        /// - Parameters:
        ///   - timeFormat: 时间格式
        ///   - endTime: 结束时间
        ///   - starTime: 开始时间
        public static func acquisitionTimeDifference(timeFormat:TimeFormat,endTime:String,starTime:String) -> NSInteger {
            let formatter = DateFormatter()
            formatter.dateFormat = timeFormat.rawValue
            let end = formatter.date(from: endTime)
            let endDate = end!.timeIntervalSince1970 * 1.0
            let start = formatter.date(from: starTime)
            let starDate = start!.timeIntervalSince1970 * 1.0
            let poor = endDate - starDate
            var house = ""
            var min = ""
            min = String(format: "%d", Int(poor / 60) % 60)
            house = String(format: "%d", poor / 3600)
            return Int(house)! * 3600 + Int(min)! * 60
        }
        
        /// 比较两个时间的大小
        /// - Parameters:
        ///   - timeFormat: 时间格式
        ///   - date1: 时间1
        ///   - date2: 时间2
        public static func compareDate(timeFormat:TimeFormat,date1:String,date2:String) -> Int {
            var ci = Int()
            let formatter = DateFormatter()
            formatter.dateFormat = timeFormat.rawValue
            var dt1 = NSDate.init()
            var dt2 = NSDate.init()
            dt1 = formatter.date(from: date1)! as NSDate
            dt2 = formatter.date(from: date2)! as NSDate
            let result = dt1.compare(dt2 as Date)
            switch result {
            case .orderedAscending:
                ci = 1
            case .orderedDescending:
                ci = -1
            case .orderedSame:
                ci = 0
            default:
                break
            }
            return ci
        }
        
        /// 获取过去某个时间
        /// - Parameter timeFormat: 时间格式
        public static func getCurrentPastTime(timeFormat:TimeFormat) -> String {
            let mydate = NSDate.init()
            let formatter = DateFormatter()
            formatter.dateFormat = timeFormat.rawValue
            let calendar:Calendar = Calendar(identifier: .gregorian)
            let adcomps = NSDateComponents()
            adcomps.year = 0
            adcomps.month = -2
            adcomps.day = 0
            let newdate = calendar.date(byAdding: adcomps as DateComponents, to: mydate as Date, wrappingComponents: false)
            let befordate = formatter.string(from: newdate!)
            return befordate
        }
        
        /// 获取明天同一时间
        /// - Parameters:
        ///   - timeFormat: 时间格式
        public static func getTomorrowDay(timeFormat:TimeFormat) -> String {
            let calendar:Calendar = Calendar(identifier: .gregorian)
            var comps:DateComponents = DateComponents()
            comps = calendar.dateComponents([.year,.month,.day,.weekday,.hour,.minute,.second], from: Date())
            comps.day = comps.day! + 1
            let beginningOfWeek = calendar.date(from: comps)
            let formatter = DateFormatter()
            formatter.dateFormat = timeFormat.rawValue
            return formatter.string(from: beginningOfWeek!)
        }
    
    func logWithTag(_ tag:String)
    {
        let dataLogPath = NSHomeDirectory() + "/Documents/logData.txt"
        let fileM = FileManager()
        if !fileM.fileExists(atPath: dataLogPath) {
            try! ("" as NSString).write(toFile: dataLogPath, atomically: true, encoding: String.Encoding.utf8.rawValue)
        }
        let dataLog = try! NSMutableString(contentsOfFile: dataLogPath, encoding: String.Encoding.utf8.rawValue)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: Date())
        let line = dateStr + " : " + tag + "   \n"
        dataLog.append(line)
        print(dataLog)
        try! dataLog.write(toFile: dataLogPath, atomically: true, encoding: String.Encoding.utf8.rawValue)
    }
    
    func readLogInfo()->String{
        let dataLogPath = NSHomeDirectory() + "/Documents/logData.txt"
        let fileM = FileManager()
        if !fileM.fileExists(atPath: dataLogPath) {
            try! ("" as NSString).write(toFile: dataLogPath, atomically: true, encoding: String.Encoding.utf8.rawValue)
        }
        let dataLog = try! NSMutableString(contentsOfFile: dataLogPath, encoding: String.Encoding.utf8.rawValue)
        return dataLog as String
    }

}



///////////////////////////////////////////////////////////////////////////////////////

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

///////////////////////////////////////////////////////////////////////////////////////


extension UIButton
{
    func allowTextToScale(minFontScale: CGFloat = 0.5, numberOfLines: Int = 1)
    {
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = minFontScale
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        // Caution! The above causes numberOfLines to become 1,
        // so this next line must be AFTER that one.
        self.titleLabel?.numberOfLines = numberOfLines
    }

}
