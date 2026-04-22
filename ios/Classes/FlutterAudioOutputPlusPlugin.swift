import AVFoundation
import Flutter
import UIKit

public class FlutterAudioOutputPlusPlugin: NSObject, FlutterPlugin {

    private let audioRouteManager = AudioRouteManager.shared

    var channel: FlutterMethodChannel?
//    static let session = AVAudioSession.sharedInstance()
    public static func register(with registrar: FlutterPluginRegistrar) {

        let channel = FlutterMethodChannel(
            name: "flutter_audio_output_plus", binaryMessenger: registrar.messenger())
        let instance = FlutterAudioOutputPlusPlugin()
        // 关键修复：将 channel 赋值给实例，否则路由变更通知无法回调 Flutter
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    
//        switch call.method {
//        case "getPlatformVersion":
//            result("iOS " + UIDevice.current.systemVersion)
//            break
//
//                   case "configureAudioSession":
//                            do {
//                                try audioRouteManager.configureAudioSession()
//                                result(nil)
//                            } catch {
//                                result(FlutterError(code: "CONFIG_ERROR", message: error.localizedDescription, details: nil))
//                            }
//        case "getCurrentOutput":
//            result(getCurrentOutput())
//            break
//        case "getAvailableInputs":
//            result(getAvailableInputs())
//            break
//        case "changeToSpeaker":
//            result(changeToSpeaker())
//            break
//        case "changeToReceiver":
//            result(changeToReceiver())
//            break
//        case "changeToHeadphones":
//            result(changeToHeadphones())
//            break
//        case "changeToBluetooth":
//            result(changeToBluetooth())
//            break
//        case "changeOutput":
//
//            let arguments = call.arguments as? [String: String] ?? [:]
//            print("changeOutput arguments: \(arguments)")
//
//            guard let deviceId = arguments["id"] as String?,
//                let deviceType = arguments["type"] as String?
//            else {
//                result(false)
//                return
//            }
//
//            let port = AVAudioSession.Port.init(rawValue: deviceType)
//            print("changeOutput arguments to port: \(port) deviceType \(deviceType)")
//
//
//  do {
//                    let success = try audioRouteManager.switchToDevice(portType: deviceType)
//                    result(success)
//                } catch {
//                    result(FlutterError(code: "SWITCH_ERROR", message: error.localizedDescription, details: nil))
//                }
//
////
////             switch port {
////             case AVAudioSession.Port.builtInReceiver, AVAudioSession.Port.builtInMic:
////                 result(changeToReceiver())
////                 break
////             case AVAudioSession.Port.builtInSpeaker:
////                 result(changeToSpeaker())
////                 break
////             case AVAudioSession.Port.headsetMic, AVAudioSession.Port.headphones:
////                 result(changeToHeadphones())
////                 break
////             case AVAudioSession.Port.bluetoothA2DP, AVAudioSession.Port.bluetoothLE,
////                 AVAudioSession.Port.bluetoothHFP:
////                 result(changeToBluetooth())
////                 break
////             default:
////                 result(false)
////                 print("默认操作")
////             }
//
//        default:
//            result(FlutterMethodNotImplemented)
//        }
    }

    func getCurrentOutput() -> [String: String] {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        //        print("hello \(currentRoute.outputs)")
        for output in currentRoute.outputs {
            return getOutputDevice(output)
        }
        return [:]
    }

    func getAvailableInputs() -> [[String: String]] {
        var arr = [[String: String]]()
        var seenTypes = Set<String>()

        // 辅助：去重追加
        func appendIfNew(_ device: [String: String]) {
            guard let type_ = device["type"] else { return }
            if seenTypes.insert(type_).inserted {
                arr.append(device)
            }
        }

        // 1. 内置听筒（Receiver）— 始终存在于 iPhone
        appendIfNew([
            "type": AVAudioSession.Port.builtInReceiver.rawValue,
            "label": "\(AVAudioSession.Port.builtInReceiver.rawValue)听筒",
            "id": AVAudioSession.Port.builtInReceiver.rawValue,
        ])

        // 2. 内置扬声器（Speaker）— 始终存在于 iPhone，但不在 availableInputs 中
        appendIfNew([
            "type": AVAudioSession.Port.builtInSpeaker.rawValue,
            "label": "\(AVAudioSession.Port.builtInSpeaker.rawValue)扬声器",
            "id": AVAudioSession.Port.builtInSpeaker.rawValue,
        ])

        // 3. 当前路由中的输出设备（蓝牙/耳机等激活时会出现在这里）
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            appendIfNew(getOutputDevice(output))
        }

        // 4. 其余可用输入设备（耳机麦克风、蓝牙 HFP 等）
        if let inputs = AVAudioSession.sharedInstance().availableInputs {
            for input in inputs {
                // 跳过纯麦克风，避免重复出现 builtInMic
                guard input.portType != .builtInMic else { continue }
                appendIfNew(getOutputDevice(input))
            }
        }

        return arr
    }

    func getOutputDevice(_ input: AVAudioSessionPortDescription) -> [String: String] {
        ["type": "\(input.portType.rawValue )", "label": input.portName, "id": input.uid]
    }

    func getInfo(_ input: AVAudioSessionPortDescription) -> [String] {
        //        print(input.portType)
        var type = "0"
        let port = AVAudioSession.Port.self
        switch input.portType {
        case port.builtInReceiver, port.builtInMic:
            type = "1"
            break
        case port.builtInSpeaker:
            type = "2"
            break
        case port.headsetMic, port.headphones:
            type = "3"
            break
        case port.bluetoothA2DP, port.bluetoothLE, port.bluetoothHFP:
            type = "4"
            break
        default:
            type = "0"
        }
        return [input.portName, type]
    }

    func changeToSpeaker() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .voiceChat, options: [])
                // 强制覆盖输出到扬声器
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                try AVAudioSession.sharedInstance().setActive(true)
            return true
        } catch {
            print("Error changing to speaker: \(error)")
            return false
        }
    }

    func changeToReceiver() -> Bool {
        do {
//            let session = AVAudioSession.sharedInstance()
//            // 第一步：取消扬声器强制覆盖
//            try session.overrideOutputAudioPort(.none)
//            // 第二步：setPreferredInput(builtInMic) 强制走听筒路径。
//            // 注意：这里刻意不调用 setActive(true)。
//            // setActive 会中断 WebView 的音频，导致恢复后重连到系统默认路由，
//            // 使 override 失效。setPreferredInput 本身不会触发中断通知，可以安全调用。
//            if let builtInMic = session.availableInputs?.first(where: {
//                $0.portType == .builtInMic
//            }) {
//                try session.setPreferredInput(builtInMic)
//            }
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none) // 恢复默认（即听筒）
            return true
        } catch {
            print("Error changing to receiver: \(error)")
            return false
        }
    }

    func changeToHeadphones() -> Bool {
        return changeByPortType([AVAudioSession.Port.headsetMic])
    }

    func changeToBluetooth() -> Bool {
        let arr = [
            AVAudioSession.Port.bluetoothLE, AVAudioSession.Port.bluetoothHFP,
            AVAudioSession.Port.bluetoothA2DP,
        ]
        return changeByPortType(arr)
    }

    func changeByPortType(_ ports: [AVAudioSession.Port]) -> Bool {
        
        
        let session = AVAudioSession.sharedInstance()
            
            // 1. 找到你想切换到的蓝牙端口
            let bluetoothPort = session.availableInputs?.first(where: {
                $0.portType == .bluetoothHFP || $0.portType == .bluetoothA2DP
            })
            
            // 2. 设置为首选输入
            do {
                try session.setPreferredInput(bluetoothPort)
                return true
            } catch {
                print("指定蓝牙设备失败: \(error)")
            }
        
        
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            if ports.firstIndex(of: output.portType) != nil {
                return true
            }
        }
        if let inputs = AVAudioSession.sharedInstance().availableInputs {
            for input in inputs {
                if ports.firstIndex(of: input.portType) != nil {
                    try? AVAudioSession.sharedInstance().setPreferredInput(input)
                    return true
                }
            }
        }
        return false
    }

    public override init() {
        super.init()
        setupAudioSession()
        registerAudioRouteChangeBlock()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // allowBluetoothA2DP + allowBluetooth 保证蓝牙设备可见
            // defaultToSpeaker 不加，由业务层自行控制输出
            try audioSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.allowBluetooth, .allowBluetoothA2DP, .allowAirPlay]
            )
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }

    func registerAudioRouteChangeBlock() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else { return }

        print("[AudioRoute] route changed, reason: \(reason.rawValue)")

        // 在主线程回调 Flutter，避免跨线程问题
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("inputChanged", arguments: 1)
        }
    }
}
