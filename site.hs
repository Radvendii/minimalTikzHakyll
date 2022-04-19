{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import Text.Pandoc.Definition
import Text.Pandoc.Walk (walkM)
import Control.Monad ((>=>))
import Data.ByteString.Lazy.Char8 (pack, unpack)
import qualified Network.URI.Encode as URI (encode)
import qualified Data.Text as Text

---------------------------------------------------------------------------------

myPandocCompiler = pandocCompilerWithTransformM defaultHakyllReaderOptions defaultHakyllWriterOptions $ walkM tikzFilter

tikzFilter :: Block -> Compiler Block
tikzFilter (CodeBlock (id, "tikzpicture":extraClasses, namevals) contents) =
  (imageBlock . ("data:image/svg+xml;utf8," ++) . URI.encode . filter (/= '\n') . itemBody <$>) $
    makeItem (Text.unpack contents)
     >>= loadAndApplyTemplate (fromFilePath "templates/tikz.tex") (bodyField "body")
     >>= withItemBody (return . pack
                       >=> unixFilterLBS "rubber-pipe" ["--pdf"]
                       >=> unixFilterLBS "pdftocairo" ["-svg", "-", "-"]
                       >=> return . unpack)
  where imageBlock fname = Para [Image (id, "tikzpicture":extraClasses, namevals) [] (Text.pack fname, "")]
tikzFilter x = return x

---------------------------------------------------------------------------------

main :: IO ()
main = hakyll $ do
  match "templates/*" $ compile templateBodyCompiler

  match "css/*.css" $ do
    route   idRoute
    compile compressCssCompiler

  match "index.md" $ do
    route $ constRoute "index.html"
    compile $ myPandocCompiler >>= loadAndApplyTemplate "templates/default.html" defaultContext
