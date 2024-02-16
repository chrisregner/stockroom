//
//  ContentView.swift
//  stockroom
//
//  Created by Christopher Regner on 2/16/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var products: [Product]

    @State private var selectedProducts: Set<Product> = []
    @State private var editMode: EditMode = .inactive
    @State private var searchText: String = ""

    private func deleteProduct(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(products[index])
        }
    }

    private func handleDelete(at offsets: IndexSet) {
        withAnimation {
            deleteProduct(at: offsets)
        }
    }

    private func deleteSelectedProducts() {
        guard !selectedProducts.isEmpty else { return }

        for product in selectedProducts {
            modelContext.delete(product)
        }
    }

    private func handleDeleteSelected() {
        withAnimation {
            deleteSelectedProducts()
            editMode = .inactive
        }
    }

    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.contains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List(selection: $selectedProducts) {
                        ForEach(filteredProducts, id: \.self) { product in
                            NavigationLink(destination: ProductView(product: product)) {
                                    HStack {
                                        Text(product.name)
                                        Spacer()
                                        Text(product.price, format: .currency(code: "PHP"))
                                        Text("QTY: \(String(product.stock))")
                                            .frame(width: 72, alignment: .leading)
                                            .padding(.leading, 8)
                                    }
                            }
                        }
                        .onDelete(perform: editMode == .active ? nil : handleDelete)
    //                    .onDelete(perform: deleteProduct)
    //                    .deleteDisabled(editMode == .active)
                    }
                }
                
                FloatingAddButton()
            }
            .navigationBarTitle("Home")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    EditButton()
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    if editMode == .active {
                        Button("Delete Selected", action: handleDeleteSelected)
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
        .searchable(text: $searchText) {
        }
    }
}

struct FloatingAddButton: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                NavigationLink(destination: ProductView()) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .frame(width: 60, height: 60)
                .background(.blue)
                .cornerRadius(30)
                .shadow(radius: 12)
                .offset(x: -24, y: -8)
            }
        }
    }
}

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
        VStack {
            PhotosSection(photos: $photos)

            Form {
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

                    Text("Description:")
                    TextEditor(text: $description)
                        .frame(height: 120)
                        .padding()
                        .border(Color.gray, width: 1)
                }
            }

            Spacer()

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
                .padding(.horizontal)
        }

        .navigationBarTitle("Add Product")

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

struct PhotoView: View {
    var index: Int
    @Binding var photo: [Data]
    @Environment(\.presentationMode) var presentationMode
    
    init(index: Int, photos: Binding<[Data]>) {
        self._photo = photos
        self.index = index
    }
    
    var body: some View {
        Image(data: photo[index])?
            .resizable()
            .aspectRatio(UIImage(data: photo[index])!.size, contentMode: .fill)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Delete") {
                        photo.remove(at: index)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
    }
}

let previewContainer: ModelContainer = {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Product.self, configurations: config)

        Task { @MainActor in
            let context = container.mainContext

            for _ in 0..<20 {
                let product = Product.createRandom()
                context.insert(product)
            }
        }

        return container
    } catch {
        fatalError()
    }
}()

#Preview {
    ContentView()
        .modelContainer(previewContainer)
//    ProductView()
//        .modelContainer(for: Product.self, inMemory: true)
}
