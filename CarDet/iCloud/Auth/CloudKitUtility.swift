//
//  CloudKitUtility.swift
//  SwiftfulThinkingAdvancedLearning
//
//  Created by Nick Sarno on 11/4/21.
//

/*
import Foundation
import CloudKit
import Combine
import UIKit

protocol CloudKitableProtocol {
    init?(record: CKRecord)
    var record: CKRecord { get }
}

enum CloudKitDatabaseType {
    case `public`, `private`
}

class CloudKitUtility {
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
        case iCloudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }

    static func database(_ type: CloudKitDatabaseType) -> CKDatabase {
        switch type {
        case .public:
            return CKContainer.default().publicCloudDatabase
        case .private:
            return CKContainer.default().privateCloudDatabase
        }
    }
}

// MARK: - USER FUNCTIONS
extension CloudKitUtility {

    static func getiCloudStatus() -> Future<Bool, Error> {
        Future { promise in
            CKContainer.default().accountStatus { status, error in
                if let error = error {
                    print("[CloudKit] ❌ accountStatus error: \(error.localizedDescription)")
                    promise(.failure(error))
                    return
                }

                switch status {
                case .available:
                    promise(.success(true))
                case .noAccount:
                    promise(.failure(CloudKitError.iCloudAccountNotFound))
                case .couldNotDetermine:
                    promise(.failure(CloudKitError.iCloudAccountNotDetermined))
                case .restricted:
                    promise(.failure(CloudKitError.iCloudAccountRestricted))
                default:
                    promise(.failure(CloudKitError.iCloudAccountUnknown))
                }
            }
        }
    }

    static func requestApplicationPermission() -> Future<Bool, Error> {
        Future { promise in
            CKContainer.default().requestApplicationPermission([.userDiscoverability]) { status, _ in
                if status == .granted {
                    promise(.success(true))
                } else {
                    promise(.failure(CloudKitError.iCloudApplicationPermissionNotGranted))
                }
            }
        }
    }

    static func discoverUserIdentity() -> Future<String, Error> {
        Future { promise in
            CKContainer.default().fetchUserRecordID { recordID, error in
                guard let recordID = recordID else {
                    return promise(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
                }
                CKContainer.default().discoverUserIdentity(withUserRecordID: recordID) { identity, _ in
                    if let components = identity?.nameComponents {
                        let formatter = PersonNameComponentsFormatter()
                        promise(.success(formatter.string(from: components)))
                    } else {
                        promise(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
                    }
                }
            }
        }
    }
    
    static func fetchRecord<T: CloudKitableProtocol>(
        by id: CKRecord.ID,
        recordType: String,
        database: CloudKitDatabaseType = .private
    ) -> AnyPublisher<T?, Error> {
        Future { promise in
            CloudKitUtility.database(database).fetch(withRecordID: id) { record, error in
                if let error = error {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                } else if let record = record, let item = T(record: record) {
                    DispatchQueue.main.async {
                        promise(.success(item))
                    }
                } else {
                    DispatchQueue.main.async {
                        promise(.success(nil))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}

extension CloudKitUtility {
    static func userProfileRecordID(completion: @escaping (CKRecord.ID?) -> Void) {
        CKContainer.default().fetchUserRecordID { userID, error in
            guard let userID = userID else {
                completion(nil)
                return
            }

            let customID = CKRecord.ID(recordName: "user-\(userID.recordName)")
            completion(customID)
        }
    }
}



// MARK: - CRUD FUNCTIONS
extension CloudKitUtility {

    static func fetch<T: CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil,
        database: CloudKitDatabaseType = .private
    ) -> Future<[T], Error> {
        Future { promise in
            fetch(
                predicate: predicate,
                recordType: recordType,
                sortDescriptions: sortDescriptions,
                resultsLimit: resultsLimit,
                database: database
            ) { (items: [T]) in
                promise(.success(items))
            }
        }
    }

    private static func fetch<T: CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil,
        database: CloudKitDatabaseType,
        completion: @escaping ([T]) -> Void
    ) {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptions
        let operation = CKQueryOperation(query: query)
        if let limit = resultsLimit {
            operation.resultsLimit = limit
        }

        var results: [T] = []
        addRecordMatchedBlock(operation: operation) { item in
            results.append(item)
        }
        addQueryResultBlock(operation: operation) { _ in
            completion(results)
        }

        add(operation: operation, to: database)
    }

    private static func addRecordMatchedBlock<T: CloudKitableProtocol>(
        operation: CKQueryOperation,
        completion: @escaping (T) -> Void
    ) {
            operation.recordMatchedBlock = { _, result in
                if case .success(let record) = result, let item = T(record: record) {
                    completion(item)
                }
            }
        
    }

    private static func addQueryResultBlock(
        operation: CKQueryOperation,
        completion: @escaping (Bool) -> Void
    ) {
            operation.queryResultBlock = { _ in completion(true) }
       
    }

    private static func add(operation: CKDatabaseOperation, to database: CloudKitDatabaseType) {
        CloudKitUtility.database(database).add(operation)
    }

    static func add<T: CloudKitableProtocol>(
        item: T,
        database: CloudKitDatabaseType = .private,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        save(record: item.record, database: database, completion: completion)
    }

    static func update<T: CloudKitableProtocol>(
        item: T,
        database: CloudKitDatabaseType = .private,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        add(item: item, database: database, completion: completion)
    }

    private static func save(
        record: CKRecord,
        database: CloudKitDatabaseType,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        CloudKitUtility.database(database).save(record) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    static func delete<T: CloudKitableProtocol>(
        item: T,
        database: CloudKitDatabaseType = .private
    ) -> Future<Bool, Error> {
        Future { promise in
            delete(record: item.record, database: database, completion: promise)
        }
    }

    private static func delete(
        record: CKRecord,
        database: CloudKitDatabaseType,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        CloudKitUtility.database(database).delete(withRecordID: record.recordID) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
*/
