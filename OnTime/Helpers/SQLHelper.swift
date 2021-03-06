//
//  SQLHelper.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import Foundation
import SQLite3

public class SQLHelper{
    
    static let instance = SQLHelper()
    
    var db : OpaquePointer? = nil
    
    private init(){}
    
    func openDatabase(){
        var db: OpaquePointer?
            let file_URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("records.sqlite")
            if sqlite3_open(file_URL.path, &db) != SQLITE_OK {
               print("There's error in opening the database")
            }
        let createQuery = """
        CREATE TABLE IF NOT EXISTS tblRecords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usrToken VARCHAR(32),
        dbToken VARCHAR(32),
        RecordTime DATETIME,
        GPSlat DECIMAL (9,6),
        GPSlon DECIMAL (9,6),
        Site TEXT,
        Type TEXT,
        isLiveData CHAR,
        resultID TEXT
        );
        """
            if sqlite3_exec(db, createQuery, nil, nil, nil) == SQLITE_OK {
                self.db = db
            }
                else {
               let errorMsg = String(cString: sqlite3_errmsg(db)!)
               print("There's error creating the table: \(errorMsg)")
        }
    }
    
    func insert(record: CheckInInfo){
        let insertStatementString = """
        INSERT INTO tblRecords (usrToken, dbToken, RecordTime, GPSlat, GPSlon, Site, Type, isLiveData, resultID)
        VALUES ('\(record.usrToken)', '\(record.dbToken)', '\(record.time!)', ?, ?, '\(record.site ?? "")', '\(record.checkInState!.rawValue)', ?,  ?);
        """
          var stmt: OpaquePointer?
          if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) ==
              SQLITE_OK {
            sqlite3_bind_double(stmt, 1, record.lat!)
            sqlite3_bind_double(stmt, 2, record.lon!)
            sqlite3_bind_int(stmt, 3, record.isLiveData! ? 1 : 0)
            sqlite3_bind_text(stmt, 4, record.resultId, -1, nil)
            if sqlite3_step(stmt) == SQLITE_DONE {
            } else {
              print("\nCould not insert row.")
            }
          } else {
            print("\nINSERT statement is not prepared.")
          }
          // 5
          sqlite3_finalize(stmt)
    }
    
    func getRecords(unsyncedOnly: Bool) -> [CheckInInfo] {
        var array = [CheckInInfo]()
        let queryStatementString = """
        SELECT * FROM tblRecords
        WHERE usrToken = '\(FilesListService.instance.getUserToken())'
        AND dbToken = '\(FilesListService.instance.getDBToken())'
        \(unsyncedOnly ? "AND resultID = ''" : "")
        ORDER BY RecordTime DESC
        """
      var queryStatement: OpaquePointer?
      if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) ==
          SQLITE_OK {

        while sqlite3_step(queryStatement) == SQLITE_ROW {
            let data = CheckInInfo()
            data.id = sqlite3_column_int(queryStatement, 0)
            data.time = String(cString: sqlite3_column_text(queryStatement, 3))
            data.lat = sqlite3_column_double(queryStatement, 4)
            data.lon = sqlite3_column_double(queryStatement, 5)
            data.site = String(cString: sqlite3_column_text(queryStatement, 6))
            data.checkInState = ActivityType(rawValue: String(cString: sqlite3_column_text(queryStatement, 7)))
            data.isLiveData = sqlite3_column_int(queryStatement, 8) == 1
            data.resultId = (String(cString: sqlite3_column_text(queryStatement, 9)))
            array.append(data)
      }
      } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("\nQuery is not prepared \(errorMessage)")
        return []
      }
      sqlite3_finalize(queryStatement)
        return array
    }
    
    
    func clearRecords(olderThanDays days : Int, completion: (Bool) -> ()){
        let deleteStatementString = """
        DELETE FROM tblRecords
        WHERE usrToken = '\(FilesListService.instance.getUserToken())'
        AND dbToken = '\(FilesListService.instance.getDBToken())'
        AND RecordTime < DATETIME('now', '-\(days) days', 'localtime')
        AND resultId != '' AND resultId IS NOT NULL
        """
        if sqlite3_exec(db, deleteStatementString, nil, nil, nil) == SQLITE_OK {
                completion(true)
            }
                else {
               let errorMsg = String(cString: sqlite3_errmsg(db)!)
               print("There's error creating the table: \(errorMsg)")
                completion(false)
        }
    }
    
    
    func sync(completion: @escaping (Bool, String)->()){
        let records = getRecords(unsyncedOnly: true)
        if records.isEmpty{
            completion(true, "All items synced")
            return
        }
        let record = records.last!
            CheckInService.instance.syncUserActivity(checkInInfo: record){(success, message) in
                if success{
                let id = record.id
                let updateQuery =  """
                UPDATE tblRecords
                SET isLiveData = 'S',
                resultID = '\(message)'
                WHERE id = \(id)
                """
                    if sqlite3_exec(self.db, updateQuery, nil, nil, nil) == SQLITE_OK{
                        self.sync(completion: completion)
                    }
                    else{
                    completion(false, "Failed to write to phone")
            }
                }
                    else {
                    completion(false, "Failed to sync")
                }
        }

    }
    
    
}
