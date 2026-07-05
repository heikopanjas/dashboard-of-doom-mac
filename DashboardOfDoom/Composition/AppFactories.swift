import DoomKit
import Foundation

@MainActor
enum AppFactories {
    private static func logProcessError(_ message: String) {
        trace.error("%@", message)
    }

    private static func makeFetchSensor(
        controller: any ProcessControllerProtocol
    ) -> @Sendable (Location) async throws -> ProcessSensor? {
        return { location in
            try await controller.refreshData(for: location).first
        }
    }

    private static func makeRenderSnapshot(
        transformer: any ProcessTransformerProtocol
    ) -> @Sendable (ProcessSensor) throws -> ProcessPresentationSnapshot {
        return { sensor in
            try transformer.render(sensor: sensor)
        }
    }

    private static func mapPublishHandler(defaultsKey: String?) -> @Sendable (UUID, Location?) -> Void {
        return { id, location in
            Task { @MainActor in
                guard let location else {
                    return
                }
                if let defaultsKey {
                    if UserDefaults.standard.bool(forKey: defaultsKey) {
                        MapPresenter.shared.updateRegion(for: id, with: location)
                    }
                    else {
                        MapPresenter.shared.updateRegion(remove: id)
                    }
                }
                else {
                    MapPresenter.shared.updateRegion(for: id, with: location)
                }
            }
        }
    }

    static func makeWeatherPresenter() -> WeatherPresenter {
        let controller = WeatherController()
        let transformer = WeatherTransformer()
        return WeatherPresenter(
            fetchSensor: makeFetchSensor(controller: controller),
            renderSnapshot: makeRenderSnapshot(transformer: transformer),
            logError: logProcessError,
            onSensorPublished: mapPublishHandler(defaultsKey: nil)
        )
    }

    static func makeForecastPresenter() -> ForecastPresenter {
        let controller = ForecastController()
        let transformer = ForecastTransformer()
        return ForecastPresenter(
            fetchSensor: makeFetchSensor(controller: controller),
            renderSnapshot: makeRenderSnapshot(transformer: transformer),
            logError: logProcessError
        )
    }

    static func makeCovidPresenter() -> CovidPresenter {
        let controller = CovidController()
        let transformer = CovidTransformer()
        return CovidPresenter(
            fetchSensor: makeFetchSensor(controller: controller),
            renderSnapshot: makeRenderSnapshot(transformer: transformer),
            logError: logProcessError,
            onSensorPublished: mapPublishHandler(defaultsKey: "showCovid")
        )
    }

    static func makeLevelPresenter() -> LevelPresenter {
        let controller = LevelController()
        let transformer = LevelTransformer()
        return LevelPresenter(
            fetchSensor: makeFetchSensor(controller: controller),
            renderSnapshot: makeRenderSnapshot(transformer: transformer),
            logError: logProcessError,
            onSensorPublished: mapPublishHandler(defaultsKey: "showLevels")
        )
    }

    static func makeRadiationPresenter() -> RadiationPresenter {
        let controller = RadiationController()
        let transformer = RadiationTransformer()
        return RadiationPresenter(
            fetchSensor: makeFetchSensor(controller: controller),
            renderSnapshot: makeRenderSnapshot(transformer: transformer),
            logError: logProcessError,
            onSensorPublished: mapPublishHandler(defaultsKey: "showRadiation")
        )
    }

    static func makeParticlePresenter() -> ParticlePresenter {
        let controller = ParticleController()
        let transformer = ParticleTransformer()
        return ParticlePresenter(
            fetchSensor: makeFetchSensor(controller: controller),
            renderSnapshot: makeRenderSnapshot(transformer: transformer),
            logError: logProcessError,
            onSensorPublished: mapPublishHandler(defaultsKey: "showParticles")
        )
    }

    static func makeSurveyPresenter() -> SurveyPresenter {
        let controller = SurveyController()
        let transformer = SurveyTransformer()
        return SurveyPresenter(
            fetchSensor: makeFetchSensor(controller: controller),
            renderSnapshot: makeRenderSnapshot(transformer: transformer),
            logError: logProcessError,
            onSensorPublished: mapPublishHandler(defaultsKey: "showElectionPolls")
        )
    }

    static func makeHazardPresenter() -> HazardPresenter {
        let controller = HazardController()
        return HazardPresenter(fetchHazards: { location in
            return await controller.fetchHazards(location: location)
        })
    }

    static func makePointOfInterestPresenter() -> PointOfInterestPresenter {
        let controller = PointOfInterestController()
        return PointOfInterestPresenter(
            fetchPharmacies: { location in
                return await controller.fetchPharmacies(location: location)
            },
            fetchHospitals: { location in
                return await controller.fetchHospitals(location: location)
            },
            fetchLiquorStores: { location in
                return await controller.fetchLiquorStores(location: location)
            },
            fetchFuneralDirectors: { location in
                return await controller.fetchFuneralDirectors(location: location)
            },
            fetchCemeteries: { location in
                return await controller.fetchCemeteries(location: location)
            }
        )
    }

    static func processPresenterRegistrations(
        weather: WeatherPresenter,
        forecast: ForecastPresenter,
        covid: CovidPresenter,
        level: LevelPresenter,
        radiation: RadiationPresenter,
        particle: ParticlePresenter,
        survey: SurveyPresenter
    ) -> [ProcessPresenterRegistration] {
        return [
            ProcessPresenterRegistration(
                presenter: weather,
                refreshIntervalKey: "weatherRefreshInterval",
                defaultMinutes: 5
            ),
            ProcessPresenterRegistration(
                presenter: forecast,
                refreshIntervalKey: "weatherRefreshInterval",
                defaultMinutes: 5
            ),
            ProcessPresenterRegistration(
                presenter: covid,
                refreshIntervalKey: "covidRefreshInterval",
                defaultMinutes: 360
            ),
            ProcessPresenterRegistration(
                presenter: level,
                refreshIntervalKey: "levelRefreshInterval",
                defaultMinutes: 15
            ),
            ProcessPresenterRegistration(
                presenter: radiation,
                refreshIntervalKey: "radiationRefreshInterval",
                defaultMinutes: 15
            ),
            ProcessPresenterRegistration(
                presenter: particle,
                refreshIntervalKey: "particleRefreshInterval",
                defaultMinutes: 30
            ),
            ProcessPresenterRegistration(
                presenter: survey,
                refreshIntervalKey: "surveyRefreshInterval",
                defaultMinutes: 360
            )
        ]
    }
}
