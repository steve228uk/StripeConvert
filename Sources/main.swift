import Foundation
import Commander

Group {
    $0.command("convert", description: "Convert Stripe CSV to work with FreeAgent") { (csv: String, destination: String) in
        do {
            let csvString = try String(contentsOfFile: csv)
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
            }
            
            print("✅ Converted")
            
        } catch {
            print("❌ Could not open CSV")
        }
    }
}.run()
