import DoomKit
import SwiftUI

extension View {
    func quality(_ quality: ProcessQuality) -> some View {
        self.modifier(QualityCodeViewModifier(qualityCode: quality))
    }
}
