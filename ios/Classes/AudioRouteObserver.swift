import AVFoundation
import Flutter

@available(iOS 10.0, *)
public class AudioRouteObserver {
    public static let shared = AudioRouteObserver()
    private let audioSession = AVAudioSession.sharedInstance()
    private var eventSink: FlutterEventSink?

    private init() {
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleRouteChange(notification: Notification) {
        guard let eventSink = eventSink else { return }

        guard let reasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        let routeInfo = AudioRouteManager.shared.getCurrentAudioRoute()
        var eventData: [String: Any] = [
            "type": "routeChange",
            "reason": routeChangeReasonToString(reason),
            "routeInfo": routeInfo
        ]

        // 添加旧路由信息
        if let previousRoute = notification.userInfo?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
            var oldOutputs: [[String: Any]] = []
            for output in previousRoute.outputs {
                oldOutputs.append([
                    "portType": output.portType.rawValue,
                    "portName": output.portName,
                    "deviceType": AudioRouteManager.shared.getDeviceType(from: output.portType)
                ])
            }
            eventData["previousRoute"] = oldOutputs
        }

        eventSink(eventData)
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let eventSink = eventSink else { return }

        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        var eventData: [String: Any] = [
            "type": "interruption",
            "interruptionType": type == .began ? "began" : "ended"
        ]

        if type == .ended {
            if let optionValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionValue)
                eventData["shouldResume"] = options.contains(.shouldResume)
            }
        }

        eventSink(eventData)
    }

    public func setEventSink(_ sink: FlutterEventSink?) {
        eventSink = sink
    }

    private func routeChangeReasonToString(_ reason: AVAudioSession.RouteChangeReason) -> String {
        switch reason {
        case .unknown:
            return "unknown"
        case .newDeviceAvailable:
            return "newDeviceAvailable"
        case .oldDeviceUnavailable:
            return "oldDeviceUnavailable"
        case .categoryChange:
            return "categoryChange"
        case .override:
            return "override"
        case .wakeFromSleep:
            return "wakeFromSleep"
        case .noSuitableRouteForCategory:
            return "noSuitableRouteForCategory"
        case .routeConfigurationChange:
            return "routeConfigurationChange"
        @unknown default:
            return "unknown"
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}