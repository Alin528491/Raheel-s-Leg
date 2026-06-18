import Combine
import CoreBluetooth
import Foundation

enum SensorPlacement: String, CaseIterable, Identifiable {
    case shin
    case thigh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shin: "KP1 Shin"
        case .thigh: "KP1 Thigh"
        }
    }

    var subtitle: String {
        switch self {
        case .shin: "Shin Sensor"
        case .thigh: "Thigh Sensor"
        }
    }

    var serviceName: String {
        switch self {
        case .shin: "SHIN"
        case .thigh: "THIGH"
        }
    }
}

struct SensorDevice: Identifiable, Equatable {
    let id: UUID
    let name: String
    let placement: SensorPlacement
    let rssi: Int
    let isConnected: Bool

    var signalPercent: Int {
        min(100, max(5, 100 + rssi))
    }

    var shortID: String {
        String(id.uuidString.prefix(8))
    }
}

@MainActor
final class AngleService: NSObject, ObservableObject {
    @Published var angle: Double = 0
    @Published var isConnected = false
    @Published var thighConnected = false
    @Published var shinConnected = false
    @Published private(set) var thighReceivingData = false
    @Published private(set) var shinReceivingData = false
    @Published var isStreaming = false
    @Published var isCalibrating = false
    @Published var calibrationRemainingSeconds = 0.0
    @Published private(set) var calibrationError: String?
    @Published var statusText = "Idle"
    @Published private(set) var availableDevices: [SensorDevice] = []

    private enum Segment: String {
        case thigh = "THIGH"
        case shin = "SHIN"

        var placement: SensorPlacement {
            switch self {
            case .thigh: .thigh
            case .shin: .shin
            }
        }
    }

    private struct DiscoveredSensor {
        let peripheral: CBPeripheral
        let segment: Segment
        var name: String
        var rssi: Int
    }

    private struct Quaternion {
        let x: Double
        let y: Double
        let z: Double
        let w: Double
    }

    private let thighServiceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    private let shinServiceUUID = CBUUID(string: "4fafc202-1fb5-459e-8fcc-c5c9c331914b")
    private let primaryCharacteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")

    private var central: CBCentralManager?
    private var peripherals: [Segment: CBPeripheral] = [:]
    private var segmentByPeripheralID: [UUID: Segment] = [:]
    private var discoveredSensors: [UUID: DiscoveredSensor] = [:]
    private var latestQuaternion: [Segment: Quaternion] = [:]
    private var lastQuaternionDate: [Segment: Date] = [:]
    private let processor = AngleBridge()
    private var streamStartDate: Date?
    private var calibrationWatchdog: Task<Void, Never>?
    private var isAngleSessionActive = false
    private let packetFreshnessInterval: TimeInterval = 1.0

    func connectPlaceholderSensors() {
        start()
    }

    func start() {
        statusText = "Starting Bluetooth"
        isStreaming = true
        if central == nil {
            central = CBCentralManager(delegate: self, queue: .main)
        } else if central?.state == .poweredOn {
            scan()
        }
    }

    func stop() {
        statusText = "Stopped"
        isStreaming = false
        central?.stopScan()
        for peripheral in peripherals.values {
            central?.cancelPeripheralConnection(peripheral)
        }
        peripherals.removeAll()
        segmentByPeripheralID.removeAll()
        discoveredSensors.removeAll()
        availableDevices.removeAll()
        latestQuaternion.removeAll()
        lastQuaternionDate.removeAll()
        isConnected = false
        thighConnected = false
        shinConnected = false
        thighReceivingData = false
        shinReceivingData = false
        isCalibrating = false
        calibrationRemainingSeconds = 0
        calibrationError = nil
        calibrationWatchdog?.cancel()
        calibrationWatchdog = nil
        isAngleSessionActive = false
        processor.resetCalibration()
        streamStartDate = nil
    }

    @discardableResult
    func beginCalibration() -> Bool {
        guard isConnected else {
            failCalibration("Connect both sensors before calibration.")
            return false
        }

        updateDataFreshness()
        if let message = sensorDataErrorMessage {
            failCalibration(message)
            return false
        }

        calibrationWatchdog?.cancel()
        calibrationError = nil
        streamStartDate = Date()
        processor.resetCalibration()
        angle = 0
        isAngleSessionActive = true
        isCalibrating = true
        calibrationRemainingSeconds = 3
        statusText = "Hold your starting position"
        startCalibrationWatchdog()
        return true
    }

    private func scan() {
        guard let central else { return }
        statusText = "Searching for sensors"
        isStreaming = true
        central.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }

    func connect(to deviceID: UUID) {
        guard let sensor = discoveredSensors[deviceID] else {
            statusText = "Sensor not found"
            return
        }

        guard let central else {
            statusText = "Starting Bluetooth"
            start()
            return
        }

        if central.state != .poweredOn {
            statusText = "Bluetooth unavailable"
            return
        }

        let peripheral = sensor.peripheral
        peripheral.delegate = self
        peripherals[sensor.segment] = peripheral
        segmentByPeripheralID[peripheral.identifier] = sensor.segment

        switch peripheral.state {
        case .connected:
            statusText = "\(sensor.segment.placement.title) connected"
            updateConnectionState()
            peripheral.discoverServices(nil)
        case .connecting:
            statusText = "Connecting \(sensor.segment.placement.title)"
        default:
            statusText = "Connecting \(sensor.segment.placement.title)"
            central.connect(peripheral)
        }
    }

    private func classify(name: String?, advertisementData: [String: Any]) -> Segment? {
        let advertisedServices = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []
        let localName = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? name ?? ""
        let loweredName = localName.lowercased()

        let isThigh = advertisedServices.contains(thighServiceUUID)
            || loweredName.contains("thigh")
            || loweredName.contains("node")
        let isShin = advertisedServices.contains(shinServiceUUID)
            || loweredName.contains("shin")

        if isThigh && !isShin {
            return .thigh
        }
        if isShin && !isThigh {
            return .shin
        }
        return nil
    }

    private func updateConnectionState() {
        thighConnected = peripherals[.thigh]?.state == .connected
        shinConnected = peripherals[.shin]?.state == .connected
        isConnected = thighConnected && shinConnected
        if isConnected {
            statusText = "Connected"
            central?.stopScan()
        } else if thighConnected || shinConnected {
            statusText = "Connect remaining sensor"
        }
        updateAvailableDevices()
    }

    private func updateAvailableDevices() {
        availableDevices = discoveredSensors.values
            .map { sensor in
                SensorDevice(
                    id: sensor.peripheral.identifier,
                    name: sensor.name,
                    placement: sensor.segment.placement,
                    rssi: sensor.rssi,
                    isConnected: peripherals[sensor.segment]?.identifier == sensor.peripheral.identifier
                        && sensor.peripheral.state == .connected
                )
            }
            .sorted { left, right in
                if left.placement != right.placement {
                    return left.placement == .shin
                }
                return left.name.localizedCaseInsensitiveCompare(right.name) == .orderedAscending
            }
    }

    private func handleQuaternion(_ quaternion: Quaternion, segment: Segment) {
        let now = Date()
        latestQuaternion[segment] = quaternion
        lastQuaternionDate[segment] = now
        updateDataFreshness(now: now)

        guard let thigh = latestQuaternion[.thigh],
              let shin = latestQuaternion[.shin] else {
            statusText = "Waiting for both sensors"
            return
        }

        guard thighReceivingData, shinReceivingData else { return }
        guard isAngleSessionActive, let streamStartDate else {
            statusText = "Sensors transmitting"
            return
        }

        let timestamp = now.timeIntervalSince(streamStartDate)
        let result = processor.process(
            thighX: thigh.x,
            thighY: thigh.y,
            thighZ: thigh.z,
            thighW: thigh.w,
            shinX: shin.x,
            shinY: shin.y,
            shinZ: shin.z,
            shinW: shin.w,
            timestampSeconds: timestamp
        )

        angle = result.flexionDegrees
        isCalibrating = result.isCalibrating
        calibrationRemainingSeconds = result.calibrationRemainingSeconds
        if result.isCalibrating {
            statusText = String(format: "Hold still: %.1fs", result.calibrationRemainingSeconds)
        } else {
            calibrationWatchdog?.cancel()
            calibrationWatchdog = nil
            statusText = result.motionRejected ? "Live angle - side motion rejected" : "Live angle"
        }
    }

    private var sensorDataErrorMessage: String? {
        if !thighReceivingData && !shinReceivingData {
            return "KP1 Thigh and KP1 Shin are connected but not sending motion data."
        }
        if !thighReceivingData {
            return "KP1 Thigh is connected but not sending motion data."
        }
        if !shinReceivingData {
            return "KP1 Shin is connected but not sending motion data."
        }
        return nil
    }

    private func updateDataFreshness(now: Date = Date()) {
        thighReceivingData = thighConnected
            && now.timeIntervalSince(lastQuaternionDate[.thigh] ?? .distantPast) <= packetFreshnessInterval
        shinReceivingData = shinConnected
            && now.timeIntervalSince(lastQuaternionDate[.shin] ?? .distantPast) <= packetFreshnessInterval
    }

    private func startCalibrationWatchdog() {
        calibrationWatchdog = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                guard let self, self.isCalibrating else { return }
                self.updateDataFreshness()
                if let message = self.sensorDataErrorMessage {
                    self.failCalibration(message)
                    return
                }
            }
        }
    }

    private func failCalibration(_ message: String) {
        calibrationWatchdog?.cancel()
        calibrationWatchdog = nil
        calibrationError = message
        isCalibrating = false
        calibrationRemainingSeconds = 0
        isAngleSessionActive = false
        streamStartDate = nil
        processor.resetCalibration()
        statusText = message
    }

    private func parseQuaternion(from data: Data, defaultSegment: Segment) -> (Segment, Quaternion)? {
        guard let line = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !line.isEmpty else {
            return nil
        }

        let parts = line
            .split(separator: ",", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

        guard parts.count >= 2 else { return nil }

        var segment = defaultSegment
        let first = parts[0].uppercased()
        if first == "THIGH" || first == "NODE" {
            segment = .thigh
        } else if first == "SHIN" {
            segment = .shin
        }

        if let qIndex = parts.firstIndex(where: { $0.uppercased().hasPrefix("Q=") }),
           qIndex + 3 < parts.count,
           let w = Double(parts[qIndex].split(separator: "=", maxSplits: 1).last ?? ""),
           let x = Double(parts[qIndex + 1]),
           let y = Double(parts[qIndex + 2]),
           let z = Double(parts[qIndex + 3]) {
            return (segment, Quaternion(x: x, y: y, z: z, w: w))
        }

        if parts.count == 5,
           let w = Double(parts[1]),
           let x = Double(parts[2]),
           let y = Double(parts[3]),
           let z = Double(parts[4]) {
            return (segment, Quaternion(x: x, y: y, z: z, w: w))
        }

        if parts.count == 4,
           let w = Double(parts[0]),
           let x = Double(parts[1]),
           let y = Double(parts[2]),
           let z = Double(parts[3]) {
            return (defaultSegment, Quaternion(x: x, y: y, z: z, w: w))
        }

        return nil
    }
}

extension AngleService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            scan()
        case .poweredOff:
            statusText = "Bluetooth off"
            isStreaming = false
        case .unauthorized:
            statusText = "Bluetooth permission denied"
            isStreaming = false
        case .unsupported:
            #if targetEnvironment(simulator)
            statusText = "Run on iPhone to connect"
            #else
            statusText = "Bluetooth unavailable on this device"
            #endif
            isStreaming = false
        default:
            statusText = "Bluetooth unavailable"
            isStreaming = false
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        guard let segment = classify(name: peripheral.name, advertisementData: advertisementData) else {
            return
        }

        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        discoveredSensors[peripheral.identifier] = DiscoveredSensor(
            peripheral: peripheral,
            segment: segment,
            name: advertisedName ?? peripheral.name ?? segment.placement.title,
            rssi: RSSI.intValue
        )
        if !isConnected {
            statusText = "Select thigh + shin sensors"
        }
        updateAvailableDevices()
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if segmentByPeripheralID[peripheral.identifier] == nil,
           let discovered = discoveredSensors[peripheral.identifier] {
            segmentByPeripheralID[peripheral.identifier] = discovered.segment
            peripherals[discovered.segment] = peripheral
        }
        updateConnectionState()
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let segment = segmentByPeripheralID[peripheral.identifier] {
            peripherals[segment] = nil
            latestQuaternion[segment] = nil
            lastQuaternionDate[segment] = nil
        }
        segmentByPeripheralID[peripheral.identifier] = nil
        streamStartDate = nil
        processor.resetCalibration()
        isCalibrating = false
        calibrationRemainingSeconds = 0
        calibrationWatchdog?.cancel()
        calibrationWatchdog = nil
        calibrationError = nil
        isAngleSessionActive = false
        updateDataFreshness()
        updateConnectionState()

        if isStreaming {
            scan()
        }
    }
}

extension AngleService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil, let services = peripheral.services else {
            statusText = "Service discovery failed"
            return
        }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil, let characteristics = service.characteristics else {
            statusText = "Characteristic discovery failed"
            return
        }

        let sorted = characteristics.sorted { left, right in
            if left.uuid == primaryCharacteristicUUID { return true }
            if right.uuid == primaryCharacteristicUUID { return false }
            return left.uuid.uuidString < right.uuid.uuidString
        }

        for characteristic in sorted where characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil,
              let data = characteristic.value,
              let defaultSegment = segmentByPeripheralID[peripheral.identifier],
              let parsed = parseQuaternion(from: data, defaultSegment: defaultSegment) else {
            return
        }

        handleQuaternion(parsed.1, segment: parsed.0)
    }
}
