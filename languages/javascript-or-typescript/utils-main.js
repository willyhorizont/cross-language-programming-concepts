const AnyType = { "Undefined": "Undefined", "Null": "Null", "Boolean": "Boolean", "String": "String", "Numeric": "Numeric", "Object": "Object", "Array": "Array", "Function": "Function", "Error": "Error", "Date": "Date" };

const checkIsNull = (anything) => (((Object.prototype.toString.call(anything) === "[object Null]") && (anything === null)) || ((Object.prototype.toString.call(anything) === "[object Undefined]") && (anything === undefined)));

const checkIsBoolean = (anything) => ((Object.prototype.toString.call(anything) === "[object Boolean]") && ((anything === true) || (anything === false)));

const checkIsString = (anything) => (Object.prototype.toString.call(anything) === "[object String]");

const checkIsNumeric = (anything) => ((Object.prototype.toString.call(anything) === "[object Number]") && (Number.isNaN(anything) === false) && (Number.isFinite(anything) === true));

const checkIsObject = (anything) => (Object.prototype.toString.call(anything) === "[object Object]");

const checkIsArray = (anything) => ((Object.prototype.toString.call(anything) === "[object Array]") && (Array.isArray(anything) === true));

const checkIsFunction = (anything) => (Object.prototype.toString.call(anything) === "[object Function]");

const getType = (anything) => ((checkIsNull(anything) === true) ? AnyType.Null : ((checkIsBoolean(anything) === true) ? AnyType.Boolean : ((checkIsString(anything) === true) ? AnyType.String : ((checkIsNumeric(anything) === true) ? AnyType.Numeric : ((checkIsObject(anything) === true) ? AnyType.Object : ((checkIsArray(anything) === true) ? AnyType.Array : ((checkIsFunction(anything) === true) ? AnyType.Function : Object.prototype.toString.call(anything))))))));

const jsonStringify = (anything, { pretty = false } = {}) => {
    // custom JSON.stringify() function jsonStringifyV3
    const indent = " ".repeat(4);
    let indentLevel = 0;
    const jsonStringifyInner = (anythingInner) => {
        const anythingInnerType = getType(anythingInner);
        if (anythingInnerType === AnyType.Null) return "null";
        if (anythingInnerType === AnyType.String) return `"${anythingInner}"`;
        if ((anythingInnerType === AnyType.Numeric) || (anythingInnerType === AnyType.Boolean)) return `${anythingInner}`;
        if (anythingInnerType === AnyType.Object) {
            if (Object.keys(anythingInner).length === 0) return "{}";
            indentLevel += 1;
            let result = ((pretty === true) ? (`{\n${indent.repeat(indentLevel)}`) : "{ ");
            Object.entries(anythingInner).forEach(([objectKey, objectValue], objectEntryIndex) => {
                result = `${result}"${objectKey}": ${jsonStringifyInner(objectValue)}`;
                if ((objectEntryIndex + 1) !== Object.keys(anythingInner).length) {
                    result = `${result}${((pretty === true) ? (`,\n${indent.repeat(indentLevel)}`) : ", ")}`;
                }
            });
            indentLevel -= 1;
            result = `${result}${((pretty === true) ? (`\n${indent.repeat(indentLevel)}}`) : " }")}`;
            return result;
        }
        if (anythingInnerType === AnyType.Array) {
            if (anythingInner.length === 0) return "[]";
            indentLevel += 1;
            let result = ((pretty === true) ? (`[\n${indent.repeat(indentLevel)}`) : "[");
            anythingInner.forEach((arrayItem, arrayItemIndex) => {
                result = `${result}${jsonStringifyInner(arrayItem)}`;
                if ((arrayItemIndex + 1) !== anythingInner.length) {
                    result = `${result}${((pretty === true) ? (`,\n${indent.repeat(indentLevel)}`) : ", ")}`;
                }
            });
            indentLevel -= 1;
            result = `${result}${((pretty === true) ? (`\n${indent.repeat(indentLevel)}]`) : "]")}`;
            return result;
        }
        if (anythingInnerType === AnyType.Function) return "[object Function]";
        return anythingInnerType;
    };
    return jsonStringifyInner(anything);
};