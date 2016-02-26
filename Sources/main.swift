import Foundation
import Commander

Group {
    
    func convertCSV(source: String, destination: String) {
        do {
            let csvString = try String(contentsOfFile: source)
            var rows = csvString.componentsSeparatedByString("\n").map { $0.componentsSeparatedByString(",") }
            rows.removeAtIndex(0)
            
            
            var newCSV = "ID,Created At,Amount,Type\n"
            for row in rows {
                if row.count > 3 {
                    newCSV += "\(row[0]),\(row[2]),\(row[3]),Payment\n"
                    newCSV += "\(row[0]),\(row[2]),-\(row[8]),Fees\n"
                    if Float(row[5]) > 0 {
                        newCSV += "\(row[0]),\(row[2]),-\(row[5]),Refund\n"
                    }
                }
            }
            
            do {
                try newCSV.writeToFile(destination, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                print("❌ Could not save CSV")
                return
            }
            
            print("✅ Converted \(source)\n")
            
        } catch {
            print("❌ Could not open CSV \(source)\n")
            return
        }
    }
    
    $0.command("convert", description: "Convert Stripe CSV to work with FreeAgent") { (csv: String, destination: String) in
        convertCSV(csv, destination: destination)
    }
    
    $0.command("directory", description: "Convert entire directory of CSVs to work with Freeagent") { (dir: String) in
        
        do {
            let fileManager = NSFileManager.defaultManager()
            let csvs = try fileManager.contentsOfDirectoryAtPath(dir).filter { NSURL(fileURLWithPath: $0).pathExtension == "csv" }
            let dest = (dir as NSString).stringByAppendingPathComponent("/converted")
            if !fileManager.fileExistsAtPath(dest) {
                do {
                    try fileManager.createDirectoryAtPath(dest, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    print("❌ Could not create 'converted' directory")
                    return
                }
            }
            
            for csv in csvs {
                let destination = (dest as NSString).stringByAppendingPathComponent(csv)
                let source = (dir as NSString).stringByAppendingPathComponent(csv)
                convertCSV(source, destination: destination)
            }
            
        } catch {
            print("❌ Could not open directory")
            return
        }
        
    }
    
}.run()

