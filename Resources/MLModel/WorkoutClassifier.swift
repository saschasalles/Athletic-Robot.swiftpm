//
// WorkoutClassifier.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class WorkoutClassifierInput : MLFeatureProvider {

    /// A sequence of body poses to classify. Its multiarray encoding uses the first dimension to index time over 60 frames. The second dimension indexes x, y, and confidence of pose keypoint locations. The last dimension indexes the keypoint type, ordered as: nose, neck, right shoulder, right elbow, right wrist, left shoulder, left elbow, left wrist, right hip, right knee, right ankle, left hip, left knee, left ankle, right eye, left eye, right ear, left ear as 60 × 3 × 18 3-dimensional array of floats
    public var poses: MLMultiArray

    public var featureNames: Set<String> {
        get {
            return ["poses"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "poses") {
            return MLFeatureValue(multiArray: poses)
        }
        return nil
    }
    
    public init(poses: MLMultiArray) {
        self.poses = poses
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public convenience init(poses: MLShapedArray<Float>) {
        self.init(poses: MLMultiArray(poses))
    }

}


/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class WorkoutClassifierOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// Probability of each category as dictionary of strings to doubles
    public lazy var labelProbabilities: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "labelProbabilities")!.dictionaryValue as! [String : Double]
    }()

    /// Most likely action category as string value
    public lazy var label: String = {
        [unowned self] in return self.provider.featureValue(for: "label")!.stringValue
    }()

    public var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    public init(labelProbabilities: [String : Double], label: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["labelProbabilities" : MLFeatureValue(dictionary: labelProbabilities as [AnyHashable : NSNumber]), "label" : MLFeatureValue(string: label)])
    }

    public init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class WorkoutClassifier {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    public class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "WorkoutClassifier", withExtension:"mlmodelc")!
    }

    /**
        Construct WorkoutClassifier instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of WorkoutClassifier.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `WorkoutClassifier.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    public init(model: MLModel) {
        self.model = model
    }

    /**
        Construct WorkoutClassifier instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    public convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    public convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct WorkoutClassifier instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    public convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    public convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct WorkoutClassifier instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<WorkoutClassifier, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct WorkoutClassifier instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> WorkoutClassifier {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct WorkoutClassifier instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<WorkoutClassifier, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(WorkoutClassifier(model: model)))
            }
        }
    }

    /**
        Construct WorkoutClassifier instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> WorkoutClassifier {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return WorkoutClassifier(model: model)
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as WorkoutClassifierInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as WorkoutClassifierOutput
    */
    public func prediction(input: WorkoutClassifierInput) throws -> WorkoutClassifierOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as WorkoutClassifierInput
           - options: prediction options 

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as WorkoutClassifierOutput
    */
    public func prediction(input: WorkoutClassifierInput, options: MLPredictionOptions) throws -> WorkoutClassifierOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return WorkoutClassifierOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - poses: A sequence of body poses to classify. Its multiarray encoding uses the first dimension to index time over 60 frames. The second dimension indexes x, y, and confidence of pose keypoint locations. The last dimension indexes the keypoint type, ordered as: nose, neck, right shoulder, right elbow, right wrist, left shoulder, left elbow, left wrist, right hip, right knee, right ankle, left hip, left knee, left ankle, right eye, left eye, right ear, left ear as 60 × 3 × 18 3-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as WorkoutClassifierOutput
    */
    public func prediction(poses: MLMultiArray) throws -> WorkoutClassifierOutput {
        let input_ = WorkoutClassifierInput(poses: poses)
        return try self.prediction(input: input_)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - poses: A sequence of body poses to classify. Its multiarray encoding uses the first dimension to index time over 60 frames. The second dimension indexes x, y, and confidence of pose keypoint locations. The last dimension indexes the keypoint type, ordered as: nose, neck, right shoulder, right elbow, right wrist, left shoulder, left elbow, left wrist, right hip, right knee, right ankle, left hip, left knee, left ankle, right eye, left eye, right ear, left ear as 60 × 3 × 18 3-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as WorkoutClassifierOutput
    */

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func prediction(poses: MLShapedArray<Float>) throws -> WorkoutClassifierOutput {
        let input_ = WorkoutClassifierInput(poses: poses)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [WorkoutClassifierInput]
           - options: prediction options 

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [WorkoutClassifierOutput]
    */
    public func predictions(inputs: [WorkoutClassifierInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [WorkoutClassifierOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [WorkoutClassifierOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  WorkoutClassifierOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
