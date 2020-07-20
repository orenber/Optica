classdef TestFig < matlab.unittest.TestCase
    properties  
        ax
        testFig
    end
    
    methods(TestMethodSetup)
        function createFig(testCase)

            testCase.testFig  = Fig();
        end
    end
    
    methods(TestMethodTeardown)
        function deleteFig(testCase)
            delete(testCase.testFig)
        end
    end
    
    methods (Test)
        function testClass(testCase)
           
            testCase.verifyClass(testCase.testFig(),'Fig');
        end
        
       
        
    end
end