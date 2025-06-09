classdef main_settings
    properties
        plot0 
        plot1 
        plot2 
        plot3 
        plot4 
        plot5 
        param 
        editmodel
    end
    methods 
        function obj = main_settings()
            obj.plot0 = 'AEGM';
            obj.plot1 = 'VEGM';
            obj.plot2 = 'Aget/Vget';
            obj.plot3 = 'AP/VP'; 
            obj.plot4 = 'AS/VS';
            obj.plot5 = 'AR/VR';
            obj.param = 'Normal';
            obj.editmodel = false;
        end
        function obj = set.plot0(obj,val)
            obj.plot0 = val;
        end
        function obj = set.plot1(obj,val)
            obj.plot1 = val;
        end
        function obj = set.plot2(obj,val)
            obj.plot2 = val;
        end
        function obj = set.plot3(obj,val)
            obj.plot3 = val;
        end
        function obj = set.plot4(obj,val)
            obj.plot4 = val;
        end
        function obj = set.plot5(obj,val)
            obj.plot5 = val;
        end
        function obj = set.param(obj,val)
            obj.param = val;
        end
        function obj = set.editmodel(obj,val)
            obj.editmodel = val;
        end

    end

end