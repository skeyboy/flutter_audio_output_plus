import AVFoundation
import Flutter

@available(iOS 10.0, *)
public class AudioRouteManager {
    public static let shared = AudioRouteManager()
    private let audioSession = AVAudioSession.sharedInstance()
    private var isAudioSessionConfigured = false
    private let audioEngine = AVAudioEngine()

    private init() {}

    // MARK: - 配置音频会话
    public func configureAudioSession() throws {
      guard !isAudioSessionConfigured else { return }

              do {
                  // 设置音频类别为播放和录制（支持切换输出设备）
                  try audioSession.setCategory(.playAndRecord,
                                               mode: .voiceChat,
                                               options: [.allowBluetoothHFP, .allowBluetoothA2DP,  .allowAirPlay])
                  try audioSession.setActive(true)
                  isAudioSessionConfigured = true

            // 2. 关键步骤：启用音频引擎的语音处理
                        // 这个操作会激活系统的音频路由管理
                        try audioEngine.inputNode.setVoiceProcessingEnabled(true)

                        // 注意：不需要启动 audioEngine，只需启用语音处理
                  print("Audio session configured successfully")
              } catch {
                  print("Failed to configure audio session: \(error.localizedDescription)")
                  throw error
              }
    }

    // MARK: - 切换音频输出
    public func switchToSpeaker() throws {
        try configureAudioSession()
        do {
            try audioSession.setPreferredInput(nil)
            try audioSession.overrideOutputAudioPort(.speaker)
            print("Switched to speaker")
        } catch {
            print("Failed to switch to speaker: \(error.localizedDescription)")
            throw error
        }
    }

    public func switchToEarpiece() throws {
        try configureAudioSession()
        do {


            // 1. 取消扬声器强制覆盖
        try audioSession.overrideOutputAudioPort(.none)

        // 2. 找到内置麦克风 (Built-in Mic) 并设为首选输入
        // 这会强制系统将路由从蓝牙切回手机本体
        let builtInMic = audioSession.availableInputs?.first(where: { $0.portType == .builtInMic })
        try audioSession.setPreferredInput(builtInMic)


            // try audioSession.setPreferredInput(nil)
            // try audioSession.overrideOutputAudioPort(.none)
            print("Switched to earpiece")
        } catch {
            print("Failed to switch to earpiece: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - 获取当前音频路由信息
    public func getCurrentAudioRoute() -> [String: Any] {
        let currentRoute = audioSession.currentRoute
        var outputs: [[String: Any]] = []

        for output in currentRoute.outputs {
            var outputInfo: [String: Any] = [
                "portType": output.portType.rawValue,
                "portName": output.portName,
                "uid": output.uid
            ]

            // 判断输出设备类型
            let deviceType = getDeviceType(from: output.portType)
            outputInfo["deviceType"] = deviceType

            outputs.append(outputInfo)





        }



        let availableOutputs = getAvailableOutputs()

        return [
            "currentOutputs": outputs,
            "availableOutputs": availableOutputs,
            "isSpeakerActive": isSpeakerActive(),
            "isEarpieceActive": isEarpieceActive(),
            "isBluetoothActive": isBluetoothActive(),
            "isHeadphonesActive": isHeadphonesActive()
        ]
    }

    // MARK: - 获取可用输出设备
    public func getAvailableOutputs() -> [[String: Any]] {
        var availableOutputs: [[String: Any]] = []

        // 获取当前音频路由
        let currentRoute = audioSession.currentRoute
        let availableInputs = audioSession.availableInputs ?? []

        // 检查可用的输出端口
        let outputPorts: [AVAudioSession.Port] = [
            .builtInReceiver,    // 听筒
            .builtInSpeaker,     // 扬声器
            .bluetoothA2DP,      // 蓝牙耳机
            .bluetoothHFP,       // 蓝牙免提
            .headphones,         // 有线耳机
            .carAudio,           // 车载音频
            .airPlay             // AirPlay
        ]

        for portType in outputPorts {
            if isPortAvailable(portType) {
                var deviceInfo: [String: Any] = [
                    "portType": portType.rawValue,
                    "deviceType": getDeviceType(from: portType),
                    "isCurrent": isCurrentPort(portType)
                ]

                // 添加设备名称
                if let portDescription = getPortDescription(for: portType) {
                    deviceInfo["portName"] = portDescription.portName
                }

                availableOutputs.append(deviceInfo)
            }
        }


        //        var receiver = [
        //                                 "portType": AVAudioSession.Port.builtInReceiver.rawValue,
        //                                 "portName": "\(AVAudioSession.Port.builtInReceiver.rawValue)听筒",
        //                                 "uid": AVAudioSession.Port.builtInReceiver.rawValue,
        //                             ]
        //  var deviceType = getDeviceType(from:AVAudioSession.Port.builtInReceiver)
        //             receiver["deviceType"] = deviceType

        //              availableOutputs.append(receiver)



        //         var speaker = [
        //                                 "portType": AVAudioSession.Port.builtInSpeaker.rawValue,
        //                                 "portName": "\(AVAudioSession.Port.builtInSpeaker.rawValue)听筒",
        //                                 "uid": AVAudioSession.Port.builtInSpeaker.rawValue,
        //                             ]
        //         deviceType = getDeviceType(from:AVAudioSession.Port.builtInSpeaker)
        //         speaker["deviceType"] = deviceType

        //         availableOutputs.append(speaker)

        return availableOutputs
    }

    // MARK: - 切换到指定设备
    public func switchToDevice(portType: String) throws -> Bool {
        try configureAudioSession()

        // 特殊处理听筒和扬声器
        if portType == AVAudioSession.Port.builtInReceiver.rawValue {
            try switchToEarpiece()
            return true
        } else if portType == AVAudioSession.Port.builtInSpeaker.rawValue {
            try switchToSpeaker()
            return true
        }

        // 对于其他设备（蓝牙、耳机等），需要设置首选输入或输出
        return try switchToExternalDevice(portType: portType)
    }

    // MARK: - 私有辅助方法
     func getDeviceType(from portType: AVAudioSession.Port) -> String {
      portType.rawValue
//         switch portType {
//         case .builtInReceiver:
//             return "earpiece"
//         case .builtInSpeaker:
//             return "speaker"
//         case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
//             return "bluetooth"
//         case .headphones, .headsetMic:
//             return "headphones"
//         case .carAudio:
//             return "car"
//         case .airPlay:
//             return "airplay"
//         default:
//             return "unknown"
//         }
    }

    private func isPortAvailable(_ portType: AVAudioSession.Port) -> Bool {
        let availablePorts = audioSession.availableInputs ?? []
        let currentRoute = audioSession.currentRoute

        // 检查是否为可用输入或当前输出
        let isAvailableInput = availablePorts.contains { $0.portType == portType }
        let isCurrentOutput = currentRoute.outputs.contains { $0.portType == portType }

        return isAvailableInput || isCurrentOutput
    }

    private func isCurrentPort(_ portType: AVAudioSession.Port) -> Bool {
        let currentRoute = audioSession.currentRoute
        return currentRoute.outputs.contains { $0.portType == portType }
    }

    private func isSpeakerActive() -> Bool {
        let currentRoute = audioSession.currentRoute
        return currentRoute.outputs.contains { $0.portType == .builtInSpeaker }
    }

    private func isEarpieceActive() -> Bool {
        let currentRoute = audioSession.currentRoute
        return currentRoute.outputs.contains { $0.portType == .builtInReceiver }
    }

    private func isBluetoothActive() -> Bool {
        let currentRoute = audioSession.currentRoute
        return currentRoute.outputs.contains { port in
            port.portType == .bluetoothA2DP ||
            port.portType == .bluetoothHFP ||
            port.portType == .bluetoothLE
        }
    }

    private func isHeadphonesActive() -> Bool {
        let currentRoute = audioSession.currentRoute
        return currentRoute.outputs.contains {
            $0.portType == .headphones || $0.portType == .headsetMic
        }
    }

    private func getPortDescription(for portType: AVAudioSession.Port) -> AVAudioSessionPortDescription? {
        let availableInputs = audioSession.availableInputs ?? []
        let currentRoute = audioSession.currentRoute

        if let input = availableInputs.first(where: { $0.portType == portType }) {
            return input
        }

        if let output = currentRoute.outputs.first(where: { $0.portType == portType }) {
            return output
        }

        return nil
    }

    private func switchToExternalDevice(portType: String) throws -> Bool {
        // 对于外部设备，尝试设置首选输入
        let availableInputs = audioSession.availableInputs ?? []

        if let targetPort = availableInputs.first(where: { $0.portType.rawValue == portType }) {
            do {
                // 取消扬声器覆盖
            try audioSession.overrideOutputAudioPort(.none)
                try audioSession.setPreferredInput(targetPort)
                return true
            } catch {
                print("Failed to switch to device: \(error.localizedDescription)")
                return false
            }
        }

        return false
    }
}
