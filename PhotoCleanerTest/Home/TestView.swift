import SwiftUI
import Photos
import Combine

fileprivate final class MediaStatsViewModel: ObservableObject {
    
    @Published var livePhotoCount: Int = 0
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var firstAsset: PHAsset? = nil
    @Published var firstImage: UIImage? = nil
    
    @Published var allAssets: Int = 0
    @Published var photoCount: Int = 0
    @Published var videoCount: Int = 0
    
    func requestAccessWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.requestAccess()
        }
    }
    
    private func requestAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
                
                if status == .authorized || status == .limited {
                    self.fetchMediaCounts()
                }
            }
        }
    }
    
    private func fetchMediaCounts() {
        let imageOptions = PHFetchOptions()
        imageOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue) // Перевіряємо чи mediaType відповідає фотографіям
        
        let videoOptions = PHFetchOptions()
        videoOptions.predicate = NSPredicate(format: "mediaType == %d AND duration >= %f", PHAssetMediaType.video.rawValue, 100.0) // Перевіряємо чи mediaType відповідає відео І їх довжина більше 100 секунд
        
        let livePhotoOptions = PHFetchOptions() // ЛайфФото це тільки фотографії (бо не існує Live відео наприклад або аудіо, це просто чернова перевірка, на всякий випадок) і підкатегорія фотографій має бути ЛайфФото
        var livePhotoPredicates: [NSPredicate] = [] // Масив наших фільтрів
        
        livePhotoPredicates.append(NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)) // Перевіряємо чи mediaType відповідає фотографіям, бо в інших категоріях не існує LivePhoto
        
        livePhotoPredicates.append(NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoLive.rawValue)) // Беремо всі категорії і перевіряємо, чи серед них є ЛайфФото (тобто це буде брати всі варіації LivePhoto, які тільки можливі і не можливі, наприклад тільки Лайф, Лайф з HDR, Лайф панорами тощо)
        livePhotoOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: livePhotoPredicates)
        
        
        let livePhotoSimpleOptions = PHFetchOptions()
        var livePhotoSimplePredicates: [NSPredicate] = []
        livePhotoSimplePredicates.append(NSPredicate(format: "mediaType == %d AND mediaSubtype == %d", PHAssetMediaType.image.rawValue, PHAssetMediaSubtype.photoLive.rawValue))
        
        livePhotoSimpleOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: livePhotoSimplePredicates)
        let livePhotoSimpleCount = PHAsset.fetchAssets(with: livePhotoSimpleOptions).count
        print("livePhotoSimpleCount: \(livePhotoSimpleCount)")
        
        
        let livePhotoTheSimplestOptions = PHFetchOptions() // Максимально простий предікейт
        livePhotoTheSimplestOptions.predicate = NSPredicate(format: "mediaType == %d AND mediaSubtype == %d", PHAssetMediaType.image.rawValue, PHAssetMediaSubtype.photoLive.rawValue)
        let livePhotoTheSimplestCount = PHAsset.fetchAssets(with: livePhotoTheSimplestOptions).count
        print("livePhotoTheSimplestCount: \(livePhotoTheSimplestCount)")
        
        let assets = PHAsset.fetchAssets(with: nil)
        allAssets = assets.count
        firstAsset = assets.firstObject
        if let firstAsset {
            loadFirstImage(firstAsset)
        }
        photoCount = PHAsset.fetchAssets(with: imageOptions).count
        livePhotoCount = PHAsset.fetchAssets(with: livePhotoOptions).count
        videoCount = PHAsset.fetchAssets(with: videoOptions).count
    }
    
    func loadFirstImage(_ asset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFit, options: options) { [weak self] (uiImage, info) in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                self?.firstImage = uiImage
            }
        }

    }
}

struct TestView: View {
    
    @StateObject private var viewModel = MediaStatsViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("Media stats")
                .font(.title.bold())
            
            if viewModel.authorizationStatus == .authorized ||
               viewModel.authorizationStatus == .limited {
                
                VStack {
                    VStack(spacing: 8) {
                        Text("🌁 All media: \(viewModel.allAssets)")
                        Text("📷 Photos: \(viewModel.photoCount)")
                        Text("🌅 LivePhotos: \(viewModel.livePhotoCount)")
                        Text("🎥 Videos: \(viewModel.videoCount)")
                    }
                    .font(.title3)
                    
                    if let firstImage = viewModel.firstImage {
                        Image(uiImage: firstImage)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                
            } else {
                Text("Waiting for photo access…")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .onAppear {
            viewModel.requestAccessWithDelay()
        }
    }
}

#Preview {
    TestView()
}
