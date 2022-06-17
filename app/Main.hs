module Main where

import Data.Aeson
import Data.Char (isAlpha)
import Data.Function ((&))
import qualified Data.HashMap.Strict as HashMap
import Data.List.Split (splitOn)
import Data.Text (unpack)
import Data.Vector (toList)
import Network.HTTP.Request
import Options.Applicative
import System.Environment (getArgs)
import System.IO (hPutStrLn, stderr)
import Text.Printf (printf)
import Text.Read (readMaybe)
import qualified Data.Vector as Vector
import Control.Arrow (ArrowChoice(left))
import System.Exit (exitWith, ExitCode (ExitFailure))

data Delim = Space | Newline
data QueryType = Id | Search
data Opts = Opts
  { delim :: Delim,
    queryType :: QueryType,
    query :: String
  }

opts :: Parser Opts
opts =
  Opts
      -- Provide -l or --one-per-line to print integers one per line
    <$> flag Space Newline 
      (short 'l' <> long "one-per-line" <> help "Print one integer per line")
      -- Provide -i|--id to search by OEIS ID number
    <*> flag Search Id
      (short 'i' <> long "id" <> help "Search by OEIS ID")
      -- Take all non-flag arguments together as a string
    <*> (unwords <$> some (strArgument $ metavar "QUERY|ID"))



main :: IO ()
main = do
  -- Run the options parser (failing on zero arguments)
  Opts {..} <- execParser 
    $ info (opts <**> helper) (fullDesc <> progDesc "Lookup OEIS data")

  -- Transform an ID if needed
  seq <- case queryType of
    Id -> do
      -- Allow IDs in the format A000001, transform to 000001
      let tailIf p = \case (x:xs) | p x -> xs; xs -> xs

      -- Ensure ID can be parsed numerically then convert it to Axxxxxx
      case readMaybe $ tailIf isAlpha query of
        Nothing -> pure 
          $ Left "ID provided is non-numeric. Please provide a numeric ID."
        Just n -> getSequence $ "id:A" ++ printf "%06d" (n::Integer)

    -- Non-ID queries are sent verbatim
    Search -> getSequence query

  case seq of
    -- If retrieval and/or parsing failed, print to stderr
    Left err -> hPutStrLn stderr err >> exitWith (ExitFailure 1)
    -- Otherwise print to stdout
    Right (Seq s) -> putStrLn $ export $ fmap show s
      where
        export = case delim of Space -> unwords; Newline -> unlines



getSequence :: String -> IO (Either String Seq)
getSequence seq = do
  Response {..} <- get $ "https://oeis.org/search?fmt=json&q=" ++ seq
  pure $
    if responseStatus /= 200
      then Left "Unable to query OEIS. Please try again."
      else eitherDecodeStrict responseBody 
        & left (const "No sequences found matching that query.")


newtype Seq = Seq [Integer]

instance Show Seq where
  show (Seq s) = unwords $ show <$> s

instance FromJSON Seq where
  parseJSON = withObject "OEIS Response" $ \o -> do
    o .: "results" >>= withArray "OEIS Results" \arr -> 
        Vector.head arr & withObject "OEIS Sequence" \o -> do
          o .: "data" >>= withText "Result" \r -> do
            pure $ Seq $ fmap read $ splitOn "," $ unpack r