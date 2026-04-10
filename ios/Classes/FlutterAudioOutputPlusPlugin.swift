import Flutter
import UIKit
import AVFoundation

public class FlutterAudioOutputPlusPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_audio_output_plus", binaryMessenger: registrar.messenger())
        let instance = FlutterAudioOutputPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break
        case "getCurrentOutput":
            result(getCurrentOutput())
            break
        case "getAvailableInputs":
            result(getAvailableInputs())
            break
        case "changeToSpeaker":
            result(changeToSpeaker())
            break
        case "changeToReceiver":
            result(changeToReceiver())
            break
        case "changeToHeadphones":
            result(changeToHeadphones())
            break
        case "changeToBluetooth":
            result(changeToBluetooth())
            break
        case "changeOutput":

            let  arguments = call.arguments as? [String: String] ?? [:]

            guard let deviceId = arguments["id"]  as String?, let deviceType = arguments["type"] as String?  else {
                result(false)
                return
            }


            let port = AVAudioSession.Port.init(rawValue: deviceType)

            switch port {
            case  AVAudioSession.Port.builtInReceiver, AVAudioSession.Port.builtInMic:
                result( changeToReceiver())
                break
            case AVAudioSession.Port.builtInSpeaker:
                result( changeToSpeaker())
                break
            case AVAudioSession.Port.headsetMic, AVAudioSession.Port.headphones:
                result( changeToHeadphones())
                break
            case AVAudioSession.Port.bluetoothA2DP, AVAudioSession.Port.bluetoothLE, AVAudioSession.Port.bluetoothHFP:
                result( changeToBluetooth())
                break
            default:
                result(false)
                print("默认操作")
            }


        default:
            result(FlutterMethodNotImplemented)
        }
    }


    func getCurrentOutput() -> [String:String] {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        //        print("hello \(currentRoute.outputs)")
        for output in currentRoute.outputs {
            return getOutputDevice(output);
        }
        return [:];
    }

    func getAvailableInputs() -> [[String:String]] {
        var arr = [[String:String]]()

        if let inputs =   AVAudioSession.sharedInstance().availableInputs?.filter({ input in
            input.portType ==  AVAudioSession.Port.builtInReceiver
            || input.portType ==  AVAudioSession.Port.builtInMic
            || input.portType ==  AVAudioSession.Port.builtInSpeaker
            || input.portType ==  AVAudioSession.Port.headsetMic
            || input.portType ==  AVAudioSession.Port.headphones
            || input.portType ==  AVAudioSession.Port.bluetoothA2DP
            || input.portType ==  AVAudioSession.Port.bluetoothLE
            || input.portType ==  AVAudioSession.Port.bluetoothHFP
        }) {
            for input in inputs {
                arr.append(getOutputDevice(input));
            }
        }
        return arr;
    }


    func getOutputDevice(_ input: AVAudioSessionPortDescription) -> [String:String] {
        ["type": "\(input.portType.rawValue )", "label": input.portName, "id":  input.uid]
    }

    func getInfo(_ input: AVAudioSessionPortDescription) -> [String] {
        //        print(input.portType)
        var type = "0";
        let port = AVAudioSession.Port.self;
        switch input.portType {
        case port.builtInReceiver, port.builtInMic:
            type = "1";
            break;
        case port.builtInSpeaker:
            type = "2";
            break;
        case port.headsetMic, port.headphones:
            type = "3";
            break;
        case port.bluetoothA2DP, port.bluetoothLE, port.bluetoothHFP:
            type = "4";
            break;
        default:
            type = "0";
        }
        return [input.portName, type];
    }

    func changeToSpeaker() -> Bool {
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            return true
        } catch {
            print("Error changing to speaker: \(error)")
            return false
        }
    }

    func changeToReceiver() -> Bool {
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
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
        let arr = [AVAudioSession.Port.bluetoothLE, AVAudioSession.Port.bluetoothHFP, AVAudioSession.Port.bluetoothA2DP];
        return changeByPortType(arr)
    }

    func changeByPortType(_ ports: [AVAudioSession.Port]) -> Bool {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            if (ports.firstIndex(of: output.portType) != nil) {
                return true;
            }
        }
        if let inputs = AVAudioSession.sharedInstance().availableInputs {
            for input in inputs {
                if (ports.firstIndex(of: input.portType) != nil) {
                    try? AVAudioSession.sharedInstance().setPreferredInput(input);
                    return true;
                }
            }
        }
        return false;
    }

    public override init() {
        super.init()
        setupAudioSession()
        registerAudioRouteChangeBlock()
    }

    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }

    func registerAudioRouteChangeBlock() {
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance(), queue: nil) {
            [weak self] notification in
            guard let self = self,
            let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
            }
            print("registerAudioRouteChangeBlock \(reason)")
            self.channel?.invokeMethod("inputChanged", arguments: 1)
        }
    }
}
