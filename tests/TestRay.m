classdef TestRay < matlab.unittest.TestCase
    properties  
        ax
        testRay
       
    end
    
    methods(TestMethodSetup)
        function createRay(testCase)

            testCase.testRay  = Ray(SystemOptic());
        end
    end
    
    methods(TestMethodTeardown)
        function deleteRay(testCase)
            delete(testCase.testRay)
        end
    end
    
    methods (Test)
        function testClass(testCase)
           
            testCase.verifyClass(testCase.testRay(),'Ray');
        end
        
       
        
    end
end