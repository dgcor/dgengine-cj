package cjsfml.system

protected type SfBool = Int32

extend SfBool {
    public static func fromBool(value: Bool): SfBool {
        match (value) {
            case false => 0
            case true => 1
        }
    }

    public func toBool(): Bool {
        this != 0
    }
}
