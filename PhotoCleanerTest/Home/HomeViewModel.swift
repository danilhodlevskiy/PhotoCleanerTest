//
//  HomeViewModel.swift
//  PhotoCleanerTest
//
//  Created by danilka on 22.01.2026.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published var test: String = ""
    
    @Published var totalStorage: Double? = nil
    @Published var usedStorage: Double? = nil
    @Published var usedStoragePercent: Double = 0
    
    func load() {

        if let storageInfo = getDeviceStorageInfo() {
            totalStorage = Double(storageInfo.totalSpace) / (1024 * 1024 * 1024)
            usedStorage = Double(storageInfo.usedSpace) / (1024 * 1024 * 1024)
            
            if let totalStorage, let usedStorage {
                Task { [weak self] in
                    try? await Task.sleep(for: .milliseconds(250))
                    guard let self else { return }
                    
                    withAnimation(.smooth(duration: 1)) {
                        self.usedStoragePercent = (usedStorage / totalStorage )
                    }
                }
            }
        }
    }
    
    func getDeviceStorageInfo() -> (totalSpace: Int64, usedSpace: Int64)? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey])
            if let totalCapacity = values.volumeTotalCapacity,
               let availableCapacity = values.volumeAvailableCapacityForImportantUsage {
                return (Int64(totalCapacity), (Int64(totalCapacity) - availableCapacity))
            }
        } catch {
            print("Error retrieving storage info: \(error.localizedDescription)")
        }
        return nil
    }
    
    
    
}
