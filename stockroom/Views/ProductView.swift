//
//  ContentView.swift
//  stockroom
//
//  Created by Christopher Regner on 2/16/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProductView: View {
   var product: Product?

   @Environment(\.modelContext) private var modelContext
   @Environment(\.presentationMode) var presentationMode

   @State private var name: String
   @State private var price: Double
   @State private var stock: Int
   @State private var description: String
   @State private var photos: [Data]

   init(product: Product? = nil) {
       self.product = product
       _name = State(initialValue: product?.name ?? "")
       _price = State(initialValue: product?.price ?? 0.0)
       _stock = State(initialValue: product?.stock ?? 0)
       _description = State(initialValue: product?.productDescription ?? "")
       _photos = State(initialValue: product?.photos ?? [])
   }

   @State private var isNameEmptyAlertPresented = false

   private var integerFormatter: NumberFormatter {
       let formatter = NumberFormatter()
       formatter.numberStyle = .none
       formatter.maximumFractionDigits = 0 // Ensures no fractional part
       return formatter
   }

   private func addProduct() {
           let newItem = Product(
               timestamp: Date(),
               name: name,
               price: price,
               stock: stock,
               productDescription: description,
               photos: photos
           )

           modelContext.insert(newItem)
   }

   private func updateProduct() {
       guard let product = product else { return }

       product.name = name
       product.price = price
       product.stock = stock
       product.productDescription = description
       product.photos = photos
   }

   private func save() {
       withAnimation {
           if name.isEmpty {
               isNameEmptyAlertPresented = true
               return
           }

           if (self.product != nil) {
               updateProduct()
           } else {
               addProduct()
           }

           self.presentationMode.wrappedValue.dismiss()
       }
   }

    var body: some View {
        NavigationStack {
           ScrollView(.vertical) {
               VStack {
                   PhotosSection(photos: $photos)

                   VStack(alignment: .leading) {
                       Text("Product Name:")
                       TextField("Enter product name", text: $name)
                           .padding()
                           .border(Color.gray, width: 1)

                       Text("Price:")
                       TextField(
                           "Enter price",
                           value: $price,
                           format: .currency(code: "PHP")
                       )
                           .keyboardType(.decimalPad)
                           .padding()
                           .border(Color.gray, width: 1)

                       Text("Stock:")
                       TextField("Enter stock", value: $stock, formatter: integerFormatter)
                           .keyboardType(.numberPad)
                           .padding()
                           .border(Color.gray, width: 1)

                       ControlGroup {
                           Button("-10") { stock = max(stock - 10, 0) }
                           Button("-1") { stock = max(stock - 1, 0) }
                           Button("+1") { stock = max(stock + 1, 0) }
                           Button("+10") { stock = max(stock + 10, 0) }
                       }

                       Text("Description:")
                       TextEditor(text: $description)
                           .frame(height: 120)
                           .padding()
                           .border(Color.gray, width: 1)
                   }
                   .padding()
               }
           }
           .toolbar {
               ToolbarItem(placement: .bottomBar) {
                   HStack {
                       Button("Cancel") {
                           self.presentationMode.wrappedValue.dismiss()
                       }
                       .buttonStyle(.borderedProminent)
                       .tint(.red)
                       Spacer()
                       Button("Save") {
                           save()
                       }
                           .alert(isPresented: $isNameEmptyAlertPresented) {
                               Alert(
                                   title: Text("Error"),
                                   message: Text("Product name cannot be empty."),
                                   dismissButton: .default(Text("OK"))
                               )
                           }
                       .buttonStyle(.borderedProminent)
                       .tint(.blue)
                   }
               }

           }
           .navigationBarTitle(
               product == nil
               ? "Add Product"
               : "Update Product"
           )
        }
    }
}

struct PhotosSection: View {
   @State var photosPickerItems: [PhotosPickerItem] = []
   @Binding var photo: [Data]

   init(photos: Binding<[Data]>) {
       self._photo = photos
   }

   var body: some View {
       ScrollView(.horizontal) {
           HStack() {
               PhotosPicker(
                   selection: $photosPickerItems,
                   matching: .images
               ) {
                   VStack(spacing: 8) {
                       Image(systemName: "photo")
                       Text("Add Photo")
                       .padding(.horizontal)
                   }
                   .frame(width: 120, height: 120)
                   .foregroundStyle(Color.white)
                   .background(Color.blue)
               }
               .onChange(of: photosPickerItems) {_, newPhotos in
                   Task {
                       for newPhoto in newPhotos {
                           if let data = try? await newPhoto.loadTransferable(
                               type: Data.self
                           ) {
                               self.photo.append(data)
                           }
                       }
                   }
               }

               ForEach(photo.indices, id: \.self) { index in
                   NavigationLink(
                       destination: PhotoView(index: index, photos: $photo)
                   ) {
                       Image(data: photo[index])?
                           .resizable()
                           .frame(width: 120, height: 120)
                   }
               }
           }
           .padding()
       }
   }
}

struct ProductView_Previews: PreviewProvider {
   static var sampleProduct = Product.createRandom()

   static var container: ModelContainer {
       let config = ModelConfiguration(isStoredInMemoryOnly: true)
       return try! ModelContainer(for: Product.self, configurations: config)
   }

    static var previews: some View {
       NavigationView {
           ProductView(product: sampleProduct)
               .modelContainer(container)
       }
    }
}
