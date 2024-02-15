//
//  ContentView.swift
//  stockroom
//
//  Created by Christopher Regner on 2/16/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var products: [Product]

//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle`(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink(destination: AddProductView()) {
                    Text("Add Product")
                }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                Spacer()
                
                List {
                    ForEach(products) { product in
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
            }
            .navigationBarTitle("Home")
        }
    }
}

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var price = 0.0
    @State private var stock = 0
    @State private var description = ""
    
    @State private var isNameEmptyAlertPresented = false
    
    private var integerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0 // Ensures no fractional part
        return formatter
    }
    
    private func addProduct() {
        // withAnimation {
            let newItem = Product(
                timestamp: Date(),
                name: name,
                price: price,
                stock: stock,
                productDescription: description
            )
        
            modelContext.insert(newItem)
        // }
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
                    if !name.isEmpty {
                        addProduct()
                        
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        // Show an alert indicating that the product name is empty
                        isNameEmptyAlertPresented = true
                    }
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
