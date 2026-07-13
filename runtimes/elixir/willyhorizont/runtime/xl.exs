defmodule Xl do
    def escape_string(s) when is_binary(s) do
        s
        |> String.replace("\\", "\\\\")
        |> String.replace("\"", "\\\"")
        |> String.replace("\n", "\\n")
        |> String.replace("\r", "\\r")
        |> String.replace("\t", "\\t")
    end
    def escape_string(_), do: ""

    defp jify_list([], _, _, _, acc), do: acc

    defp jify_list([head | tail], child_d, p, t, acc) do
        acc_lel = [%{
            "t" => "v",
            "v" => head,
            "d" => child_d
        } | acc]
        jify_list(tail, child_d, p, t, (case tail do
            [] ->
                acc_lel
            _ ->
                [%{
                    "t" => "r",
                    "v" => (if p, do: ",\n" <> String.duplicate(t, child_d), else: ","),
                    "d" => child_d
                } | acc_lel]
        end))
    end

    defp jify_dict([], _, _, _, acc), do: acc

    defp jify_dict([{d_k, d_v} | tail], child_d, p, t, acc) do
        acc_del = [%{
            "t" => "r",
            "v" => (if p, do: "\"" <> to_string(d_k) <> "\": ", else: "\"" <> to_string(d_k) <> "\":"),
            "d" => child_d
        }, %{
            "t" => "v",
            "v" => d_v,
            "d" => child_d
        } | acc]
        jify_dict(tail, child_d, p, t, (case tail do
            [] ->
                acc_del
            _ ->
                [%{
                    "t" => "r",
                    "v" => (if p, do: ",\n" <> String.duplicate(t, child_d), else: ","),
                    "d" => child_d
                } | acc_del]
        end))
    end

    defp jify_loop([], r, _, _), do: r

    defp jify_loop([c | ns], r, p, t) do
        if c["t"] == "r" do
            jify_loop(ns, r <> c["v"], p, t)
        else
            v = c["v"]
            cur_d = c["d"]
            cond do
                is_nil(v) ->
                    jify_loop(ns, r <> "null", p, t)
                is_boolean(v) ->
                    jify_loop(ns, r <> to_string(v), p, t)
                is_binary(v) ->
                    jify_loop(ns, r <> "\"" <> escape_string(v) <> "\"", p, t)
                is_number(v) ->
                    jify_loop(ns, r <> to_string(v), p, t)
                is_function(v) ->
                    jify_loop(ns, r <> "\"[object Function]\"", p, t)
                is_list(v) ->
                    if v == [] do
                        jify_loop(ns, r <> "[]", p, t)
                    else
                        child_d = cur_d + 1
                        jify_loop([%{
                            "t" => "r",
                            "v" => (if p, do: "[\n" <> String.duplicate(t, child_d), else: "["),
                            "d" => child_d
                        } | jify_list(v |> Enum.reverse(), child_d, p, t, [%{
                            "t" => "r",
                            "v" => (if p, do: "\n" <> String.duplicate(t, cur_d) <> "]", else: "]"),
                            "d" => cur_d
                        } | ns])], r, p, t)
                    end
                is_map(v) ->
                    dpl = Map.to_list(v)
                    if dpl == [] do
                        jify_loop(ns, r <> "{}", p, t)
                    else
                        child_d = cur_d + 1
                        jify_loop([%{
                            "t" => "r",
                            "v" => (if p, do: "{\n" <> String.duplicate(t, child_d), else: "{"),
                            "d" => child_d
                        } | jify_dict(dpl |> Enum.reverse(), child_d, p, t, [%{
                            "t" => "r",
                            "v" => (if p, do: "\n" <> String.duplicate(t, cur_d) <> "}", else: "}"),
                            "d" => cur_d
                        } | ns])], r, p, t)
                    end
                true ->
                    jify_loop(ns, r <> "\"[object Object]\"", p, t)
            end
        end
    end

    def json_stringify(a, o \\ []) do
        p = Keyword.get(o, :pretty, false)
        t = String.duplicate(" ", 4)
        s = [%{"t" => "v", "v" => a, "d" => 0}]
        r = ""
        jify_loop(s, r, p, t)
    end
end
