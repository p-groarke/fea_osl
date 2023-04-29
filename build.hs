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

getBuildDirLeaf :: IO String
getBuildDirLeaf = do
	unfiltered_ver <- getFeaVer
	let ver = filter (\x -> x /= '.') unfiltered_ver
	let folder = "FeaOSL-" ++ ver ++ "/"
	return folder

getBuildDir :: IO String
getBuildDir = do
	leaf <- getBuildDirLeaf
	let folder = "build/" ++ leaf
	return folder

getZipFilename :: IO String
getZipFilename = do
	ver <- getFeaVer
	let n = "FeaOSL-" ++ ver ++ ".zip"
	return n

readInclude :: String -> IO String
readInclude l = do
	let path = last (words l)
	if "\"" `isInfixOf` path
	then parseFile (parseIncludePath l)
	else return l

replaceInclude :: String -> IO String
replaceInclude contents = do
	f_lines <- mapM
			(\l ->
				if "#include" `isInfixOf` l
				then readInclude l
				else return l
			)
			(lines contents)

	return (unlines f_lines)

parseFile :: String -> IO String
parseFile filename = do
	contents <- readFile filename
	new_contents <- replaceInclude contents
	return new_contents

writeToTemp :: FilePath -> String -> IO ()
writeToTemp filepath contents = do
	build_dir <- getBuildDir
	let out_filepath = build_dir ++ takeFileName filepath
	writeFile out_filepath contents


main :: IO ()
main = do
	out_filename <- getZipFilename
	printf "Generating %s\n" out_filename

	fea_version <- getFeaVer
	build_dir <- getBuildDir
	build_dir_leaf <- getBuildDirLeaf

	dirExists <- doesDirectoryExist build_dir
	when dirExists (removeDirectoryRecursive build_dir)
	createDirectoryIfMissing True build_dir

	files <- listDirectory "."

	-- Copy supporting files (.md, .ui)
	let support_files = filter
			(\x -> isSuffixOf ".md" x || isSuffixOf ".ui" x || isSuffixOf ".csv" x)
			files

	-- let support_files = filter
	-- 		(liftM2 (||) (isSuffixOf ".md") (isSuffixOf ".ui"))
	-- 		files

	mapM_ (\f -> copyFile f (build_dir ++ f)) support_files

	-- Get *.osl files.
	let osl_filepaths = filter
			(liftM2 (&&) (isSuffixOf ".osl") (/= feaLibFilename))
			files

	-- Replace osl #include statements with target file contents.
	new_file_contents <- mapM parseFile osl_filepaths
	zipWithM_ writeToTemp osl_filepaths new_file_contents

	-- Now, zip everything in the temp directory.
	let out_filepath = build_dir_leaf ++ out_filename
	let zip_expr = build_dir_leaf ++ "*"
	-- callProcess "7z" ["a", "-aoa", "-tzip", out_filepath,
	-- 		"./" ++ tempBuildDir ++ "/*"]
	setCurrentDirectory "./build"
	callProcess "7z" ["a", "-aoa", "-tzip", out_filepath, zip_expr]
