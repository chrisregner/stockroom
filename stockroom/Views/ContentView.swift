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
            return products.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationStack {
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
                        // TODO: this is not having the intended effect
                        // of hiding red buttons on lists on list mode
                        .onDelete(perform: editMode == .active ? nil : handleDelete)
                        .deleteDisabled(editMode == .active)
                    }
                }
                
                FloatingAddButton()
            }
            .navigationBarTitle("Stockroom")
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
}
