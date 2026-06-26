#pragma once

#include <iostream>
#include <variant>
#include <string>
#include <vector>
#include <unordered_map>
#include <functional>
#include <memory>
#include <utility>
#include <cstdint>
#include <sstream>
#include <algorithm>
#include <stdexcept>

namespace xl {
    struct XlNone {
        bool operator==(const XlNone&) const {
            return true;
        }
    };

    class CrossType;

    using XlBool = bool;
    using XlInt = int64_t;
    using XlFloat = double;
    using XlString = std::string;
    using XlList = std::vector<CrossType>;
    using XlDict = std::unordered_map<std::string, CrossType>;

    struct XlDictIndexed {
        std::vector<std::string> keys;
        std::unordered_map<std::string, CrossType> map;

        void insert(const std::string& key, const CrossType& value);
    };

    struct XlClosureVarArgs {
        const std::vector<CrossType>& varargs;
        size_t index = 0;

        XlClosureVarArgs(const std::vector<CrossType>& arg) : varargs(arg), index(0) {}

        CrossType getNextArguments(); 
    };

    using XlClosure = std::function<CrossType(XlClosureVarArgs&)>;

    class CrossType {
    public: 
        std::variant<
            XlNone,
            XlBool,
            XlInt,
            XlFloat,
            XlString,
            std::shared_ptr<XlList>,
            std::shared_ptr<XlDict>,
            std::shared_ptr<XlDictIndexed>,
            XlClosure
        > value;

        CrossType() : value(XlNone{}) {}
        CrossType(XlNone v) : value(v) {}
        CrossType(XlBool v) : value(v) {}
        CrossType(XlInt v) : value(v) {}
        CrossType(XlFloat v) : value(v) {}
        CrossType(XlString v) : value(v) {}
        CrossType(const char* v) : value(XlString(v)) {}
        CrossType(XlList v) : value(std::make_shared<XlList>(std::move(v))) {}
        CrossType(XlDict v) : value(std::make_shared<XlDict>(std::move(v))) {}
        CrossType(XlDictIndexed v) : value(std::make_shared<XlDictIndexed>(std::move(v))) {}
        CrossType(XlClosure v) : value(v) {}

        template <typename... Args>
        CrossType call(Args&&... varargs) const {
            if (auto xl_closure_ref = std::get_if<XlClosure>(&value)) {
                std::vector<CrossType> varargs_xl_list;
                varargs_xl_list.reserve(sizeof...(varargs));
                (varargs_xl_list.push_back(CrossType(std::forward<Args>(varargs))), ...);

                XlClosureVarArgs varargs_tracker(varargs_xl_list);
                return (*xl_closure_ref)(varargs_tracker);
            }
            throw std::runtime_error("Error: Expected XlClosure.");
        }
    };

    inline CrossType XlClosureVarArgs::getNextArguments() {
        if (index < varargs.size()) {
            return varargs[index++];
        }
        return CrossType(XlNone{});
    }

    inline void XlDictIndexed::insert(const std::string& key, const CrossType& value) {
        if (map.find(key) == map.end()) {
            keys.push_back(key);
        }
        map[key] = value;
    }

    template <typename... Args>
    CrossType to_xl_list(Args&&... varargs) {
        XlList new_xl_list;
        new_xl_list.reserve(sizeof...(varargs));
        (new_xl_list.push_back(CrossType(std::forward<Args>(varargs))), ...);
        return CrossType(std::move(new_xl_list));
    }

    template <typename... Args>
    CrossType to_xl_dict(Args&&... varargs) {
        XlDict new_xl_dict;
        (new_xl_dict.insert(std::forward<Args>(varargs)), ...);
        return CrossType(std::move(new_xl_dict));
    }

    template <typename... Args>
    CrossType to_xl_dict_indexed(Args&&... varargs) {
        XlDictIndexed new_xl_dict_indexed;
        ([&](auto&& pair) {
            new_xl_dict_indexed.insert(
                std::forward<decltype(pair.first)>(pair.first), 
                CrossType(std::forward<decltype(pair.second)>(pair.second))
            );
        }(std::forward<Args>(varargs)), ...);
        return CrossType(std::move(new_xl_dict_indexed));
    }

    inline std::string string_repeat(std::string s, size_t n) {
        std::string result = "";
        for (size_t i = 0; i < n; i += 1) {
            result += s;
        }
        return result;
    }

    struct JsonStringifyOptionalArgument {
        bool pretty = false;
    };

    struct JsonStringifyToken {
        std::string type; // "reference" or "primitive"
        CrossType cross_type_value;
        std::string primitive_value;
        size_t indentation_level = 0;
    };

    std::string json_stringify(const CrossType& anything, JsonStringifyOptionalArgument option = {}) {
        const std::string indentation = "    ";
        std::vector<JsonStringifyToken> token_stack;

        token_stack.push_back({ "reference", anything, "", 0 });
        std::string result = "";

        while (!token_stack.empty()) {
            JsonStringifyToken current = token_stack.back();
            token_stack.pop_back();

            if (current.type == "primitive") {
                result += current.primitive_value;
                continue;
            }

            size_t current_indentation_level = current.indentation_level;
            const auto& current_value = current.cross_type_value.value; // access internal std::variant

            if (std::holds_alternative<XlNone>(current_value)) {
                result += "null";
                continue;
            }

            if (std::holds_alternative<XlString>(current_value)) {
                result += "\"" + std::get<XlString>(current_value) + "\"";
                continue;
            }

            if (std::holds_alternative<XlBool>(current_value)) {
                result += std::get<XlBool>(current_value) ? "true" : "false";
                continue;
            }

            if (std::holds_alternative<XlInt>(current_value)) {
                result += std::to_string(std::get<XlInt>(current_value));
                continue;
            }

            if (std::holds_alternative<XlFloat>(current_value)) {
                result += std::to_string(std::get<XlFloat>(current_value));
                continue;
            }

            if (auto any_xl_list_ref = std::get_if<std::shared_ptr<XlList>>(&current_value)) {
                auto& xl_list_ref = *any_xl_list_ref;
                if (xl_list_ref->empty()) {
                    result += "[]";
                    continue;
                }

                size_t child_indentation_level = current_indentation_level + 1;

                token_stack.push_back({ "primitive", CrossType(XlNone{}), std::string(option.pretty ? ("\n" + string_repeat(indentation, current_indentation_level) + "]") : "]"), current_indentation_level });

                for (ptrdiff_t i = static_cast<ptrdiff_t>(xl_list_ref->size()) - 1; i >= 0; i -= 1) {
                    token_stack.push_back({ "reference", (*xl_list_ref)[i], "", child_indentation_level });

                    if (i > 0) {
                        token_stack.push_back({ "primitive", CrossType(XlNone{}), std::string(option.pretty ? (",\n" + string_repeat(indentation, child_indentation_level)) : ", "), child_indentation_level });
                    }
                }

                token_stack.push_back({ "primitive", CrossType(XlNone{}), std::string(option.pretty ? ("[\n" + string_repeat(indentation, child_indentation_level)) : "["), child_indentation_level });
                continue;
            }

            if (auto any_xl_dict_indexed_ref = std::get_if<std::shared_ptr<XlDictIndexed>>(&current_value)) {
                auto& xl_dict_indexed_ref = *any_xl_dict_indexed_ref;
                if (xl_dict_indexed_ref->keys.empty()) {
                    result += "{}";
                    continue;
                }

                size_t child_indentation_level = current_indentation_level + 1;

                token_stack.push_back({ "primitive", CrossType(XlNone{}), std::string(option.pretty ? ("\n" + string_repeat(indentation, current_indentation_level) + "}") : " }"), current_indentation_level });

                for (ptrdiff_t i = static_cast<ptrdiff_t>(xl_dict_indexed_ref->keys.size()) - 1; i >= 0; i -= 1) {
                    std::string key = xl_dict_indexed_ref->keys[i];
                    CrossType val = xl_dict_indexed_ref->map.at(key);

                    token_stack.push_back({ "reference", val, "", child_indentation_level });
                    token_stack.push_back({ "primitive", CrossType(XlNone{}), "\"" + key + "\": ", child_indentation_level });

                    if (i > 0) {
                        token_stack.push_back({ "primitive", CrossType(XlNone{}), std::string(option.pretty ? (",\n" + string_repeat(indentation, child_indentation_level)) : ", "), child_indentation_level });
                    }
                }

                token_stack.push_back({ "primitive", CrossType(XlNone{}), std::string(option.pretty ? ("{\n" + string_repeat(indentation, child_indentation_level)) : "{ "), child_indentation_level });
                continue;
            }

            if (auto any_xl_dict_ref = std::get_if<std::shared_ptr<XlDict>>(&current_value)) {
                auto& xl_dict_ref = *any_xl_dict_ref;
                if (xl_dict_ref->empty()) {
                    result += "{}";
                    continue;
                }

                size_t child_indentation_level = current_indentation_level + 1;

                token_stack.push_back({ "primitive", CrossType(XlNone{}), option.pretty ? ("\n" + string_repeat(indentation, current_indentation_level) + "}") : " }", current_indentation_level });

                std::vector<std::pair<std::string, CrossType>> xl_dict_items(xl_dict_ref->begin(), xl_dict_ref->end());

                for (ptrdiff_t i = static_cast<ptrdiff_t>(xl_dict_items.size()) - 1; i >= 0; i -= 1) {
                    token_stack.push_back({ "reference", xl_dict_items[i].second, "", child_indentation_level });
                    token_stack.push_back({ "primitive", CrossType(XlNone{}), "\"" + xl_dict_items[i].first + "\": ", child_indentation_level });

                    if (i > 0) {
                        token_stack.push_back({ "primitive", CrossType(XlNone{}), option.pretty ? (",\n" + string_repeat(indentation, child_indentation_level)) : ", ", child_indentation_level });
                    }
                }

                token_stack.push_back({ "primitive", CrossType(XlNone{}), option.pretty ? ("{\n" + string_repeat(indentation, child_indentation_level)) : "{ ", child_indentation_level });
                continue;
            }

            if (std::holds_alternative<XlClosure>(current_value)) {
                result += "\"XlClosure\"";
                continue;
            }

            result += "\"Unknown\"";
        }

        return result;
    }
}
