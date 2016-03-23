module Html.CssHelpers (withNamespace, style, stylesheetLink) where

{-| Helper functions for using elm-css with elm-html.

@docs withNamespace, style, stylesheetLink
-}

import Css.Helpers exposing (toCssIdentifier, identifierToString)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import String
import Json.Encode exposing (string)


type alias Helpers class id =
  { class : List class -> Attribute
  , classList : List ( class, Bool ) -> Attribute
  , id : id -> Attribute
  }


type alias Namespace name class id =
  { class : List class -> Attribute
  , classList : List ( class, Bool ) -> Attribute
  , id : id -> Attribute
  , name : name
  }


{-| Takes a namespace and returns helper functions for `id`, `class`, and
`classList` which work just like their equivalents in `elm-html` except that
they accept union types and automatically incorporate the given namespace. Also
note that `class` accepts a `List` instead of a single element; this is so you
can specify multiple classes without having to call `classList` passing tuples
that all end in `True`.

    -- Put this before your view code to specify a namespace.
    { id, class, classList } = withNamespace "homepage"

    view =
        h1 [ id Hero, class [ Fancy ] ] [ text "Hello, World!" ]

    type HomepageIds = Hero | SomethingElse | AnotherId
    type HomepageClasses = Fancy | AnotherClass | SomeOtherClass

The above would generate this DOM element:

    <h1 id="Hero" class="homepage_Fancy">Hello, World!</h1>
-}
withNamespace : name -> Namespace name class id
withNamespace name =
  { class = namespacedClass name
  , classList = namespacedClassList name
  , id = toCssIdentifier >> Attr.id
  , name = name
  }


helpers : Helpers class id
helpers =
  { class = class
  , classList = classList
  , id = toCssIdentifier >> Attr.id
  }


namespacedClassList : name -> List ( class, Bool ) -> Attribute
namespacedClassList name list =
  list
    |> List.filter snd
    |> List.map fst
    |> namespacedClass name


classList : List ( class, Bool ) -> Attribute
classList list =
  list
    |> List.filter snd
    |> List.map fst
    |> class


namespacedClass : name -> List class -> Attribute
namespacedClass name list =
  list
    |> List.map (identifierToString name)
    |> String.join " "
    |> Attr.class


class : List class -> Attribute
class =
  namespacedClass ""


{-| Create an inline style from CSS
-}
style : String -> Html
style text =
    Html.node
        "style"
        [ Attr.property "textContent" <| string text
        , Attr.property "type" <| string "text/css" ]
        []


{-| Link in a stylesheet from a url
-}
stylesheetLink : String -> Html
stylesheetLink url =
    Html.node
        "link"
        [ Attr.property "rel" (string "stylesheet")
        , Attr.property "type" (string "text/css")
        , Attr.property "href" (string url)
        ]
        []
