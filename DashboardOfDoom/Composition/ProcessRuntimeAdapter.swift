import DoomKit
import Foundation

enum ProcessRuntimeAdapter {
    static func makeDependencies() -> ProcessRuntimeDependencies {
        return ProcessRuntimeDependencies(
            waitUntilReady: {
                await NetworkManager.shared.startMonitoring()
                for _ in 0 ..< 30 {
                    if await NetworkManager.shared.isConnected == true {
                        return
                    }
                    try? await Task.sleep(for: .seconds(1))
                }
            },
            logger: ProcessLogger(
                debug: { message in
                    trace.debug("%@", message)
                },
                info: { message in
                    trace.info("%@", message)
                },
                warning: { message in
                    trace.warning("%@", message)
                },
                error: { message in
                    trace.error("%@", message)
                }
            )
        )
    }
}
