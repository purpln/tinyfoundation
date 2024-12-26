public enum Mode: String {
    case readOnly      = "rb"
    case writeOnly     = "wb"
    case readAndWrite  = "r+b"
    case appendOnly    = "ab"
    case appendAndRead = "a+b"
}
