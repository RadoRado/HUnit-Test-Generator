HUnit-Test-Generator
====================

A small Haskell program that reads a dead-simple DSL and generates proper HUnit tests

## Motiviation

Since HUnit tests are ugly to write and are not very easy to understand from Haskell beginners, I decided to use a simpler "language" to write tests.

Imagine we have `Prime.hs` module, which exports `isPrime :: Int -> Bool` funciton and we want to test it.

In order to do so, we create a file called `PrimeTests` with the following content:

```
import Prime
"2 should be prime" -> isPrime 2 == True
"4 should not be prime" -> isPrime 4 == False
"7 should be prime" -> isPrime 7 == True
```

The first line is the import for the module.

The synax of a test (which is one lone) is as follows:

```
"Message for the assertEqual" -> Function-Call == Expected-Value
```

The test is generated like so:

```
$ runhaskell GenerateTests.hs PrimeTests PrimeTests.hs
Everything is saved in PrimeTests.hs
Now running the tests
Cases: 3  Tried: 3  Errors: 0  Failures: 0
Counts {cases = 3, tried = 3, errors = 0, failures = 0}

```

This will generate a `PrimeTests.hs` file with the following content:

```haskell
import Prime
import Test.HUnit
test1 = TestCase(assertEqual "2 should be prime" True (isPrime 2))
test2 = TestCase(assertEqual "4 should not be prime" False (isPrime 4))
test3 = TestCase(assertEqual "7 should be prime" True (isPrime 7))

testList = TestList[ test1, test2, test3 ]
main = do runTestTT testList
```

After this, the student can simply run:

```
$ runhaskell PrimeTests.hs
```
