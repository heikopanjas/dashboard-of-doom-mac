import AppKit
import DoomKit
import SwiftUI

@main
struct DashboardOfDoomApp: App {
    @State var weatherViewModel = AppFactories.makeWeatherPresenter()
    @State var forecastPresenter = AppFactories.makeForecastPresenter()
    @State var covidPresenter = AppFactories.makeCovidPresenter()
    @State var levelPresenter = AppFactories.makeLevelPresenter()
    @State var radiationPresenter = AppFactories.makeRadiationPresenter()
    @State var particlePresenter = AppFactories.makeParticlePresenter()
    @State var surveyPresenter = AppFactories.makeSurveyPresenter()
    @State var colorPresenter = ColorPresenter()
    @State var hazardPresenter = AppFactories.makeHazardPresenter()
    @State var pointOfInterestPresenter = AppFactories.makePointOfInterestPresenter()

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(weatherViewModel)
                .environment(forecastPresenter)
                .environment(covidPresenter)
                .environment(levelPresenter)
                .environment(radiationPresenter)
                .environment(particlePresenter)
                .environment(surveyPresenter)
                .environment(colorPresenter)
                .environment(hazardPresenter)
                .environment(pointOfInterestPresenter)
                .environment(appDelegate)
                .onAppear {
                    appDelegate.levelPresenter = levelPresenter
                    appDelegate.particlePresenter = particlePresenter
                    appDelegate.surveyPresenter = surveyPresenter

                    AppProcessControl.shared.configure(
                        hazardPresenter: hazardPresenter,
                        pointOfInterestPresenter: pointOfInterestPresenter
                    )
                    AppProcessControl.shared.start()

                    Task {
                        await AppProcessControl.shared.registerProcessPresenters(
                            AppFactories.processPresenterRegistrations(
                                weather: weatherViewModel,
                                forecast: forecastPresenter,
                                covid: covidPresenter,
                                level: levelPresenter,
                                radiation: radiationPresenter,
                                particle: particlePresenter,
                                survey: surveyPresenter
                            )
                        )
                    }
                }
        } label: {
            Text(weatherViewModel.faceplate[.weather(.temperature)] ?? "n/a")
                .font(.system(.body, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }
}
