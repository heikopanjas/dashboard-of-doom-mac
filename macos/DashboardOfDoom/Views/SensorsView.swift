import SwiftUI

/// Combines the three physical-sensor categories (water level, radiation, particulate
/// matter) into one scrolling tab. Each section keeps its own placemark/last-update
/// header because these sensors can each sit at a different location.
struct SensorsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LevelView()
                Divider()
                RadiationView()
                Divider()
                ParticleView()
            }
        }
    }
}
