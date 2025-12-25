classdef Logger
    methods (Static)
        function info(msg)
            fprintf('[INFO] %s\n', msg);
        end
    end
end
