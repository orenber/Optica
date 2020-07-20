classdef TestArrow < matlab.unittest.TestCase
    properties  
        ax
        testArrow
    end
    
    methods(TestMethodSetup)
        function createArrow(testCase)

            testCase.testArrow  = Arrow([3 4],[1 2],'green');
        end
    end
    
    methods(TestMethodTeardown)
        function deleteArrow(testCase)
            delete(testCase.testArrow)
        end
    end
    
    methods (Test)
        function testClass(testCase)
           
            testCase.verifyClass(testCase.testArrow(),'Arrow');
        end
        
    end
end