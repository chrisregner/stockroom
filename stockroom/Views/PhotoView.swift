//
//  ContentView.swift
//  stockroom
//
//  Created by Christopher Regner on 2/16/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PhotoView: View {
    var index: Int
    @Binding var photo: [Data]
    @Environment(\.presentationMode) var presentationMode
    
    init(index: Int, photos: Binding<[Data]>) {
        self._photo = photos
        self.index = index
    }
    
    var body: some View {
        if let imageData = photo[safe: index],
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(uiImage.size, contentMode: .fill)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Delete") {
                            photo.remove(at: index)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
        } else {
            // Provide a fallback view
            Text("Image not available")
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    @State static var samplePhotos: [Data] = [UIImage(named: "cat1")!.jpegData(compressionQuality: 1.0)!]

    static var previews: some View {
        PhotoView(index: 0, photos: $samplePhotos)
    }                                               
}
