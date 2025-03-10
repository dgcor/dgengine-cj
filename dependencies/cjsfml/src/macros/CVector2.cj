macro package cjsfml.macros

import std.ast.*

public macro CVector2(attrTokens: Tokens, inputTokens: Tokens) {
    const errorMsg = "Invalid CVector2 syntax"
    const errorHint = "Syntax: CVector2[<Private|public|..> <Identifier> <type>]()\n" +
        "Example: CVector2[Vector2i Int32](), CVector2[public Vector2f Float32]()"

    if (inputTokens.size > 0) {
        diagReport(DiagReportLevel.ERROR, attrTokens, errorMsg, errorHint)
    }

    var visibility = Token(PRIVATE)
    var name = Token(IDENTIFIER)
    var valueType = Token(INT32)

    match (attrTokens.size) {
        case 2 =>
            name = attrTokens[0]
            valueType = attrTokens[1]
        case 3 =>
            visibility = attrTokens[0]
            name = attrTokens[1]
            valueType = attrTokens[2]
        case _ => diagReport(DiagReportLevel.ERROR, attrTokens, errorMsg, errorHint)
    }

    if (visibility.kind != PRIVATE && visibility.kind != PROTECTED && visibility.kind != INTERNAL && visibility.kind !=
        PUBLIC) {
        diagReport(DiagReportLevel.ERROR, attrTokens, errorMsg, errorHint)
    }
    if (name.kind != IDENTIFIER) {
        diagReport(DiagReportLevel.ERROR, attrTokens, errorMsg, errorHint)
    }
    if (valueType.kind != INT8 && valueType.kind != INT16 && valueType.kind != INT32 && valueType.kind != INT64 &&
        valueType.kind != UINT8 && valueType.kind != UINT16 && valueType.kind != UINT32 && valueType.kind != UINT64 &&
        valueType.kind != FLOAT16 && valueType.kind != FLOAT32 && valueType.kind != FLOAT64 && valueType.kind !=
        INTNATIVE && valueType.kind != UINTNATIVE && valueType.kind != BOOLEAN) {
        diagReport(DiagReportLevel.ERROR, attrTokens, errorMsg, errorHint)
    }

    var defaultValue: Token = match (valueType.kind) {
        case INT8 | INT16 | INT32 | INT64 | UINT8 | UINT16 | UINT32 | UINT64 | INTNATIVE | UINTNATIVE => Token(
            INTEGER_LITERAL, "0")
        case FLOAT16 | FLOAT32 | FLOAT64 => Token(FLOAT_LITERAL, "0.0")
        case BOOLEAN => Token(BOOL_LITERAL, "false")
        case _ =>
            diagReport(DiagReportLevel.ERROR, attrTokens, errorMsg, errorHint)
            Token()
    }

    let start = quote(
@C
$(visibility) struct $(name) {
    public var x: $(valueType) = $(defaultValue)
    public var y: $(valueType) = $(defaultValue)

    public const init() {}
    public const init(x: $(valueType), y: $(valueType)) {
        this.x = x
        this.y = y
    }

    public const init(tuple: ($(valueType), $(valueType))) {
        x = tuple[0]
        y = tuple[1]
    }

)
    let operatorsNumber = quote(
    public operator const func -(): $(name) {
        return $(name)(-x, -y)
    }

    public operator const func +(right: $(name)): $(name) {
        return $(name)(x + right.x, y + right.y)
    }

    public operator const func -(right: $(name)): $(name) {
        return $(name)(x - right.x, y - right.y)
    }

    public operator const func +(right: ($(valueType), $(valueType))): $(name) {
        return $(name)(x + right[0], y + right[1])
    }

    public operator const func -(right: ($(valueType), $(valueType))): $(name) {
        return $(name)(x - right[0], y - right[1])
    }

    public operator const func *(right: $(valueType)): $(name) {
        return $(name)(x * right, y * right)
    }

    public operator const func /(right: $(valueType)): $(name) {
        return $(name)(x / right, y / right)
    }
}
)
    let operatorsBool = quote(
    public operator const func -(): $(name) {
        return $(name)(!x, !y)
    }

    public operator const func +(right: $(name)): $(name) {
        return $(name)(x || right.x, y || right.y)
    }

    private static const func subtract(left: Bool, right: Bool): Bool {
        if (left && right) {
            false
        } else if (left && !right) {
            true
        } else if (!left && right) {
            false
        } else {
            false
        }
    }

    public operator const func -(right: $(name)): $(name) {
        return $(name)(subtract(x, right.x), subtract(y, right.y))
    }

    public operator const func +(right: ($(valueType), $(valueType))): $(name) {
        return $(name)(x || right[0], y || right[1])
    }

    public operator const func -(right: ($(valueType), $(valueType))): $(name) {
        return $(name)(subtract(x, right[0]), subtract(y, right[1]))
    }
}
)
    if (valueType.kind == BOOLEAN) {
        return start + operatorsBool
    }
    return start + operatorsNumber
}
