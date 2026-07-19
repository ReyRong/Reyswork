import AVFoundation
import Foundation

enum AmplifyError: Error, CustomStringConvertible {
    case usage
    case unsupportedFormat

    var description: String {
        switch self {
        case .usage:
            return "Usage: swift scripts/amplify-audio.swift <input> <output> <gain-db>"
        case .unsupportedFormat:
            return "Input processing format must expose Float32 channel data."
        }
    }
}

func run() throws {
    guard CommandLine.arguments.count == 4 else {
        throw AmplifyError.usage
    }

    let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
    let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
    let gainDB = Double(CommandLine.arguments[3]) ?? 0
    let gain = Float(pow(10, gainDB / 20))
    let limiterCeiling: Float = 0.98

    let inputFile = try AVAudioFile(forReading: inputURL)
    let processingFormat = inputFile.processingFormat
    guard processingFormat.commonFormat == .pcmFormatFloat32 else {
        throw AmplifyError.unsupportedFormat
    }

    let outputSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: processingFormat.sampleRate,
        AVNumberOfChannelsKey: Int(processingFormat.channelCount),
        AVEncoderBitRateKey: 128_000
    ]

    try? FileManager.default.removeItem(at: outputURL)
    let outputFile = try AVAudioFile(forWriting: outputURL, settings: outputSettings, commonFormat: .pcmFormatFloat32, interleaved: false)
    let frameCapacity: AVAudioFrameCount = 4096

    var sourcePeak: Float = 0
    var outputPeak: Float = 0
    var sourceSquareSum: Double = 0
    var outputSquareSum: Double = 0
    var sampleCount = 0
    var limitedSampleCount = 0
    var processedFrameCount: AVAudioFramePosition = 0

    while inputFile.framePosition < inputFile.length {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: frameCapacity) else {
            throw AmplifyError.unsupportedFormat
        }

        try inputFile.read(into: buffer)
        guard let channelData = buffer.floatChannelData else {
            throw AmplifyError.unsupportedFormat
        }

        let frameLength = Int(buffer.frameLength)
        let channelCount = Int(processingFormat.channelCount)
        for channel in 0..<channelCount {
            let samples = channelData[channel]
            for frame in 0..<frameLength {
                let original = samples[frame]
                sourcePeak = max(sourcePeak, abs(original))
                sourceSquareSum += Double(original * original)

                var amplified = original * gain
                if amplified > limiterCeiling {
                    amplified = limiterCeiling
                    limitedSampleCount += 1
                } else if amplified < -limiterCeiling {
                    amplified = -limiterCeiling
                    limitedSampleCount += 1
                }

                outputPeak = max(outputPeak, abs(amplified))
                outputSquareSum += Double(amplified * amplified)
                samples[frame] = amplified
                sampleCount += 1
            }
        }

        try outputFile.write(from: buffer)
        processedFrameCount += AVAudioFramePosition(buffer.frameLength)
    }

    print("gain_db=\(gainDB)")
    print("frames=\(processedFrameCount)")
    print(String(format: "source_peak=%.4f", sourcePeak))
    print(String(format: "output_peak=%.4f", outputPeak))
    print(String(format: "source_rms=%.4f", sqrt(sourceSquareSum / Double(sampleCount))))
    print(String(format: "output_rms=%.4f", sqrt(outputSquareSum / Double(sampleCount))))
    print("limited_samples=\(limitedSampleCount)")
}

do {
    try run()
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
