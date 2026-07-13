<?php

namespace WillyHorizont\Runtime;

class Xl {
    public static function escape_string($s) {
        if ($s === null) {
            return "";
        }
        return strtr((string)$s, [
            "\\" => "\\\\",
            "\""  => "\\\"",
            "\n" => "\\n",
            "\r" => "\\r",
            "\t" => "\\t"
        ]);
    }
    public static function json_stringify($a, $p = false) {
        $t = str_repeat(" ", 4);
        $s = [["t" => "v", "v" => $a, "d" => 0]];
        $r = "";
        while (count($s) > 0) {
            $c = array_pop($s);
            if ($c["t"] === "r") {
                $r .= $c["v"];
                continue;
            }
            $v = $c["v"];
            $cur_t = $c["d"];
            if ($v === null) {
                $r .= "null";
                continue;
            }
            if (((gettype($v) === "boolean") || (gettype($v) === "bool")) && is_bool($v)) {
                $r .= $v ? "true" : "false";
                continue;
            }
            if ((gettype($v) === "string") && is_string($v)) {
                $r .= "\"" . Xl::escape_string($v) . "\"";
                continue;
            }
            if (is_numeric($v) && ((((gettype($v) === "integer") || (gettype($v) === "int")) && (is_int($v) || is_integer($v))) || (((gettype($v) === "float") || (gettype($v) === "double")) && (is_float($v) || is_double($v))))) {
                $r .= (string)$v;
                continue;
            }
            if (is_callable($v)) {
                $r .= "\"[object Function]\"";
                continue;
            }
            if ((gettype($v) === "array") && is_array($v) && ((array_keys($v) === range(0, count($v) - 1)) || empty($v))) {
                if (count($v) === 0) {
                    $r .= "[]";
                    continue;
                }
                $child_t = $cur_t + 1;
                $s[] = [
                    "t" => "r",
                    "v" => $p ? "\n" . str_repeat($t, $cur_t) . "]" : "]",
                    "d" => $cur_t
                ];
                for ($i = count($v) - 1; $i >= 0; $i -= 1) {
                    $s[] = [
                        "t" => "v",
                        "v" => $v[$i],
                        "d" => $child_t
                    ];
                    if ($i > 0) {
                        $s[] = [
                            "t" => "r",
                            "v" => $p ? ",\n" . str_repeat($t, $child_t) : ",",
                            "d" => $child_t
                        ];
                    }
                }
                $s[] = [
                    "t" => "r",
                    "v" => $p ? "[\n" . str_repeat($t, $child_t) : "[",
                    "d" => $child_t
                ];
                continue;
            }
            if ((gettype($v) === "array") && is_array($v) && (!empty($v) && (array_keys($v) !== range(0, count($v) - 1)))) {
                $de = is_object($v) ? get_object_vars($v) : $v;
                if (count($de) === 0) {
                    $r .= "{}";
                    continue;
                }
                $child_t = $cur_t + 1;
                $s[] = [
                    "t" => "r",
                    "v" => $p ? "\n" . str_repeat($t, $cur_t) . "}" : "}",
                    "d" => $cur_t
                ];
                $keys = array_keys($de);
                for ($i = count($keys) - 1; $i >= 0; $i -= 1) {
                    $dk = $keys[$i];
                    $dict_value = $de[$dk];
                    $s[] = [
                        "t" => "v",
                        "v" => $dict_value,
                        "d" => $child_t
                    ];
                    $s[] = [
                        "t" => "r",
                        "v" => $p ? "\"{$dk}\": " : "\"{$dk}\":",
                        "d" => $child_t
                    ];
                    if ($i > 0) {
                        $s[] = [
                            "t" => "r",
                            "v" => $p ? ",\n" . str_repeat($t, $child_t) : ",",
                            "d" => $child_t
                        ];
                    }
                }
                $s[] = [
                    "t" => "r",
                    "v" => $p ? "{\n" . str_repeat($t, $child_t) : "{",
                    "d" => $child_t
                ];
                continue;
            }
            $r .= "\"" . gettype($v) . "\"";
        }
        return $r;
    }
}
