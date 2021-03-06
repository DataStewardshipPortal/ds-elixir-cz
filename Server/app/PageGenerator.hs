{-# LANGUAGE OverloadedStrings #-}

module PageGenerator (renderPage) where

import           Data.Monoid
import qualified Data.Text as T

import           Text.Blaze.Internal (textValue)
import           Text.Blaze.Html5 (Html, toHtml, (!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

import           Config.Config (baseURL, staticURL, respondentKeyFieldId, respondentKeyFieldName)

import           Modes
import qualified Texts
import           Model.Respondent as R

import qualified Bridge as B

{-# ANN module ("HLint: ignore Redundant do" :: String) #-}
{-# ANN module ("HLint: ignore Use camelCase" :: String) #-}

renderOverlay :: T.Text -> Html -> Html
renderOverlay elemId content = do
  H.div ! A.id (H.toValue elemId) ! A.class_ "overlay" ! A.onclick fn $ do
    H.div content
  where
    fn = H.toValue $ T.concat ["Haste['overlay']('", elemId, "')"]

renderHead :: Html
renderHead = H.head $ do
    H.meta ! A.charset "utf-8"
    H.meta ! A.httpEquiv "X-UA-Compatible" ! A.content "IE=edge"
    H.title "Questionnaire"
    H.meta ! A.name "viewport" ! A.content "width=device-width, initial-scale=1"
    H.link ! A.rel "stylesheet" ! A.href (textValue $ staticURL <> "css/normalize.min.css")
    H.link ! A.rel "stylesheet" ! A.href ( textValue $ staticURL <> "css/auto-complete.css")
    H.link ! A.rel "stylesheet" ! A.href ( textValue $ staticURL <> "css/main.css")
    H.script ! A.src (textValue $ staticURL <> "js/vendor/jquery-3.1.1.min.js") $ mempty

renderBanner :: Html
renderBanner = H.div ! A.id "banner" $ do
  H.p ! A.class_ "title" $ "Interoperability Platform"
  H.a ! A.href "https://www.elixir-czech.cz/" $ do
    H.img ! A.src (textValue $ staticURL <> "img/logo.jpg") ! A.id "logo" ! A.alt "Elixir logo"

renderControlPanel :: Mode -> Html
renderControlPanel mode = do
  H.div ! A.id "control-panel" ! A.class_ "control-panel" $ do
    case mode of
        ReadOnly -> nonSaveable
        WrongRespondent -> nonSaveable
        Filling _ -> saveable
        Submitted -> nonSaveable
    H.div ! A.id (H.toValue B.infoBarId) ! A.class_ "info-bar" $ "Data not saved"
    where
    saveable = do
      H.button ! A.class_ "action-button" ! A.onclick (textValue $ T.pack $ B.call0 B.SavePlan) $ do
        H.img ! A.class_ "action-icon" ! A.src (textValue $ staticURL <> "img/save.png") ! A.alt "Save the questionnaire"
        H.span "Save"
    nonSaveable = do
      H.div ! A.class_ "control-panel-label no-plan" $ "No key provided"
      H.button ! A.class_ "action-button action-button-disabled" $ do
        H.img ! A.class_ "action-icon action-icon-disabled" ! A.src (textValue $ staticURL <> "img/save.png") ! A.alt "Save the plan"
        H.span "Save"

renderTabs :: Html
renderTabs = H.ul ! A.class_ "nav mainNav" $ do
  H.li ! A.id "tab_100" $ H.a ! A.onclick "Haste['toVision']()" $ "Vision"
  H.li ! A.id "tab_200" $ H.a ! A.onclick "Haste['toAction']()" $ "Action steps"
  H.li ! A.id "tab_300" $ H.a ! A.onclick "Haste['toLifecycle']()" $ "Lifecycle"
  H.li ! A.id "tab_400" $ H.a ! A.onclick "Haste['toData']()" $ "Data"
  H.li ! A.id "tab_500" $ H.a ! A.onclick "Haste['toRoles']()" $ "Roles"
  H.li ! A.id "tab_600" $ H.a ! A.onclick "Haste['toMQuestionnaire']()" $ "Managerial Questionnaire"
  H.li ! A.id "tab_700" $ H.a ! A.onclick "Haste['toTQuestionnaire']()" $ "Technical Questionnaire"

renderFooter :: Html
renderFooter = H.div ! A.id "footer" ! A.class_ "stripe" $ do
  H.table ! A.class_ "footer-table" $ H.tbody $ do
    H.tr $ do
      H.td $ do
        H.h3 "Contact"
        _ <- "Phone: +420 220 183 267"
        H.br
        _ <- "E-mail : elixir@uochb.cas.cz"
        H.br
        H.a ! A.href "http://www.elixir-czech.cz" $ "http://www.elixir-czech.cz"
      H.td $ do
        H.h3 "Address"
        _ <- "ELIXIR CZ"
        H.br
        _ <- "Flemingovo nám. 542/2"
        H.br
        _ <- "166 10 Praha 6 - Dejvice"
        H.br
        "Czech Republic"
      H.td ! A.style "text-align: center; " $ do
        H.h3 "Data stewardship action team"
        H.a ! A.href "https://www.uochb.cz" $ H.img ! A.src (textValue $ staticURL <> "img/logo-uochb.png") ! A.class_ "logo" ! A.alt "FIT logo"
        H.a ! A.href "http://ccmi.fit.cvut.cz/en" $ H.img ! A.src (textValue $ staticURL <> "img/logo-ccmi.png") ! A.class_ "logo" ! A.alt "CCMi logo"
        H.a ! A.href "http://fit.cvut.cz/en" $ H.img ! A.src (textValue $ staticURL <> "img/logo-fit.png") ! A.class_ "logo" ! A.alt "FIT logo"
        H.br
        H.span "Contact: "
        H.a ! A.href "mailto:robert.pergl@fit.cvut.cz" $ "robert.pergl@fit.cvut.cz"
      H.td $ do
        H.h3 "Links"
        H.a ! A.href "http://www.elixir-europe.org/" $ "ELIXIR Europe"
        H.br
        H.a ! A.href "http://www.elixir-europe.org/about/elixir-nodes" $ "ELIXIR Nodes"
        H.br
        H.a ! A.href "http://www.elixir-czech.org/" $ "ELIXIR Czech"
        H.br
        H.a ! A.href "http://www.elixir-czech.cz/" $ "ELIXIR Czech local"
        H.br
        H.a ! A.href "https://www.elixir-czech.cz/login" $ "Members area"

renderAcknowledgement :: Html
renderAcknowledgement = do
  H.div ! A.class_ "colophon-box" $ do
    H.span ! A.class_ "colophon-text" $ "Crafted with "
    H.a ! A.href "https://www.haskell.org/ghc/" ! A.class_ "colophon-text" $ "GHC"
    H.span ! A.class_ "colophon-text" $ " & "
    H.a ! A.href "http://haste-lang.org/" ! A.class_ "colophon-text" $ "Haste"
    H.span ! A.class_ "colophon-text" $ ", powered by "
    H.a ! A.href "https://github.com/scotty-web/scotty" ! A.class_ "colophon-text" $ "Scotty"
    H.img ! A.src (textValue $ staticURL <> "img/haskell.png") ! A.alt "Haskell logo"

-- Pages

renderPage :: Mode -> Html
renderPage mode = do
  H.docTypeHtml ! A.class_ "no-js" ! A.lang "en" $ do
    renderHead
    H.body $ do
      H.div ! A.id "container" $ do
        renderBanner
        renderControlPanel mode
        case mode of
          ReadOnly -> H.div ! A.class_ "bar error" $ "To be able to submit your data, please apply for a respondent key @ robert.pergl@fit.cvut.cz"
          WrongRespondent ->  H.div ! A.class_ "bar error" $ do
            _ <- "Wrong respondent key in URL"
            closeButton "error"
          Filling respondent -> H.div ! A.class_ "bar message" $ do
            _ <- "Questionnaire opened for: "
            H.span ! A.style "font-style: normal; color: black;" $ toHtml $ R.name respondent
            _ <- " (last submission: "
            H.span ! A.style "font-style: normal; color: black;" $ toHtml $ R.submissionInfo respondent
            ")"
          Submitted -> H.div ! A.class_ "bar message" $ do
            _ <- "Thank you for your submission! "
            closeButton "message"
        renderTabs
        H.div ! A.id "banner-bottom" ! A.class_ "stripe stripe-thick" $ mempty
        H.div ! A.id "loader" ! A.class_ "loader" $ "Rendering the Knowledge model..."
        H.div ! A.id "inside" ! A.class_ "inside" $ do
          visionPane
          actionPane
          lifeCyclePane
          dataPane
          rolesPane
          mFormHolderPane
          tFormHolderPane
        overlayPanes
        renderFooter
        renderAcknowledgement
        foot
  where
    closeButton typ = H.a ! A.href (textValue baseURL) $ H.button ! A.class_ ("close-button " <> textValue typ) $ "X"
    visionPane = H.div ! A.id "pane_100" $ Texts.vision
    actionPane = H.div ! A.id "pane_200" ! A.style "display: none;" $ Texts.actionSteps
    lifeCyclePane = H.div ! A.id "pane_300" ! A.style "display: none;" $ Texts.lifeCycle
    dataPane = H.div ! A.id "pane_400" ! A.style "display: none;" $ Texts.dataText
    rolesPane = H.div ! A.id "pane_500" ! A.style "display: none;" $ Texts.roles
    mFormHolderPane =
      H.div ! A.id "pane_600" ! A.style "display: none;" $ do
        H.form ! A.id (H.toValue B.formId) ! A.method "post" ! A.action "submit"  $ do
          H.input ! A.type_ "hidden" ! A.id (textValue respondentKeyFieldId) ! A.name (textValue respondentKeyFieldName) ! A.value (textValue respondentKey)
        where
          respondentKey = case mode of
            ReadOnly -> ""
            WrongRespondent -> ""
            Filling respondent -> R.key respondent
            Submitted -> ""
    tFormHolderPane = H.div ! A.id "pane_700" ! A.style "display: none;" $
      H.p ! A.style "font-style: italic;" $ "Being prepared."
    overlayPanes = do
      renderOverlay "overlay1" Texts.overlay1
      renderOverlay "overlay2" Texts.overlay2
      renderOverlay "overlay3" Texts.overlay3
      renderOverlay "overlay4" Texts.overlay4
      renderOverlay "overlay5" Texts.overlay5
      renderOverlay "overlay6" Texts.overlay6
    foot = H.script ! A.src (textValue $ staticURL <> "js/main.js") $ mempty

