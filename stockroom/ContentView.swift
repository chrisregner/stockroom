//
//  ContentView.swift
//  stockroom
//
//  Created by Christopher Regner on 2/16/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var products: [Product]
    
    @State private var selectedProducts: Set<Product> = []
    @State var editMode: EditMode = .inactive

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

    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink(destination: ProductView()) {
                    Text("Add Product")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                List(selection: $selectedProducts) {
                    ForEach(products, id: \.self) { product in
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

    init(product: Product? = nil) {
        self.product = product
        _name = State(initialValue: product?.name ?? "")
        _price = State(initialValue: product?.price ?? 0.0)
        _stock = State(initialValue: product?.stock ?? 0)
        _description = State(initialValue: product?.productDescription ?? "")
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
                productDescription: description
            )

            modelContext.insert(newItem)
    }

    private func updateProduct() {
        guard let product = product else { return }

        product.name = name
        product.price = price
        product.stock = stock
        product.productDescription = description
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

let previewContainer: ModelContainer = {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Product.self, configurations: config)

        Task { @MainActor in
            let context = container.mainContext

            for _ in 0..<10 {
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
//    AddProductView()
//        .modelContainer(for: Product.self, inMemory: true)
}
