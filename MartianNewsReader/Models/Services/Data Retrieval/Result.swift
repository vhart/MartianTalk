enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}
