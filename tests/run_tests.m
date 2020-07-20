
function run_tests()


%% Create a TestSuite array.
run_test(?TestLens);
run_test(?TestSystemOptic); 
run_test(?TestSpace);
run_test(?TestArrow);
run_test(?TestFig);
run_test(?TestRay);
  
end
 




function run_test(TestObject)
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.Codecoverage.*
%% -------- Create a Test Class. -------------
suite = TestSuite.fromClass(TestObject);

%% Create the TestRunner object and run the suite.
runner = TestRunner.withTextOutput;
 
result = run(runner,suite);

%% Create Table of Test Results
rt = table(result)

end
