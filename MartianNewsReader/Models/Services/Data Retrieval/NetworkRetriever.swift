import Foundation

struct NetworkRetriever<T>: DataRetrieving {
    func get(from url: URL,
             decoding strategy: DecodingStrategy,
             onComplete: @escaping (Result<T, RetrievalError>) -> Void) {

        let task = URLSession.shared.dataTask(with: url) { (data, response, _) in
            guard let data = data
                else {
                    let retrievalError: RetrievalError

                    if let response = response as? HTTPURLResponse {
                        switch response.statusCode {
                        case 400...499: retrievalError = .badRequest
                        case 500...599: retrievalError = .serverError
                        default: retrievalError = .unknownError
                        }
                    } else {
                        retrievalError = .unknownError
                    }

                    onComplete(.failure(retrievalError))
                    return
            }

            guard let content = strategy.decode(data: data) as? T
                else { onComplete(.failure(.invalidData)) ; return }

            onComplete(.success(content))
        }
        task.resume()
    }
}
