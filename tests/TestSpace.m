classdef TestSpace < matlab.unittest.TestCase
    properties  
        ax
        testSpace
    end
    
    methods(TestMethodSetup)
        function createSystemOptic(testCase)

            testCase.testSpace  = Space();
        end
    end
    
    methods(TestMethodTeardown)
        function deleteSpace(testCase)
            delete(testCase.testSpace)
        end
    end
    
    methods (Test)
        function testClass(testCase)
           
            testCase.verifyClass(testCase.testSpace(),'Space');
        end
        
       
        
    end
end