import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var plateNumber = ""
    @Published var selectedSymbol: String?
    @Published var isLoading = false
    @Published var results: [PlateEntry] = []
    @Published var resultCount = 0
    @Published var errorMessage: String?

    private let service = SearchService()

    func search() {
        let trimmed = plateNumber.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a plate number"
            return
        }
        errorMessage = nil
        isLoading = true
        results = []

        Task {
            let result = await service.search(plateNumber: trimmed, symbol: selectedSymbol)
            isLoading = false
            if let err = result.error {
                errorMessage = err
            } else {
                results = result.entries
                resultCount = result.count
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var vm = SearchViewModel()
    @FocusState private var plateFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                titleSection
                searchCard
                if let err = vm.errorMessage {
                    Text(err)
                        .font(.subheadline)
                        .foregroundColor(.appError)
                        .multilineTextAlignment(.center)
                }
                if !vm.results.isEmpty {
                    resultsSection
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.appBackground)
        .onTapGesture { plateFocused = false }
    }

    private var titleSection: some View {
        VStack(spacing: 4) {
            Text("CarPlate Lebanon")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appOnSurface)
                .padding(.top, 24)
            Text("تفييش السيارات لبنان")
                .font(.subheadline)
                .foregroundColor(.appTextMuted)
        }
    }

    private var searchCard: some View {
        VStack(spacing: 12) {
            TextField("Plate Number", text: $vm.plateNumber)
                .keyboardType(.numberPad)
                .focused($plateFocused)
                .font(.system(size: 18))
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appBorderColor, lineWidth: 1)
                )
                .onSubmit { vm.search() }

            VStack(alignment: .leading, spacing: 6) {
                Text("Symbol (optional)")
                    .font(.caption)
                    .foregroundColor(.appTextMuted)
                SymbolChips(selected: $vm.selectedSymbol)
            }

            Button(action: vm.search) {
                ZStack {
                    if vm.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Search").font(.system(size: 16))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.appPrimary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(vm.isLoading)
        }
        .padding(20)
        .background(Color.appCardBg)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Found \(vm.resultCount) result(s)")
                .font(.subheadline)
                .foregroundColor(.appTextMuted)
            ForEach(vm.results) { entry in
                ResultCardView(entry: entry)
            }
        }
    }
}

struct SymbolChips: View {
    @Binding var selected: String?

    let symbols: [(value: String, label: String)] = [
        ("", "All"), ("--", "--"), ("*", "*"), ("#", "#"),
        ("A", "A"), ("AG", "AG"), ("AP", "AP"), ("B", "B"),
        ("C", "C"), ("C1", "C1"), ("D", "D"), ("G", "G"),
        ("J", "J"), ("M", "M"), ("MP", "MP"), ("N", "N"),
        ("O", "O"), ("P", "P"), ("R", "R"), ("S", "S"),
        ("T", "T"), ("Y", "Y"), ("Z", "Z"),
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(symbols, id: \.value) { sym in
                let isSelected = selected == (sym.value.isEmpty ? nil : sym.value)
                Button {
                    selected = sym.value.isEmpty ? nil : sym.value
                } label: {
                    Text(sym.label)
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(isSelected ? Color.appPrimary : Color.appOnSurface.opacity(0.08))
                        .foregroundColor(isSelected ? .white : Color.appTextMuted)
                        .cornerRadius(6)
                }
            }
        }
    }
}
