import Prime
import Test.HUnit
test1 = TestCase(assertEqual "2 should be prime" True (isPrime 2))
test2 = TestCase(assertEqual "4 should not be prime" False (isPrime 4))
test3 = TestCase(assertEqual "7 should be prime" True (isPrime 7))

testList = TestList[ test1, test2, test3 ]
main = do runTestTT testList
