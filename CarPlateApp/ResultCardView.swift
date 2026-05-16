import SwiftUI

struct ResultCardView: View {
    let entry: PlateEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            Divider().padding(.vertical, 10)
            infoGrid
            if entry.hasOwnerInfo {
                Divider().padding(.vertical, 10)
                ownerSection
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorderColor, lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack(spacing: 12) {
            Text(entry.symbol.isEmpty ? "-" : entry.symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.appPrimary)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.plateNumber)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appOnSurface)
                Text(entry.carModel)
                    .font(.system(size: 13))
                    .foregroundColor(.appTextMuted)
            }

            Spacer()

            Text(entry.year)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.appTextMuted)
        }
    }

    private var infoGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
            infoRow("Color:", entry.color)
            infoRow("Usage:", entry.usage)
            infoRow("Chassis:", entry.chassis)
            infoRow("Engine:", entry.engine)
        }
    }

    private func infoRow(_ label: String, _ value: String) -> GridRow {
        GridRow {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.appTextMuted)
            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 12))
                .foregroundColor(.appOnSurface)
                .gridColumnAlignment(.leading)
        }
    }

    private var ownerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Owner Info")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.appPrimary)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
                infoRow("Name:", entry.ownerName)
                if !entry.motherName.isEmpty {
                    infoRow("Mother:", entry.motherName)
                }
                infoRow("Phone:", entry.phone)
                infoRow("Address:", entry.address)
                infoRow("Acquired:", entry.acquisition)
                GridRow {
                    Text("Status:")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextMuted)
                    Text(entry.statusText)
                        .font(.system(size: 12))
                        .foregroundColor(entry.statusColor)
                        .gridColumnAlignment(.leading)
                }
            }
        }
    }
}
