import Foundation

/// Manages completion state for network connection waiting.
///
/// Prevents race conditions when multiple concurrent tasks await connectivity:
/// only the first caller of ``tryComplete()`` receives `true`, so exactly one
/// task resumes the shared continuation and duplicate resumptions are avoided.
actor ConnectionWaiter {
    private var isCompleted = false

    /// Atomically claims completion.
    /// - Returns: `true` for the first caller, `false` once already claimed.
    func tryComplete() -> Bool {
        guard isCompleted == false else {
            return false
        }
        isCompleted = true
        return true
    }
}
