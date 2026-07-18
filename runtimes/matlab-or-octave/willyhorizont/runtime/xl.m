classdef xl
    methods (Static)
        function d = dict(varargin)
            if mod(length(varargin), 2) ~= 0
                error("XlRuntimeError: Invalid Dict.");
            end
            d = containers.Map("KeyType", "char", "ValueType", "any");
            for i = 1:2:length(varargin)
                k = varargin{i};
                v = varargin{i+1};
                d(k) = v;
            end
        end

        function r = escapestring(s)
            if isequal(s, {}) || isequal(s, [])
                r = "";
                return;
            end
            r = s;
            r = strrep(r, "\\", "\\\\");
            r = strrep(r, "\"", "\\\"");
            r = strrep(r, "\n", "\\n");
            r = strrep(r, "\r", "\\r");
            r = strrep(r, "\t", "\\t");
        end

        function r = jsonstringify(a, varargin)
            p = false;
            if length(varargin) >= 1 && isstruct(varargin{1}) && isfield(varargin{1}, "pretty")
                p = varargin{1}.("pretty");
            end
            t = repmat(" ", 1, 4);
            s = {struct("t", "v", "v", {a}, "d", 0)};
            r = "";
            while ~isempty(s)
                c = s{end};
                s(end) = []; 
                if strcmp(c.("t"), "r")
                    r = cstrcat(r, c.("v"));
                    continue;
                end
                v = c.("v");
                curd = c.("d");
                if isequal(v, {}) || isequal(v, [])
                    r = cstrcat(r, "null");
                    continue;
                end
                if islogical(v)
                    if v
                        r = cstrcat(r, "true");
                    else
                        r = cstrcat(r, "false");
                    end
                    continue;
                end
                if ischar(v) || isstring(v)
                    r = cstrcat(r, """", xl.escapestring(v), """");
                    continue;
                end
                if isnumeric(v) && numel(v) == 1
                    r = cstrcat(r, num2str(v));
                    continue;
                end
                if isa(v, "function_handle")
                    r = cstrcat(r, """[object Function]""");
                    continue;
                end
                if iscell(v)
                    if isempty(v)
                        r = cstrcat(r, "[]");
                        continue;
                    end
                    childd = curd + 1;
                    slcb = "]";
                    if p; slcb = cstrcat("\n", repmat(t, 1, curd), "]"); end;
                    s{end+1} = struct("t", "r", "v", slcb, "d", curd);
                    for i = length(v):-1:1
                        s{end+1} = struct("t", "v", "v", {v{i}}, "d", childd);
                        if i > 1
                            slelsep = ",";
                            if p; slelsep = cstrcat(",\n", repmat(t, 1, childd)); end;
                            s{end+1} = struct("t", "r", "v", slelsep, "d", childd);
                        end
                    end
                    slob = "[";
                    if p; slob = cstrcat("[\n", repmat(t, 1, childd)); end;
                    s{end+1} = struct("t", "r", "v", slob, "d", childd);
                    continue;
                end
                if isa(v, "containers.Map") || isstruct(v)
                    if isstruct(v)
                        dkl = fieldnames(v);
                    else
                        dkl = keys(v);
                    end
                    if isempty(dkl)
                        r = cstrcat(r, "{}");
                        continue;
                    end
                    childd = curd + 1;
                    sdcb = "}";
                    if p; sdcb = cstrcat("\n", repmat(t, 1, curd), "}"); end;
                    s{end+1} = struct("t", "r", "v", sdcb, "d", curd);
                    for i = length(dkl):-1:1
                        dk = dkl{i};
                        if isstruct(v)
                            dv = v.(dk);
                        else
                            dv = v(dk);
                        end
                        s{end+1} = struct("t", "v", "v", {dv}, "d", childd);
                        sdpkvsep = cstrcat("""", dk, """:");
                        if p; sdpkvsep = cstrcat("""", dk, """: "); end;
                        s{end+1} = struct("t", "r", "v", sdpkvsep, "d", childd);
                        if i > 1
                            sdelsep = ",";
                            if p; sdelsep = cstrcat(",\n", repmat(t, 1, childd)); end;
                            s{end+1} = struct("t", "r", "v", sdelsep, "d", childd);
                        end
                    end
                    sdob = "{";
                    if p; sdob = cstrcat("{\n", repmat(t, 1, childd)); end;
                    s{end+1} = struct("t", "r", "v", sdob, "d", childd);
                    continue;
                end
                r = cstrcat(r, """", class(v), """");
            end
        end
    end
end
