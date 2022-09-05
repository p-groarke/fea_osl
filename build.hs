{-# OPTIONS_GHC -fno-warn-tabs #-}
{-# LANGUAGE ScopedTypeVariables #-}

import System.IO ()
import System.Process ( readProcess, callProcess )
import System.Directory ( createDirectoryIfMissing, findFileWith, listDirectory, copyFile, removeDirectory, removeDirectoryRecursive, doesDirectoryExist, setCurrentDirectory )
import Control.Monad ( filterM, liftM2, zipWithM_, when )
import Control.Exception ( assert )
import Text.Printf ( printf )
import Data.Char ( isSpace )
import Data.List ( isSuffixOf, isPrefixOf, findIndex, isInfixOf, words )
import System.FilePath (takeFileName)

{- Globals -}
outDir :: String
outDir = "build"

tempBuildDir :: String
tempBuildDir = "build/FeaOSL"

feaLibFilename :: String
feaLibFilename = "fea.osl"

readmeFilename :: String
readmeFilename = "README.md"


{- Pure -}
rstrip :: String -> String
rstrip = reverse . dropWhile isSpace . reverse

parseIncludePath :: String -> String
parseIncludePath s = do
	let wrds = words s
	-- assert (length wrds == 2) wrds
	tail (init (last wrds))

{- Impure -}
getFeaVer :: IO String
getFeaVer = do
	v <- readProcess "git" ["describe", "--tags", "--abbrev=0"] []
	let r = rstrip v
	return r

getZipFilename :: IO String
getZipFilename = do
	ver <- getFeaVer
	let n = "FeaOSL-" ++ ver ++ ".zip"
	return n

replaceInclude :: String -> IO String
replaceInclude contents = do
	f_lines <- mapM
			(\l ->
				if (isInfixOf "#include" l)
				then readFile (parseIncludePath l)
				else return l
			)
			(lines contents)

	return (unlines f_lines)


writeToTemp :: FilePath -> String -> IO ()
writeToTemp filepath contents = do
	let out_filepath = tempBuildDir ++ "/" ++ takeFileName filepath
	writeFile out_filepath contents


main :: IO ()
main = do
	out_filename <- getZipFilename
	printf "Generating %s\n" out_filename

	-- Cleanup, todo : At end
	dirExists <- doesDirectoryExist tempBuildDir
	when dirExists (removeDirectoryRecursive tempBuildDir)
	createDirectoryIfMissing True tempBuildDir

	files <- listDirectory "."

	-- Copy supporting files (.md, .ui)
	let support_files = filter
			(\x -> isSuffixOf ".md" x || isSuffixOf ".ui" x || isSuffixOf ".csv" x)
			files

	-- let support_files = filter
	-- 		(liftM2 (||) (isSuffixOf ".md") (isSuffixOf ".ui"))
	-- 		files

	mapM_ (\f -> copyFile f (tempBuildDir ++ "/" ++ f)) support_files

	-- Get *.osl files.
	let osl_filepaths = filter
			(liftM2 (&&) (isSuffixOf ".osl") (/= feaLibFilename))
			files

	-- Replace osl #include statements with target file contents.
	osl_file_contents <- mapM readFile osl_filepaths
	new_file_contents <- mapM replaceInclude osl_file_contents
	zipWithM_ writeToTemp osl_filepaths new_file_contents

	-- Now, zip everything in the temp directory.
	let out_filepath = "FeaOSL/" ++ out_filename
	-- callProcess "7z" ["a", "-aoa", "-tzip", out_filepath,
	-- 		"./" ++ tempBuildDir ++ "/*"]
	setCurrentDirectory "./build"
	callProcess "7z" ["a", "-aoa", "-tzip", out_filepath,
			"FeaOSL/*"]

