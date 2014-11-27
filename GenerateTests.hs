import System.IO
import System.Directory
import System.Environment (getArgs)
import System.Process
import Data.List.Split
import Data.Char (isSpace)
import Data.String.Utils

trim :: String -> String
trim = f . f
    where f = reverse . dropWhile isSpace

prepareTemplate :: [(String, String)] -> String -> String
prepareTemplate [] templateString = templateString
prepareTemplate (x:xs) templateString = prepareTemplate xs (replaceVariable x templateString)
    where
        replaceVariable (name, value) tpl = replace namePlaceholder value tpl
            where
                namePlaceholder = "{{" ++ name ++ "}}"

importHUnit :: String
importHUnit = "import Test.HUnit"

mainFunction :: String
mainFunction = "main = do runTestTT testList"

generateTestList :: Int -> String
generateTestList testCasesCount = testListCode
    where
        testCasesSeparatedByComma = join ", " $ map (\index -> "test" ++ (show index)) [1 .. testCasesCount]
        testListCode = unwords ["testList = TestList[", testCasesSeparatedByComma, "]"]


generateAssertEqual :: Int -> String -> String -> String -> String
generateAssertEqual testNumber message expected fCall = prepareTemplate variables assertEqualTpl
    where
        variables = [("testNumber", show testNumber), ("message", message), ("expected", expected), ("fCall", fCall)]
        assertEqualTpl = "test{{testNumber}} = TestCase(assertEqual {{message}} {{expected}} ({{fCall}}))"

-- Takes a line and returns a valid Haskell testCase code
generateTestCase :: Int -> String -> String
generateTestCase testNumber line = testCaseExpression
    where
        (message, testPart) = extractParts "->" line
        (functionCall, expectedPart) = extractParts "==" testPart
        testCaseExpression = generateAssertEqual testNumber message expectedPart functionCall

extractParts :: String -> String -> (String, String)
extractParts delimiter text = (firstPart, secondPart)
    where
            parts@(x:y:xs) = map trim $ splitOn delimiter text
            firstPart = x
            secondPart = y

writePart :: String -> String -> IO()
writePart fileName line = appendFile fileName (line ++ "\n")

main = do
    args@(sourceFileName:destinationFileName:nothing) <- getArgs
    content <- readFile sourceFileName
    let (moduleName:contents) = lines content
    writePart destinationFileName moduleName
    writePart destinationFileName importHUnit
    writePart destinationFileName $ unlines $ map (\(index, line) -> generateTestCase index line) $ zip [1 .. (length contents)] contents
    writePart destinationFileName $ generateTestList (length contents)
    writePart destinationFileName mainFunction
    putStrLn $ "Everything is saved in " ++ destinationFileName
    putStrLn $ "Now running the tests"
    _ <- system("runhaskell " ++ destinationFileName)
    return ()
