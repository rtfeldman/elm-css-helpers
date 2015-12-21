module Css.Helpers (namespace) where

{-| Helper functions for using elm-css with elm-html.

@docs namespace
-}

import Css.Util exposing (toCssIdentifier, classToString)
import Html exposing (Attribute)
import Html.Attributes as Attr
import String


type alias Namespace class id =
    { class : class -> Attribute
    , classList : List ( class, Bool ) -> Attribute
    , id : id -> Attribute
    , name : String
    }


{-| Takes a namespace and returns helper functions for `id`, `class`, and
`classList` which work just like their equivalents in `elm-html` except that
they accept union types and automatically incorporate the given namespace.

    -- Put this before your view code to specify a namespace.
    { id, class, classList } = namespace "homepage"

    view =
        h1 [ id Hero, class Fancy ] [ text "Hello, World!" ]

    type HomepageIds = Hero | SomethingElse | AnotherId
    type HomepageClasses = Fancy | AnotherClass | SomeOtherClass

The above would generate this DOM element:

    <h1 id="Hero" class="homepage_Fancy">Hello, World!</h1>
-}
namespace : String -> Namespace class id
namespace name =
    { class = classToString name >> Attr.class
    , classList = classList name
    , id = toCssIdentifier >> Attr.id
    , name = name
    }


classList : String -> List ( class, Bool ) -> Attribute
classList name list =
    list
        |> List.filter snd
        |> List.map (fst >> classToString name)
        |> String.join " "
        |> Attr.class
