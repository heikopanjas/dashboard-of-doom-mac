import DoomKit
import SwiftUI

extension SurveyPresenter {
    func gradient(selector: ProcessSelector) -> LinearGradient {
        switch selector {
            case .survey(.fascists):
                return Gradient.fascists
            case .survey(.afd):
                return Gradient.fascists
            case .survey(.bsw):
                return Gradient.clowns
            case .survey(.clowns):
                return Gradient.clowns
            case .survey(.fdp):
                return Gradient.clowns
            case .survey(.freie_waehler):
                return Gradient.clowns
            case .survey(.cducsu):
                return Gradient.fascists
            case .survey(.cdu):
                return Gradient.fascists
            case .survey(.csu):
                return Gradient.fascists
            case .survey(.spd):
                return Gradient.spd
            case .survey(.gruene):
                return Gradient.gruene
            case .survey(.linke):
                return Gradient.linke
            case .survey(.sonstige):
                return Gradient.sonstige
            default:
                return Gradient.linear
        }
    }
}
