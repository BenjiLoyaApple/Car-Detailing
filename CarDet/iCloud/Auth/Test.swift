//
//  Test.swift
//  CarDet
//
//  Created by BenjiLoya on 22.10.2025.
//

import SwiftUI
import CloudKit
import Combine

class CloudKitUserViewModel: ObservableObject {
    @Published var isSignedInToiCloud: Bool = false
    @Published var permissinStatus: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    
    init() {
        getCloudStatus()
        requestPermission()
        fetchiCloudUserRecordID()
    }
    
    private func getCloudStatus() {
        CKContainer.default().accountStatus { [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self?.isSignedInToiCloud = true
                case .noAccount:
                    self?.error = CloudKitError.iCloudAccountNotFound.rawValue
                case .couldNotDetermine:
                    self?.error = CloudKitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self?.error = CloudKitError.iCloudAccountRestricted.rawValue
                default:
                    self?.error = CloudKitError.iCloudAccountUnknown.rawValue
                }
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
    }
    
    func requestPermission() {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                if returnedStatus == .granted {
                    self?.permissinStatus = true
                }
            }
        }
    }
    
    func fetchiCloudUserRecordID() {
        CKContainer.default().fetchUserRecordID { [weak self] returnedID, returnedError in
            if let id = returnedID {
                self?.discoveriCloudUser(id: id)
            }
        }
    }
    
    func discoveriCloudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [weak self] returnedIdentify, returnedError in
            DispatchQueue.main.async {
                if let name = returnedIdentify?.nameComponents?.givenName {
                    self?.userName = name
                }
            }
        }
    }
    
}

struct CloudKitView: View {
    @StateObject private  var vm = CloudKitUserViewModel()
    
    var body: some View {
        VStack {
            Text("Is Signed in: \(vm.isSignedInToiCloud.description.uppercased())")
            Text("Error: \(vm.error)")
            Text("Permission: \(vm.permissinStatus.description.uppercased())")
            Text("Name: \(vm.userName)")
        }
    }
}

#Preview {
    CloudKitView()
}
