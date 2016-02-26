import Foundation
import Commander

Group {

    func convertCSV(source: String, destination: String) {
        do {
            let csvString = try String(contentsOfFile: source)
            var rows = csvString.componentsSeparatedByString("\n").map { $0.componentsSeparatedByString(",") }
            rows.removeAtIndex(0)


            var newCSV = ""
            for row in rows {
                if row.count > 3 {
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let date = formatter.dateFromString(row[2])!
                    formatter.dateFormat = "dd/MM/yyyy"
                    let dateString = formatter.stringFromDate(date)

                    newCSV += "\(dateString),\(row[3]),\(row[0]) Payment\n"
                    newCSV += "\(dateString),-\(row[8]),\(row[0]) Fees\n"
                    if let refund = Float(row[4]) where refund > 0 {
                        newCSV += "\(dateString),-\(refund),\(row[0]) Refund\n"
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
